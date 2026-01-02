#!/bin/bash
# Deploy Argo Workflows using local images
# This script installs Argo Workflows from packaged Helm charts using local registry images

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
CHARTS_DIR="${CHARTS_DIR:-$LAB_DIR/preparation/charts}"
VALUES_FILE="${VALUES_FILE:-$LAB_DIR/../../modules/kubernetes/argo-workflows-airgap/helm-values.yaml}"
REGISTRY="${REGISTRY:-local-registry.registry.svc.cluster.local:5000}"

echo "⚙️  Deploying Argo Workflows from local images"
echo ""
echo "Charts directory: $CHARTS_DIR"
echo "Values file: $VALUES_FILE"
echo "Registry: $REGISTRY"
echo ""

# Check prerequisites
command -v helm >/dev/null 2>&1 || { echo "❌ helm is required but not installed." >&2; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required but not installed." >&2; exit 1; }

# Check if charts directory exists
if [ ! -d "$CHARTS_DIR" ]; then
  echo "❌ Charts directory not found: $CHARTS_DIR"
  echo "   Make sure you've transferred the deployment bundle"
  exit 1
fi

# Find Argo Workflows chart
ARGO_CHART=$(find "$CHARTS_DIR" -name "argo-workflows-*.tgz" | head -1)

if [ -z "$ARGO_CHART" ]; then
  echo "❌ Argo Workflows chart not found in $CHARTS_DIR"
  exit 1
fi

echo "📦 Found chart: $(basename $ARGO_CHART)"
echo ""

# Create namespace
echo "📝 Creating namespace..."
kubectl create namespace argo --dry-run=client -o yaml | kubectl apply -f -

# Update values file with registry address
TEMP_VALUES=$(mktemp)
cp "$VALUES_FILE" "$TEMP_VALUES"

# Replace registry address in values file
sed -i.bak "s|local-registry:5000|${REGISTRY}|g" "$TEMP_VALUES"
rm -f "${TEMP_VALUES}.bak"

echo "📋 Installing Argo Workflows..."
echo "   Chart: $ARGO_CHART"
echo "   Values: $TEMP_VALUES"
echo ""

# Install Argo Workflows
if helm install argo-workflows "$ARGO_CHART" \
  --namespace argo \
  --values "$TEMP_VALUES" \
  --wait --timeout 5m; then
  echo "✅ Argo Workflows installed successfully"
else
  echo "❌ Failed to install Argo Workflows"
  rm -f "$TEMP_VALUES"
  exit 1
fi

# Cleanup temp file
rm -f "$TEMP_VALUES"

# Wait for pods to be ready
echo "⏳ Waiting for Argo Workflows to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argo-workflows-server -n argo || true
kubectl wait --for=condition=available --timeout=300s deployment/workflow-controller -n argo || true

# Check pod status
echo ""
echo "📊 Pod status:"
kubectl get pods -n argo

echo ""
echo "✅ Argo Workflows deployment complete!"
echo ""
echo "Next steps:"
echo "1. Validate deployment: ./validate.sh"
echo "2. Submit test workflow: kubectl apply -f ../../reference-app/workflows/hello-world.yaml"
echo "3. Access UI (port-forward): kubectl port-forward svc/argo-workflows-server 2746:2746 -n argo"


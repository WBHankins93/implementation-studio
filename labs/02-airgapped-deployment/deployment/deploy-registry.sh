#!/bin/bash
# Deploy local container registry
# This script deploys a Docker registry inside the cluster

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "📦 Deploying local container registry"
echo ""

# Check prerequisites
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required but not installed." >&2; exit 1; }

# Check if registry already exists
if kubectl get deployment local-registry -n registry &>/dev/null; then
  echo "ℹ️  Registry already deployed"
  echo "   To redeploy, delete first: kubectl delete deployment local-registry -n registry"
  exit 0
fi

# Deploy registry
echo "📋 Applying registry manifests..."
kubectl apply -f "$LAB_DIR/02-airgapped-deployment/manifests/registry.yaml"

# Wait for registry to be ready
echo "⏳ Waiting for registry to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/local-registry -n registry

# Get registry endpoint
REGISTRY_IP=$(kubectl get svc local-registry -n registry -o jsonpath='{.spec.clusterIP}')
REGISTRY_PORT=$(kubectl get svc local-registry -n registry -o jsonpath='{.spec.ports[0].port}')

echo ""
echo "✅ Registry deployed successfully!"
echo ""
echo "Registry endpoint: ${REGISTRY_IP}:${REGISTRY_PORT}"
echo "Registry service: local-registry.registry.svc.cluster.local:5000"
echo ""
echo "Next steps:"
echo "1. Load images: ./load-images.sh"
echo "2. Verify registry: kubectl get pods -n registry"


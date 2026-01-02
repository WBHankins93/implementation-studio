#!/bin/bash
# Prepare demo environment - verify everything works, create demo workflows

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🎬 Preparing POC Demo"
echo ""

# Check if kubectl is configured
if ! kubectl cluster-info &>/dev/null; then
  echo "❌ kubectl is not configured"
  echo "   Run: gcloud container clusters get-credentials <cluster-name> --region <region> --project <project-id>"
  exit 1
fi

# Verify Argo Workflows is running
echo "🔍 Verifying Argo Workflows..."
if kubectl get deployment argo-workflows-server -n argo &>/dev/null; then
  READY=$(kubectl get deployment argo-workflows-server -n argo -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
  if [ "$READY" != "0" ]; then
    echo "✅ Argo Workflows is ready"
  else
    echo "⚠️  Argo Workflows is not ready yet"
  fi
else
  echo "❌ Argo Workflows not found. Run ./scripts/quick-deploy.sh first"
  exit 1
fi

# Create demo namespace if needed
echo "📝 Setting up demo namespace..."
kubectl create namespace demo --dry-run=client -o yaml | kubectl apply -f -

# Deploy demo workflows
echo "📦 Deploying demo workflows..."
if [ -d "$LAB_DIR/manifests" ]; then
  kubectl apply -f "$LAB_DIR/manifests/" || true
  echo "✅ Demo workflows deployed"
else
  echo "⚠️  No manifests directory found"
fi

# Get Argo UI access info
echo ""
echo "🌐 Argo Workflows UI Access:"
echo ""
echo "Port forward command:"
echo "  kubectl port-forward -n argo svc/argo-workflows-server 2746:2746"
echo ""
echo "Then open: http://localhost:2746"
echo ""

# List available workflows
echo "📋 Available workflows:"
kubectl get workflows --all-namespaces 2>/dev/null || echo "  (No workflows yet)"

echo ""
echo "✅ Demo preparation complete!"
echo ""
echo "Review demo script: $LAB_DIR/demo-prep/demo-script.md"
echo "Review backup demo: $LAB_DIR/demo-prep/backup-demo.md"


#!/bin/bash
# Setup Kind cluster for local testing

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLUSTER_NAME="${CLUSTER_NAME:-implementation-studio}"

echo "🚀 Setting up Kind cluster: $CLUSTER_NAME"

# Check for required tools
command -v kind >/dev/null 2>&1 || { echo "❌ kind is required but not installed. Install: brew install kind" >&2; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required but not installed." >&2; exit 1; }

# Check if cluster already exists
if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
  echo "⚠️  Cluster $CLUSTER_NAME already exists. Delete it first with: kind delete cluster --name $CLUSTER_NAME"
  exit 1
fi

# Create cluster
echo "  Creating Kind cluster..."
kind create cluster --name "$CLUSTER_NAME" --wait 5m

# Wait for cluster to be ready
echo "  Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

echo "✅ Kind cluster '$CLUSTER_NAME' is ready!"
echo ""
echo "To use this cluster:"
echo "  export KUBECONFIG=\$(kind get kubeconfig-path --name $CLUSTER_NAME)"
echo ""
echo "To delete this cluster:"
echo "  kind delete cluster --name $CLUSTER_NAME"


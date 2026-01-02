#!/bin/bash
# Setup Kind cluster to simulate air-gapped environment
# This creates a cluster and applies network policies to block external access

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLUSTER_NAME="${CLUSTER_NAME:-airgap-simulation}"

echo "🚀 Setting up Kind cluster for air-gap simulation"
echo ""

# Check prerequisites
command -v kind >/dev/null 2>&1 || { echo "❌ kind is required but not installed. Install: brew install kind" >&2; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required but not installed." >&2; exit 1; }

# Check if cluster already exists
if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
  echo "⚠️  Cluster $CLUSTER_NAME already exists."
  read -p "Delete existing cluster and recreate? (y/N): " -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🗑️  Deleting existing cluster..."
    kind delete cluster --name "$CLUSTER_NAME"
  else
    echo "Using existing cluster."
    exit 0
  fi
fi

# Create cluster
echo "📦 Creating Kind cluster..."
if kind create cluster --name "$CLUSTER_NAME" --config "$SCRIPT_DIR/kind-config.yaml" --wait 5m; then
  echo "✅ Cluster created successfully"
else
  echo "❌ Failed to create cluster"
  exit 1
fi

# Wait for cluster to be ready
echo "⏳ Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s --context kind-$CLUSTER_NAME

# Apply network policies to block external access
echo "🔒 Applying network policies to block external access..."

cat <<EOF | kubectl apply -f - --context kind-$CLUSTER_NAME
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-egress
  namespace: default
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress: []  # No egress rules = block all external traffic
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-egress-kube-system
  namespace: kube-system
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  # Allow DNS resolution within cluster
  - to:
    - namespaceSelector:
        matchLabels:
          name: kube-system
    ports:
    - protocol: UDP
      port: 53
EOF

echo "✅ Network policies applied"

# Create argo namespace
echo "📝 Creating namespaces..."
kubectl create namespace argo --dry-run=client -o yaml | kubectl apply -f - --context kind-$CLUSTER_NAME
kubectl create namespace registry --dry-run=client -o yaml | kubectl apply -f - --context kind-$CLUSTER_NAME

# Apply network policy to argo namespace (allow only internal traffic)
cat <<EOF | kubectl apply -f - --context kind-$CLUSTER_NAME
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-internal-only
  namespace: argo
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector: {}  # Allow from any namespace
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: registry  # Allow access to registry
  - to:
    - namespaceSelector: {}  # Allow internal cluster communication
    ports:
    - protocol: UDP
      port: 53  # DNS
EOF

echo "✅ Air-gap simulation setup complete!"
echo ""
echo "Cluster: $CLUSTER_NAME"
echo "Context: kind-$CLUSTER_NAME"
echo ""
echo "To use this cluster:"
echo "  export KUBECONFIG=\$(kind get kubeconfig-path --name $CLUSTER_NAME)"
echo "  kubectl config use-context kind-$CLUSTER_NAME"
echo ""
echo "To verify air-gap (should fail):"
echo "  kubectl run test --image=busybox --rm -it --restart=Never -- wget -O- https://www.google.com"
echo ""
echo "To delete this cluster:"
echo "  kind delete cluster --name $CLUSTER_NAME"


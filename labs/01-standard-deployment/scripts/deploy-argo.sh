#!/bin/bash
# Deploy Argo Workflows and Ingress NGINX to the cluster

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🚀 Deploying Argo Workflows and Ingress NGINX"
echo ""

# Check if kubectl is configured
if ! kubectl cluster-info &>/dev/null; then
  echo "❌ kubectl is not configured or cluster is not accessible"
  echo "   Run: gcloud container clusters get-credentials <cluster-name> --region <region> --project <project-id>"
  exit 1
fi

# Get cluster info
CLUSTER_NAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}' 2>/dev/null || echo "unknown")
echo "📦 Cluster: $CLUSTER_NAME"
echo ""

# Add Helm repos
echo "📥 Adding Helm repositories..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Create namespace
echo "📝 Creating namespace..."
kubectl create namespace argo --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace ingress-nginx --dry-run=client -o yaml | kubectl apply -f -

# Install Ingress NGINX
echo "🌐 Installing Ingress NGINX..."
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --values "$LAB_DIR/../../modules/kubernetes/ingress-nginx/helm-values.yaml" \
  --wait

# Install Argo Workflows
echo "⚙️  Installing Argo Workflows..."
helm upgrade --install argo-workflows argo/argo-workflows \
  --namespace argo \
  --values "$LAB_DIR/../../modules/kubernetes/argo-workflows/helm-values.yaml" \
  --wait

# Wait for services
echo "⏳ Waiting for services to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argo-workflows-server -n argo || true
kubectl wait --for=condition=available --timeout=300s deployment/ingress-nginx-controller -n ingress-nginx || true

# Get ingress IP
echo ""
echo "🔍 Getting Ingress IP..."
INGRESS_IP=$(kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")
if [ "$INGRESS_IP" != "pending" ] && [ -n "$INGRESS_IP" ]; then
  echo "✅ Ingress IP: $INGRESS_IP"
else
  echo "⏳ Ingress IP is still being assigned. Check with:"
  echo "   kubectl get service ingress-nginx-controller -n ingress-nginx"
fi

echo ""
echo "✅ Deployment complete!"
echo ""
echo "Next steps:"
echo "1. Create an Ingress resource to expose Argo Workflows UI"
echo "2. Submit a sample workflow: kubectl apply -f manifests/sample-workflow.yaml"
echo "3. Access the UI once Ingress is configured"


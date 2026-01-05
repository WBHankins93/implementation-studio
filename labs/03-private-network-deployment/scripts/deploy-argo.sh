#!/bin/bash
# Deploy Argo Workflows and Internal Ingress NGINX to the private cluster
# This script should be run from the bastion host (works for both GCP and AWS)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🚀 Deploying Argo Workflows and Internal Ingress NGINX"
echo ""

# Check if kubectl is configured
if ! kubectl cluster-info &>/dev/null; then
  echo "❌ kubectl is not configured or cluster is not accessible"
  echo ""
  echo "For GCP:"
  echo "   gcloud container clusters get-credentials <cluster-name> --region <region> --project <project-id> --internal-ip"
  echo ""
  echo "For AWS:"
  echo "   aws eks update-kubeconfig --region <region> --name <cluster-name>"
  exit 1
fi

# Detect cloud provider (try to infer from cluster endpoint or config)
CLUSTER_ENDPOINT=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' 2>/dev/null || echo "")
if [[ "$CLUSTER_ENDPOINT" == *"gke"* ]] || [[ "$CLUSTER_ENDPOINT" == *"googleapis"* ]]; then
  CLOUD_PROVIDER="gcp"
elif [[ "$CLUSTER_ENDPOINT" == *"eks"* ]] || [[ "$CLUSTER_ENDPOINT" == *"amazonaws"* ]]; then
  CLOUD_PROVIDER="aws"
else
  # Default to GCP if can't determine
  CLOUD_PROVIDER="gcp"
  echo "⚠️  Could not determine cloud provider, defaulting to GCP"
fi

echo "☁️  Cloud Provider: $CLOUD_PROVIDER"
echo ""

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

# Install Internal Ingress NGINX (internal-only load balancer)
echo "🌐 Installing Internal Ingress NGINX..."

if [ "$CLOUD_PROVIDER" = "gcp" ]; then
  # GCP: Use annotation for internal load balancer
  helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
    --namespace ingress-nginx \
    --set controller.service.type=LoadBalancer \
    --set controller.service.annotations."cloud\.google\.com/load-balancer-type"="Internal" \
    --set controller.admissionWebhooks.enabled=false \
    --wait
elif [ "$CLOUD_PROVIDER" = "aws" ]; then
  # AWS: Internal load balancer is created automatically when using private subnets
  # Add annotation to ensure it's internal
  helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
    --namespace ingress-nginx \
    --set controller.service.type=LoadBalancer \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-scheme"="internal" \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-type"="nlb" \
    --set controller.admissionWebhooks.enabled=false \
    --wait
else
  echo "❌ Unknown cloud provider: $CLOUD_PROVIDER"
  exit 1
fi

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

# Get internal ingress IP
echo ""
echo "🔍 Getting Internal Ingress IP..."
INGRESS_IP=$(kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "pending")
if [ "$INGRESS_IP" != "pending" ] && [ -n "$INGRESS_IP" ]; then
  echo "✅ Internal Ingress IP/Hostname: $INGRESS_IP"
  echo "   Note: This is only accessible from within the VPC"
else
  echo "⏳ Ingress IP is still being assigned. Check with:"
  echo "   kubectl get service ingress-nginx-controller -n ingress-nginx"
fi

echo ""
echo "✅ Deployment complete!"
echo ""
echo "Next steps:"
echo "1. Create an Ingress resource to expose Argo Workflows UI (internal only)"
echo "2. Submit a sample workflow: kubectl apply -f manifests/sample-workflow.yaml"
echo "3. Access the UI from within the VPC or via bastion port forwarding"

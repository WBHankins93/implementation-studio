#!/bin/bash
# Deploy Argo Workflows to the cluster (GCP or AWS)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🚀 Deploying Argo Workflows"
echo ""

cd "$LAB_DIR"

# Get cluster credentials based on provider
CLOUD_PROVIDER=$(grep -E '^cloud_provider\s*=' terraform.tfvars 2>/dev/null | sed 's/.*=\s*"\(.*\)".*/\1/' | tr -d ' ' || echo "gcp")

if [ "$CLOUD_PROVIDER" = "gcp" ]; then
  echo "☁️  Using GCP provider"
  
  CLUSTER_NAME=$(terraform output -raw gcp_cluster_name 2>/dev/null || terraform output -raw cluster_name)
  REGION=$(grep -E '^region\s*=' terraform.tfvars | sed 's/.*=\s*"\(.*\)".*/\1/' | tr -d ' ' || echo "us-central1")
  PROJECT_ID=$(grep -E '^project_id\s*=' terraform.tfvars | sed 's/.*=\s*"\(.*\)".*/\1/' | tr -d ' ' || echo "")
  
  if [ -z "$PROJECT_ID" ]; then
    echo "❌ Could not determine GCP project ID"
    echo "   Please set project_id in terraform.tfvars"
    exit 1
  fi
  
  echo "📋 Getting GKE cluster credentials..."
  gcloud container clusters get-credentials "$CLUSTER_NAME" \
    --region "$REGION" \
    --project "$PROJECT_ID"
    
elif [ "$CLOUD_PROVIDER" = "aws" ]; then
  echo "☁️  Using AWS provider"
  
  CLUSTER_NAME=$(terraform output -raw aws_cluster_name 2>/dev/null || terraform output -raw cluster_name)
  REGION=$(grep -E '^region\s*=' terraform.tfvars | sed 's/.*=\s*"\(.*\)".*/\1/' | tr -d ' ' || echo "us-west-2")
  
  echo "📋 Getting EKS cluster credentials..."
  aws eks update-kubeconfig \
    --region "$REGION" \
    --name "$CLUSTER_NAME"
else
  echo "❌ Unknown cloud provider: $CLOUD_PROVIDER"
  exit 1
fi

echo ""
echo "✅ Cluster credentials configured"
echo ""

# Verify cluster access
echo "🔍 Verifying cluster access..."
kubectl cluster-info
kubectl get nodes

echo ""
echo "📦 Installing Argo Workflows..."
echo ""

# Add Argo Helm repository
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Create argo namespace
kubectl create namespace argo --dry-run=client -o yaml | kubectl apply -f -

# Install Argo Workflows
helm upgrade --install argo-workflows argo/argo-workflows \
  --namespace argo \
  --set controller.service.type=ClusterIP \
  --set server.service.type=ClusterIP \
  --wait

echo ""
echo "📦 Installing Ingress NGINX..."
echo ""

# Add NGINX Helm repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install Ingress NGINX
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --wait

echo ""
echo "📝 Applying sample workflow..."
kubectl apply -f manifests/sample-workflow.yaml

echo ""
echo "✅ Argo Workflows deployed successfully!"
echo ""
echo "To access the Argo Workflows UI:"
echo "1. Port forward: kubectl port-forward -n argo svc/argo-workflows-server 2746:2746"
echo "2. Open: https://localhost:2746"
echo ""
echo "Or use Ingress (if configured):"
echo "  kubectl get ingress -n argo"

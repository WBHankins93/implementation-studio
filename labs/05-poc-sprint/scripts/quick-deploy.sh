#!/bin/bash
# Quick deployment script for POC - deploys minimal infrastructure and Argo Workflows

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DEPLOY_DIR="$LAB_DIR/minimal-deployment"

echo "🚀 Quick POC Deployment"
echo ""

# Check prerequisites
command -v terraform >/dev/null 2>&1 || { echo "❌ terraform is required" >&2; exit 1; }
command -v gcloud >/dev/null 2>&1 || { echo "❌ gcloud CLI is required" >&2; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required" >&2; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "❌ helm is required" >&2; exit 1; }

# Check for terraform.tfvars
if [ ! -f "$DEPLOY_DIR/terraform.tfvars" ]; then
  echo "⚠️  terraform.tfvars not found"
  echo "   Copy terraform.tfvars.example to terraform.tfvars and configure:"
  echo "   cd $DEPLOY_DIR"
  echo "   cp terraform.tfvars.example terraform.tfvars"
  exit 1
fi

cd "$DEPLOY_DIR"

# Initialize Terraform
echo "🔧 Initializing Terraform..."
terraform init

# Deploy infrastructure
echo "🏗️  Deploying infrastructure (this may take 5-10 minutes)..."
terraform apply -auto-approve

# Get cluster credentials
echo "🔐 Getting cluster credentials..."
CLUSTER_NAME=$(terraform output -raw cluster_name)
REGION=$(terraform output -raw region 2>/dev/null || grep -E '^region' terraform.tfvars | cut -d'"' -f2)
PROJECT_ID=$(grep -E '^project_id' terraform.tfvars | cut -d'"' -f2)

gcloud container clusters get-credentials "$CLUSTER_NAME" \
  --region "$REGION" \
  --project "$PROJECT_ID"

# Wait for cluster to be ready
echo "⏳ Waiting for cluster to be ready..."
kubectl wait --for=condition=ready node --all --timeout=300s || true

# Deploy Argo Workflows
echo "⚙️  Deploying Argo Workflows..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

kubectl create namespace argo --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install argo-workflows argo/argo-workflows \
  --namespace argo \
  --values "$LAB_DIR/../../modules/kubernetes/argo-workflows/helm-values.yaml" \
  --wait

# Deploy demo workflows
echo "📦 Deploying demo workflows..."
if [ -d "$LAB_DIR/manifests" ]; then
  kubectl apply -f "$LAB_DIR/manifests/" || true
fi

echo ""
echo "✅ POC deployment complete!"
echo ""
echo "Cluster: $CLUSTER_NAME"
echo "Region: $REGION"
echo ""
echo "Next steps:"
echo "1. Access Argo UI: kubectl port-forward -n argo svc/argo-workflows-server 2746:2746"
echo "2. Open: http://localhost:2746"
echo "3. Review demo workflows in manifests/"
echo "4. Prepare demo: ./scripts/prepare-demo.sh"


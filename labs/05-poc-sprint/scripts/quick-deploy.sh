#!/bin/bash
# Quick deployment script for POC - supports Kind, GCP, and AWS
# For fastest POC (zero cost), use Kind directly - no Terraform needed

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DEPLOY_DIR="$LAB_DIR/minimal-deployment"

echo "🚀 Quick POC Deployment"
echo ""
echo "Options:"
echo "1. Kind (local, zero cost, fastest) - Recommended for POC"
echo "2. GCP (cloud, minimal cost, ~5-10 min)"
echo "3. AWS (cloud, minimal cost, ~10-15 min)"
echo ""

# Check for deployment method
if [ -f "$DEPLOY_DIR/terraform.tfvars" ]; then
  CLOUD_PROVIDER=$(grep -E '^cloud_provider\s*=' "$DEPLOY_DIR/terraform.tfvars" | sed 's/.*=\s*"\(.*\)".*/\1/' | tr -d ' ' || echo "gcp")
  USE_TERRAFORM=true
else
  echo "⚠️  No terraform.tfvars found"
  echo ""
  read -p "Deploy with Kind (local, zero cost)? [Y/n]: " -r
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "Please create terraform.tfvars for cloud deployment:"
    echo "  cd $DEPLOY_DIR"
    echo "  cp terraform.tfvars.example terraform.tfvars"
    echo "  # Edit terraform.tfvars with your cloud provider settings"
    exit 1
  else
    USE_TERRAFORM=false
    CLOUD_PROVIDER="kind"
  fi
fi

# Option 1: Kind (local, zero cost)
if [ "$USE_TERRAFORM" = false ] || [ "$CLOUD_PROVIDER" = "kind" ]; then
  echo "🐳 Deploying with Kind (local, zero cost)..."
  
  command -v kind >/dev/null 2>&1 || { echo "❌ kind is required. Install: brew install kind" >&2; exit 1; }
  command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required" >&2; exit 1; }
  command -v helm >/dev/null 2>&1 || { echo "❌ helm is required" >&2; exit 1; }
  
  CLUSTER_NAME="poc-cluster"
  
  # Check if cluster exists
  if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
    echo "⚠️  Cluster $CLUSTER_NAME already exists. Using existing cluster."
  else
    echo "📦 Creating Kind cluster..."
    kind create cluster --name "$CLUSTER_NAME" --wait 5m
  fi
  
  # Set kubeconfig
  export KUBECONFIG=$(kind get kubeconfig-path --name "$CLUSTER_NAME" 2>/dev/null || kind get kubeconfig --name "$CLUSTER_NAME" > /tmp/kind-kubeconfig && echo "/tmp/kind-kubeconfig")
  kubectl config use-context "kind-${CLUSTER_NAME}"
  
  echo "✅ Kind cluster ready"
  
else
  # Option 2 & 3: Cloud deployment (GCP or AWS)
  echo "☁️  Deploying with $CLOUD_PROVIDER..."
  
  # Check prerequisites
  command -v terraform >/dev/null 2>&1 || { echo "❌ terraform is required" >&2; exit 1; }
  command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required" >&2; exit 1; }
  command -v helm >/dev/null 2>&1 || { echo "❌ helm is required" >&2; exit 1; }
  
  if [ "$CLOUD_PROVIDER" = "gcp" ]; then
    command -v gcloud >/dev/null 2>&1 || { echo "❌ gcloud CLI is required" >&2; exit 1; }
  elif [ "$CLOUD_PROVIDER" = "aws" ]; then
    command -v aws >/dev/null 2>&1 || { echo "❌ aws CLI is required" >&2; exit 1; }
  fi
  
  cd "$DEPLOY_DIR"
  
  # Initialize Terraform
  echo "🔧 Initializing Terraform..."
  terraform init
  
  # Deploy infrastructure
  echo "🏗️  Deploying infrastructure (this may take 5-15 minutes)..."
  terraform apply -auto-approve
  
  # Get cluster credentials
  echo "🔐 Getting cluster credentials..."
  GET_CREDS_CMD=$(terraform output -raw get_credentials_command)
  eval "$GET_CREDS_CMD"
  
  CLUSTER_NAME=$(terraform output -raw cluster_name)
  
  echo "✅ Cloud cluster ready"
fi

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
if [ "$USE_TERRAFORM" = true ]; then
  REGION=$(terraform output -raw region 2>/dev/null || echo "N/A")
  echo "Provider: $CLOUD_PROVIDER"
  echo "Region: $REGION"
else
  echo "Provider: Kind (local)"
fi
echo ""
echo "Next steps:"
echo "1. Access Argo UI: kubectl port-forward -n argo svc/argo-workflows-server 2746:2746"
echo "2. Open: http://localhost:2746"
echo "3. Review demo workflows in manifests/"
echo "4. Prepare demo: ./scripts/prepare-demo.sh"
echo ""
if [ "$USE_TERRAFORM" = true ]; then
  echo "To clean up:"
  echo "  cd $DEPLOY_DIR"
  echo "  terraform destroy"
else
  echo "To clean up:"
  echo "  kind delete cluster --name $CLUSTER_NAME"
fi

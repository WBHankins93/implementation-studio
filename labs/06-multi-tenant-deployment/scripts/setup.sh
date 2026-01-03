#!/bin/bash
# Setup script for Lab 06: Multi-Tenant Deployment (Kind, GCP, or AWS)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🚀 Setting up Lab 06: Multi-Tenant Deployment"
echo ""

# Check prerequisites
echo "📋 Checking prerequisites..."

command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required but not installed." >&2; exit 1; }

# Detect cloud provider from terraform.tfvars or use default
CLOUD_PROVIDER="kind"
if [ -f "$LAB_DIR/terraform.tfvars" ]; then
  CLOUD_PROVIDER=$(grep -E '^cloud_provider\s*=' "$LAB_DIR/terraform.tfvars" | sed 's/.*=\s*"\(.*\)".*/\1/' | tr -d ' ' || echo "kind")
fi

echo "☁️  Cloud Provider: $CLOUD_PROVIDER"
echo ""

# Provider-specific prerequisites
if [ "$CLOUD_PROVIDER" = "gcp" ]; then
  command -v terraform >/dev/null 2>&1 || { echo "❌ terraform is required for GCP deployment" >&2; exit 1; }
  command -v gcloud >/dev/null 2>&1 || { echo "❌ gcloud CLI is required for GCP deployment" >&2; exit 1; }
  echo "✅ GCP prerequisites met"
elif [ "$CLOUD_PROVIDER" = "aws" ]; then
  command -v terraform >/dev/null 2>&1 || { echo "❌ terraform is required for AWS deployment" >&2; exit 1; }
  command -v aws >/dev/null 2>&1 || { echo "❌ aws CLI is required for AWS deployment" >&2; exit 1; }
  echo "✅ AWS prerequisites met"
elif [ "$CLOUD_PROVIDER" = "kind" ]; then
  command -v kind >/dev/null 2>&1 || { echo "❌ kind is required for local deployment" >&2; exit 1; }
  echo "✅ Kind prerequisites met"
else
  echo "⚠️  Unknown cloud provider: $CLOUD_PROVIDER (assuming Kind)"
  command -v kind >/dev/null 2>&1 || { echo "❌ kind is required for local deployment" >&2; exit 1; }
fi

echo "✅ All prerequisites met"
echo ""

# Setup cluster based on provider
if [ "$CLOUD_PROVIDER" = "kind" ]; then
  echo "🐳 Setting up Kind cluster..."
  CLUSTER_NAME=$(grep -E '^cluster_name\s*=' "$LAB_DIR/terraform.tfvars" 2>/dev/null | cut -d'=' -f2 | tr -d ' "' || echo "multi-tenant-cluster")
  
  if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
    echo "✅ Kind cluster '$CLUSTER_NAME' already exists"
  else
    echo "Creating Kind cluster..."
    kind create cluster --name "$CLUSTER_NAME" --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  disableDefaultCNI: false
nodes:
- role: control-plane
- role: worker
EOF
    echo "✅ Kind cluster created"
  fi
  
  # Set kubectl context
  kubectl config use-context "kind-${CLUSTER_NAME}"
  
  echo ""
  echo "✅ Setup complete!"
  echo ""
  echo "Next steps:"
  echo "1. Create shared services: kubectl apply -f manifests/shared-services/"
  echo "2. Create tenants: ./tenant-onboarding/create-tenant.sh tenant-a standard"
  echo "3. Validate: ./scripts/validate.sh"
  
elif [ "$CLOUD_PROVIDER" = "gcp" ] || [ "$CLOUD_PROVIDER" = "aws" ]; then
  echo "☁️  Setting up $CLOUD_PROVIDER cluster..."
  cd "$LAB_DIR"
  
  # Check for terraform.tfvars
  if [ ! -f "$LAB_DIR/terraform.tfvars" ]; then
    echo "⚠️  terraform.tfvars not found"
    echo "   Copy terraform.tfvars.example to terraform.tfvars and configure:"
    echo "   cp terraform.tfvars.example terraform.tfvars"
    echo ""
    read -p "Continue anyway? (y/N): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      exit 1
    fi
  fi
  
  terraform init
  echo ""
  echo "✅ Setup complete!"
  echo ""
  echo "Next steps:"
  echo "1. Review terraform.tfvars"
  echo "2. Run: terraform plan"
  echo "3. Run: terraform apply"
  echo "4. Get credentials: terraform output get_credentials_command"
  echo "5. Create shared services: kubectl apply -f manifests/shared-services/"
  echo "6. Create tenants: ./tenant-onboarding/create-tenant.sh tenant-a standard"
  echo "7. Validate: ./scripts/validate.sh"
fi

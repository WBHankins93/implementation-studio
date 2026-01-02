#!/bin/bash
# Setup script for Lab 06: Multi-Tenant Deployment

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🚀 Setting up Lab 06: Multi-Tenant Deployment"
echo ""

# Check prerequisites
echo "📋 Checking prerequisites..."

command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required but not installed." >&2; exit 1; }

if [ -f "$LAB_DIR/terraform.tfvars" ]; then
  USE_GCP=$(grep -E '^use_gcp\s*=' "$LAB_DIR/terraform.tfvars" | cut -d'=' -f2 | tr -d ' "' || echo "false")
  
  if [ "$USE_GCP" = "true" ]; then
    command -v terraform >/dev/null 2>&1 || { echo "❌ terraform is required for GCP deployment" >&2; exit 1; }
    command -v gcloud >/dev/null 2>&1 || { echo "❌ gcloud CLI is required for GCP deployment" >&2; exit 1; }
    command -v helm >/dev/null 2>&1 || { echo "❌ helm is required" >&2; exit 1; }
  else
    command -v kind >/dev/null 2>&1 || { echo "❌ kind is required for local deployment" >&2; exit 1; }
  fi
else
  echo "⚠️  terraform.tfvars not found, assuming Kind deployment"
  command -v kind >/dev/null 2>&1 || { echo "❌ kind is required for local deployment" >&2; exit 1; }
fi

echo "✅ All prerequisites met"
echo ""

# Setup cluster
if [ -f "$LAB_DIR/terraform.tfvars" ]; then
  USE_GCP=$(grep -E '^use_gcp\s*=' "$LAB_DIR/terraform.tfvars" | cut -d'=' -f2 | tr -d ' "' || echo "false")
else
  USE_GCP="false"
fi

if [ "$USE_GCP" = "true" ]; then
  echo "☁️  Setting up GCP cluster..."
  cd "$LAB_DIR"
  terraform init
  echo ""
  echo "Next steps:"
  echo "1. Review terraform.tfvars"
  echo "2. Run: terraform plan"
  echo "3. Run: terraform apply"
  echo "4. Get credentials: terraform output get_credentials_command"
else
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
  echo "2. Create tenants: ./tenant-onboarding/create-tenant.sh tenant-a"
  echo "3. Validate: ./scripts/validate.sh"
fi


#!/bin/bash
# Setup script for Lab 03: Private Network Deployment (GCP or AWS)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🚀 Setting up Lab 03: Private Network Deployment"
echo ""

# Check prerequisites
echo "📋 Checking prerequisites..."

command -v terraform >/dev/null 2>&1 || { echo "❌ terraform is required but not installed." >&2; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required but not installed." >&2; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "❌ helm is required but not installed." >&2; exit 1; }

# Detect cloud provider from terraform.tfvars or use default
CLOUD_PROVIDER="gcp"
if [ -f "$LAB_DIR/terraform.tfvars" ]; then
  CLOUD_PROVIDER=$(grep -E '^cloud_provider\s*=' "$LAB_DIR/terraform.tfvars" | sed 's/.*=\s*"\(.*\)".*/\1/' | tr -d ' ' || echo "gcp")
fi

echo "☁️  Cloud Provider: $CLOUD_PROVIDER"
echo ""

# Provider-specific prerequisites
if [ "$CLOUD_PROVIDER" = "gcp" ]; then
  command -v gcloud >/dev/null 2>&1 || { echo "❌ gcloud CLI is required for GCP deployment" >&2; exit 1; }
  echo "✅ GCP prerequisites met"
elif [ "$CLOUD_PROVIDER" = "aws" ]; then
  command -v aws >/dev/null 2>&1 || { echo "❌ aws CLI is required for AWS deployment" >&2; exit 1; }
  echo "✅ AWS prerequisites met"
else
  echo "⚠️  Unknown cloud provider: $CLOUD_PROVIDER (assuming GCP)"
  command -v gcloud >/dev/null 2>&1 || { echo "❌ gcloud CLI is required for GCP deployment" >&2; exit 1; }
fi

echo "✅ All prerequisites met"
echo ""

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

# Initialize Terraform
echo "🔧 Initializing Terraform..."
cd "$LAB_DIR"
terraform init

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Review and update terraform.tfvars if needed"
echo "2. Run: terraform plan"
echo "3. Run: terraform apply"
echo "4. After apply, access bastion: ./scripts/bastion-access.sh"
echo "5. From bastion, run: ./scripts/deploy-argo.sh"

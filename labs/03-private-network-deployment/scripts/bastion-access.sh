#!/bin/bash
# Access bastion host and configure kubectl for private cluster

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🔐 Accessing Bastion Host"
echo ""

# Check if terraform outputs are available
if [ ! -f "$LAB_DIR/terraform.tfstate" ]; then
  echo "❌ Terraform state not found. Run 'terraform apply' first."
  exit 1
fi

# Get bastion details from Terraform output
cd "$LAB_DIR"
BASTION_NAME=$(terraform output -raw bastion_name 2>/dev/null || echo "")
BASTION_ZONE=$(terraform output -raw bastion_zone 2>/dev/null || echo "")
PROJECT_ID=$(grep -E '^project_id\s*=' terraform.tfvars 2>/dev/null | sed 's/.*= *"\(.*\)".*/\1/' | head -1 || gcloud config get-value project 2>/dev/null || echo "")

if [ -z "$BASTION_NAME" ] || [ -z "$BASTION_ZONE" ]; then
  echo "❌ Could not get bastion details from Terraform output"
  echo "   Make sure terraform apply completed successfully"
  exit 1
fi

if [ -z "$PROJECT_ID" ]; then
  echo "⚠️  Could not determine project ID. Please set it manually:"
  read -p "Enter GCP project ID: " PROJECT_ID
fi

echo "📋 Bastion Details:"
echo "   Name: $BASTION_NAME"
echo "   Zone: $BASTION_ZONE"
echo "   Project: $PROJECT_ID"
echo ""

# Get SSH command
SSH_CMD="gcloud compute ssh $BASTION_NAME --zone $BASTION_ZONE --project $PROJECT_ID"

echo "🔗 SSH Command:"
echo "   $SSH_CMD"
echo ""

# Check if user wants to SSH now
read -p "SSH to bastion now? (y/N): " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo ""
  echo "🚀 Connecting to bastion..."
  echo "   Once connected, you can:"
  echo "   1. Get cluster credentials: gcloud container clusters get-credentials <cluster-name> --region <region> --project $PROJECT_ID --internal-ip"
  echo "   2. Deploy Argo Workflows: ./scripts/deploy-argo.sh"
  echo ""
  exec $SSH_CMD
else
  echo ""
  echo "To connect later, run:"
  echo "   $SSH_CMD"
fi


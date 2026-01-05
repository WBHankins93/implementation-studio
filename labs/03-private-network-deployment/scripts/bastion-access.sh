#!/bin/bash
# Access bastion host and configure kubectl for private cluster (GCP or AWS)

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

# Detect cloud provider
cd "$LAB_DIR"
CLOUD_PROVIDER=$(grep -E '^cloud_provider\s*=' terraform.tfvars 2>/dev/null | sed 's/.*=\s*"\(.*\)".*/\1/' | tr -d ' ' || echo "gcp")

if [ "$CLOUD_PROVIDER" = "gcp" ]; then
  # GCP Bastion Access
  BASTION_NAME=$(terraform output -raw gcp_bastion_name 2>/dev/null || echo "")
  BASTION_ZONE=$(terraform output -raw gcp_bastion_zone 2>/dev/null || echo "")
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
    echo "   1. Get cluster credentials: terraform output get_credentials_command"
    echo "   2. Deploy Argo Workflows: ./scripts/deploy-argo.sh"
    echo ""
    exec $SSH_CMD
  else
    echo ""
    echo "To connect later, run:"
    echo "   $SSH_CMD"
  fi

elif [ "$CLOUD_PROVIDER" = "aws" ]; then
  # AWS Bastion Access
  BASTION_IP=$(terraform output -raw aws_bastion_public_ip 2>/dev/null || echo "")

  if [ -z "$BASTION_IP" ]; then
    echo "❌ Could not get bastion IP from Terraform output"
    echo "   Make sure terraform apply completed successfully"
    exit 1
  fi

  echo "📋 Bastion Details:"
  echo "   Public IP: $BASTION_IP"
  echo ""

  # Check for SSH key
  SSH_KEY="${HOME}/.ssh/id_rsa"
  if [ ! -f "$SSH_KEY" ]; then
    echo "⚠️  SSH key not found at $SSH_KEY"
    echo "   You'll need to:"
    echo "   1. Create an SSH key pair: ssh-keygen -t rsa -b 4096"
    echo "   2. Add the public key to the bastion instance"
    echo "   Or use AWS Systems Manager Session Manager (recommended for production)"
    echo ""
    read -p "Continue anyway? (y/N): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      exit 1
    fi
  fi

  # Get SSH command
  SSH_CMD="ssh -i $SSH_KEY ec2-user@$BASTION_IP"

  echo "🔗 SSH Command:"
  echo "   $SSH_CMD"
  echo ""
  echo "⚠️  Note: For production, consider using AWS Systems Manager Session Manager"
  echo "   This avoids exposing SSH and doesn't require managing SSH keys"
  echo ""

  # Check if user wants to SSH now
  read -p "SSH to bastion now? (y/N): " -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "🚀 Connecting to bastion..."
    echo "   Once connected, you can:"
    echo "   1. Get cluster credentials: terraform output get_credentials_command"
    echo "   2. Deploy Argo Workflows: ./scripts/deploy-argo.sh"
    echo ""
    exec $SSH_CMD
  else
    echo ""
    echo "To connect later, run:"
    echo "   $SSH_CMD"
    echo ""
    echo "Or use AWS Systems Manager Session Manager:"
    echo "   aws ssm start-session --target <instance-id>"
  fi

else
  echo "❌ Unknown cloud provider: $CLOUD_PROVIDER"
  exit 1
fi

#!/bin/bash
# Cleanup script for Lab 03: Private Network Deployment

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🧹 Cleaning up Lab 03: Private Network Deployment"
echo ""

# Confirm deletion
echo "⚠️  This will destroy all resources created by this lab."
echo "   This includes:"
echo "   - Private GKE cluster"
echo "   - Private VPC network"
echo "   - Bastion host"
echo "   - Artifact Registry"
echo "   - All associated resources"
echo ""
read -p "Are you sure you want to continue? (yes/N): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
  echo "Cancelled."
  exit 0
fi

# Change to lab directory
cd "$LAB_DIR"

# Destroy Terraform resources
echo "🗑️  Destroying Terraform resources..."
terraform destroy -auto-approve

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "All resources have been destroyed."


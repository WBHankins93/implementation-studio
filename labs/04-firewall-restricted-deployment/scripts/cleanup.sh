#!/bin/bash
# Cleanup script for Lab 04: Firewall-Restricted Deployment

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🧹 Cleaning up Lab 04: Firewall-Restricted Deployment"
echo ""

# Confirm deletion
echo "⚠️  This will destroy all resources created by this lab."
echo "   This includes:"
echo "   - GKE cluster"
echo "   - VPC network"
echo "   - Proxy server"
echo "   - Firewall rules"
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


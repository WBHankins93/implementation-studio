#!/bin/bash
# Cleanup script for POC - destroys all resources

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DEPLOY_DIR="$LAB_DIR/minimal-deployment"

echo "🧹 Cleaning up POC deployment"
echo ""

# Confirm deletion
echo "⚠️  This will destroy all POC resources."
echo "   This includes:"
echo "   - GKE cluster"
echo "   - VPC network"
echo "   - All associated resources"
echo ""
read -p "Are you sure you want to continue? (yes/N): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
  echo "Cancelled."
  exit 0
fi

# Change to deployment directory
cd "$DEPLOY_DIR"

# Destroy Terraform resources
echo "🗑️  Destroying Terraform resources..."
terraform destroy -auto-approve

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "All POC resources have been destroyed."


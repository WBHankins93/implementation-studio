#!/bin/bash
# Cleanup script for Lab 07: Integration Patterns

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🧹 Cleaning up Lab 07: Integration Patterns"
echo ""

# Confirm deletion
echo "⚠️  This will destroy all resources created by this lab."
echo "   This includes:"
echo "   - GKE cluster"
echo "   - VPC network"
echo "   - Cloud SQL instance (if created)"
echo "   - All integration deployments"
echo ""
read -p "Are you sure you want to continue? (yes/N): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
  echo "Cancelled."
  exit 0
fi

# Delete integration deployments
echo "🗑️  Deleting integration deployments..."
kubectl delete namespace oauth-proxy --wait=false || true
kubectl delete namespace database --wait=false || true
kubectl delete namespace kong --wait=false || true

# Destroy Terraform resources
echo "🗑️  Destroying Terraform resources..."
cd "$LAB_DIR"
terraform destroy -auto-approve

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "All resources have been destroyed."


#!/bin/bash
# Cleanup script for Lab 01

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🧹 Cleaning up Lab 01 resources"
echo ""

# Confirm
read -p "This will destroy all Terraform resources. Continue? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
  echo "Aborted."
  exit 0
fi

# Remove Kubernetes resources
if kubectl cluster-info &>/dev/null; then
  echo "🗑️  Removing Kubernetes resources..."
  kubectl delete namespace argo --ignore-not-found=true
  kubectl delete namespace ingress-nginx --ignore-not-found=true
fi

# Destroy Terraform resources
echo "🗑️  Destroying Terraform resources..."
cd "$LAB_DIR"
terraform destroy -auto-approve

echo ""
echo "✅ Cleanup complete!"


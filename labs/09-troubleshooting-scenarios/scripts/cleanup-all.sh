#!/bin/bash
# Cleanup All Scenarios

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🧹 Cleaning up All Troubleshooting Scenarios"
echo ""

# Confirm deletion
echo "⚠️  This will delete all test namespaces and resources."
echo ""
read -p "Are you sure you want to continue? (yes/N): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
  echo "Cancelled."
  exit 0
fi

# Delete test namespaces
echo "🗑️  Deleting test namespaces..."
kubectl delete namespace network-test --ignore-not-found=true
kubectl delete namespace resource-test --ignore-not-found=true
kubectl delete namespace permission-test --ignore-not-found=true
kubectl delete namespace image-test --ignore-not-found=true
kubectl delete namespace dns-test --ignore-not-found=true
kubectl delete namespace cert-test --ignore-not-found=true

# Option to delete cluster
echo ""
read -p "Delete Kind cluster? (yes/N): " -r
if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
  echo "🗑️  Deleting Kind cluster..."
  kind delete cluster --name troubleshooting-lab 2>/dev/null || echo "  Cluster not found or already deleted"
fi

echo ""
echo "✅ Cleanup complete!"


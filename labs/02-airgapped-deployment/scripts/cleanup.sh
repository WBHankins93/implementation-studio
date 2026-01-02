#!/bin/bash
# Cleanup script for Lab 02

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CLUSTER_NAME="${CLUSTER_NAME:-airgap-simulation}"

echo "🧹 Cleaning up Lab 02 resources"
echo ""

# Confirm
read -p "This will delete the Kind cluster and all resources. Continue? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
  echo "Aborted."
  exit 0
fi

# Delete Kind cluster
if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
  echo "🗑️  Deleting Kind cluster..."
  kind delete cluster --name "$CLUSTER_NAME"
fi

# Clean up preparation artifacts (optional)
read -p "Delete preparation artifacts (images, charts, bundles)? (y/N): " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "🗑️  Cleaning up preparation artifacts..."
  rm -rf "$LAB_DIR/preparation/images"
  rm -rf "$LAB_DIR/preparation/charts"
  rm -rf "$LAB_DIR/preparation/airgap-deployment-bundle-*"
fi

echo ""
echo "✅ Cleanup complete!"


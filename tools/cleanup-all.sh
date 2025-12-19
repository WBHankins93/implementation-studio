#!/bin/bash
# Emergency cleanup script - removes all resources

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "⚠️  WARNING: This will attempt to clean up all resources!"
echo "   This includes:"
echo "   - Kind clusters"
echo "   - Terraform state (local)"
echo "   - Temporary files"
echo ""
read -p "Are you sure you want to continue? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
  echo "Aborted."
  exit 0
fi

# Cleanup Kind clusters
echo "🧹 Cleaning up Kind clusters..."
for cluster in $(kind get clusters 2>/dev/null || true); do
  if [[ "$cluster" == *"implementation-studio"* ]] || [[ "$cluster" == *"airgap"* ]]; then
    echo "  Deleting cluster: $cluster"
    kind delete cluster --name "$cluster" || true
  fi
done

# Cleanup Terraform
echo "🧹 Cleaning up Terraform state..."
find "$PROJECT_ROOT" -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
find "$PROJECT_ROOT" -name "*.tfstate" -delete 2>/dev/null || true
find "$PROJECT_ROOT" -name "*.tfstate.*" -delete 2>/dev/null || true

# Cleanup temporary files
echo "🧹 Cleaning up temporary files..."
find "$PROJECT_ROOT" -type f -name "*.tmp" -delete 2>/dev/null || true
find "$PROJECT_ROOT" -type f -name "*.log" -delete 2>/dev/null || true

echo "✅ Cleanup complete!"


#!/bin/bash
# Package Helm charts for offline installation

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="${OUTPUT_DIR:-$SCRIPT_DIR/charts}"

echo "📦 Packaging Helm charts for offline installation"
echo ""

# Check prerequisites
command -v helm >/dev/null 2>&1 || { echo "❌ helm is required but not installed." >&2; exit 1; }

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Add Helm repositories
echo "📥 Adding Helm repositories..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Package Argo Workflows chart
echo "📦 Packaging Argo Workflows chart..."
CHART_VERSION=$(helm search repo argo/argo-workflows --versions | head -2 | tail -1 | awk '{print $2}')
echo "    Version: $CHART_VERSION"

if helm pull argo/argo-workflows --version "$CHART_VERSION" --destination "$OUTPUT_DIR"; then
  echo "    ✅ Chart packaged successfully"
else
  echo "    ❌ Failed to package chart"
  exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Helm chart packaging complete!"
echo ""
echo "Charts saved to: $OUTPUT_DIR"
echo ""
echo "Next steps:"
echo "1. Verify charts: ls -lh $OUTPUT_DIR"
echo "2. Create deployment bundle: ./create-bundle.sh"


#!/bin/bash
# Package Helm charts for offline installation
# This script downloads and packages all required Helm charts for air-gapped deployment

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${OUTPUT_DIR:-$SCRIPT_DIR/charts}"

echo "📦 Packaging Helm charts for offline installation"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Add Helm repositories
echo "📥 Adding Helm repositories..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Package Argo Workflows chart
echo "📦 Packaging Argo Workflows chart..."
CHART_VERSION=$(helm search repo argo/argo-workflows --versions | head -2 | tail -1 | awk '{print $2}')
helm pull argo/argo-workflows --version "$CHART_VERSION" --destination "$OUTPUT_DIR"

echo ""
echo "✅ Charts packaged successfully!"
echo ""
echo "Charts saved to: $OUTPUT_DIR"
echo ""
echo "To use these charts offline:"
echo "1. Transfer the charts directory to your air-gapped environment"
echo "2. Install using: helm install argo-workflows ./charts/argo-workflows-*.tgz"
echo "3. Or use with: helm install argo-workflows ./charts/argo-workflows-*.tgz -f values.yaml"


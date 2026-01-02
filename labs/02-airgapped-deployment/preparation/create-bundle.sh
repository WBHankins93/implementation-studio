#!/bin/bash
# Create complete deployment bundle for air-gapped environment
# This script packages all required files into a single bundle

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
BUNDLE_NAME="${BUNDLE_NAME:-airgap-deployment-bundle-$(date +%Y%m%d-%H%M%S)}"
BUNDLE_DIR="$SCRIPT_DIR/$BUNDLE_NAME"

echo "📦 Creating deployment bundle for air-gapped environment"
echo ""
echo "Bundle name: $BUNDLE_NAME"
echo ""

# Check that required directories exist
if [ ! -d "$SCRIPT_DIR/images" ]; then
  echo "❌ Images directory not found. Run mirror-images.sh first."
  exit 1
fi

if [ ! -d "$SCRIPT_DIR/charts" ]; then
  echo "❌ Charts directory not found. Run package-helm.sh first."
  exit 1
fi

# Create bundle directory structure
echo "📁 Creating bundle structure..."
mkdir -p "$BUNDLE_DIR"/{images,charts,manifests,scripts,docs}

# Copy images
echo "📋 Copying images..."
cp -r "$SCRIPT_DIR/images"/* "$BUNDLE_DIR/images/" 2>/dev/null || true
IMAGE_COUNT=$(find "$BUNDLE_DIR/images" -name "*.tar" 2>/dev/null | wc -l | xargs)
echo "    ✅ Copied $IMAGE_COUNT image files"

# Copy charts
echo "📋 Copying Helm charts..."
cp -r "$SCRIPT_DIR/charts"/* "$BUNDLE_DIR/charts/" 2>/dev/null || true
CHART_COUNT=$(find "$BUNDLE_DIR/charts" -name "*.tgz" 2>/dev/null | wc -l | xargs)
echo "    ✅ Copied $CHART_COUNT chart files"

# Copy deployment scripts
echo "📋 Copying deployment scripts..."
cp "$LAB_DIR/02-airgapped-deployment/deployment"/*.sh "$BUNDLE_DIR/scripts/" 2>/dev/null || true
cp "$LAB_DIR/02-airgapped-deployment/manifests"/*.yaml "$BUNDLE_DIR/manifests/" 2>/dev/null || true

# Copy Helm values
echo "📋 Copying Helm values..."
cp "$LAB_DIR/../../modules/kubernetes/argo-workflows-airgap/helm-values.yaml" "$BUNDLE_DIR/charts/argo-workflows-values.yaml" 2>/dev/null || true

# Create README for bundle
cat > "$BUNDLE_DIR/README.md" << 'EOF'
# Air-Gapped Deployment Bundle

This bundle contains everything needed to deploy Argo Workflows in an air-gapped environment.

## Contents

- `images/` - Container images as tar files
- `charts/` - Packaged Helm charts
- `manifests/` - Kubernetes manifests
- `scripts/` - Deployment scripts
- `README.md` - This file

## Transfer Instructions

1. **USB Drive:**
   - Copy entire bundle directory to USB drive
   - Transfer to air-gapped environment
   - Extract if compressed

2. **Network Transfer (if available):**
   - Use secure file transfer (SCP, SFTP)
   - Verify file integrity after transfer
   - Use checksums to ensure completeness

3. **Physical Media:**
   - Burn to DVD/Blu-ray if very large
   - Use multiple media if needed
   - Label clearly with bundle name and date

## Deployment

Once transferred to air-gapped environment:

1. Extract bundle (if compressed)
2. Follow deployment instructions in deployment/README.md
3. Run scripts in order:
   - load-images.sh
   - deploy-registry.sh
   - deploy-argo.sh
   - validate.sh

## Bundle Information

- Created: $(date)
- Images: See images/ directory
- Charts: See charts/ directory
EOF

# Create checksum file
echo "🔐 Creating checksums..."
find "$BUNDLE_DIR" -type f -exec sha256sum {} \; > "$BUNDLE_DIR/checksums.txt"
echo "    ✅ Checksums saved to checksums.txt"

# Calculate total size
TOTAL_SIZE=$(du -sh "$BUNDLE_DIR" | cut -f1)
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Bundle created successfully!"
echo ""
echo "Bundle location: $BUNDLE_DIR"
echo "Total size: $TOTAL_SIZE"
echo "Images: $IMAGE_COUNT"
echo "Charts: $CHART_COUNT"
echo ""
echo "Next steps:"
echo "1. Review bundle contents: ls -lh $BUNDLE_DIR"
echo "2. Verify checksums: sha256sum -c $BUNDLE_DIR/checksums.txt"
echo "3. Transfer bundle to air-gapped environment"
echo ""
echo "Transfer methods:"
echo "  - USB drive: Copy $BUNDLE_DIR to USB"
echo "  - Network: Use SCP/SFTP to transfer"
echo "  - Physical media: Burn to DVD/Blu-ray if very large"


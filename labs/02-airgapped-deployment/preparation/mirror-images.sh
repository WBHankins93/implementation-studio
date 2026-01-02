#!/bin/bash
# Mirror container images for air-gapped deployment
# This script pulls all required images and saves them as tar files

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
IMAGES_FILE="${IMAGES_FILE:-$LAB_DIR/../../modules/kubernetes/argo-workflows-airgap/images.txt}"
OUTPUT_DIR="${OUTPUT_DIR:-$SCRIPT_DIR/images}"

echo "🖼️  Mirroring container images for air-gapped deployment"
echo ""
echo "Images file: $IMAGES_FILE"
echo "Output directory: $OUTPUT_DIR"
echo ""

# Check prerequisites
command -v docker >/dev/null 2>&1 || { echo "❌ docker is required but not installed." >&2; exit 1; }

# Check if images file exists
if [ ! -f "$IMAGES_FILE" ]; then
  echo "❌ Images file not found: $IMAGES_FILE"
  exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Counter for tracking progress
TOTAL=0
PULLED=0
SKIPPED=0

echo "📥 Pulling and saving images..."
echo ""

# Read images file and process each line
while IFS= read -r line || [ -n "$line" ]; do
  # Skip empty lines and comments
  [[ -z "$line" ]] && continue
  [[ "$line" =~ ^[[:space:]]*# ]] && continue
  
  # Remove leading/trailing whitespace
  image=$(echo "$line" | xargs)
  
  # Skip if empty after trimming
  [[ -z "$image" ]] && continue
  
  TOTAL=$((TOTAL + 1))
  
  echo "[$TOTAL] Processing: $image"
  
  # Check if image already exists locally
  if docker image inspect "$image" &>/dev/null; then
    echo "    ℹ️  Image already exists locally"
  else
    echo "    📥 Pulling image..."
    if docker pull "$image"; then
      PULLED=$((PULLED + 1))
    else
      echo "    ❌ Failed to pull: $image"
      continue
    fi
  fi
  
  # Create safe filename (replace / and : with _)
  safe_name=$(echo "$image" | sed 's/[\/:]/_/g')
  output_file="$OUTPUT_DIR/${safe_name}.tar"
  
  # Save image
  echo "    💾 Saving to: $output_file"
  if docker save "$image" -o "$output_file"; then
    echo "    ✅ Saved successfully"
  else
    echo "    ❌ Failed to save: $image"
    continue
  fi
  
  echo ""
done < "$IMAGES_FILE"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Image mirroring complete!"
echo ""
echo "Summary:"
echo "  Total images: $TOTAL"
echo "  Pulled: $PULLED"
echo "  Saved to: $OUTPUT_DIR"
echo ""
echo "Next steps:"
echo "1. Verify images: ls -lh $OUTPUT_DIR"
echo "2. Create deployment bundle: ./create-bundle.sh"
echo "3. Transfer bundle to air-gapped environment"


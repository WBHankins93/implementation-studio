#!/bin/bash
# Load container images into local registry
# This script loads images from tar files and pushes them to the local registry

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
IMAGES_DIR="${IMAGES_DIR:-$LAB_DIR/preparation/images}"
REGISTRY="${REGISTRY:-local-registry.registry.svc.cluster.local:5000}"

echo "📥 Loading container images into local registry"
echo ""
echo "Images directory: $IMAGES_DIR"
echo "Registry: $REGISTRY"
echo ""

# Check prerequisites
command -v docker >/dev/null 2>&1 || { echo "❌ docker is required but not installed." >&2; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required but not installed." >&2; exit 1; }

# Check if images directory exists
if [ ! -d "$IMAGES_DIR" ]; then
  echo "❌ Images directory not found: $IMAGES_DIR"
  echo "   Make sure you've transferred the deployment bundle"
  exit 1
fi

# Check if registry is accessible
echo "🔍 Checking registry accessibility..."
if ! kubectl get svc local-registry -n registry &>/dev/null; then
  echo "⚠️  Registry service not found. Deploying registry..."
  kubectl apply -f "$LAB_DIR/02-airgapped-deployment/manifests/registry.yaml"
  echo "⏳ Waiting for registry to be ready..."
  kubectl wait --for=condition=available --timeout=120s deployment/local-registry -n registry
fi

# Get registry endpoint
REGISTRY_IP=$(kubectl get svc local-registry -n registry -o jsonpath='{.spec.clusterIP}')
REGISTRY_ENDPOINT="${REGISTRY_IP}:5000"

echo "✅ Registry accessible at: $REGISTRY_ENDPOINT"
echo ""

# Counter for tracking progress
TOTAL=0
LOADED=0
FAILED=0

echo "📦 Loading and pushing images..."
echo ""

# Process each tar file
for tar_file in "$IMAGES_DIR"/*.tar; do
  # Skip if no tar files found
  [ -e "$tar_file" ] || { echo "❌ No image tar files found in $IMAGES_DIR"; exit 1; }
  
  TOTAL=$((TOTAL + 1))
  filename=$(basename "$tar_file")
  
  echo "[$TOTAL] Processing: $filename"
  
  # Load image and capture output
  echo "    📥 Loading image..."
  LOAD_OUTPUT=$(docker load -i "$tar_file" 2>&1)
  
  if [ $? -eq 0 ]; then
    # Get the image name from the load output
    # Docker load outputs: "Loaded image: image:tag"
    IMAGE_INFO=$(echo "$LOAD_OUTPUT" | grep "Loaded image" | sed 's/Loaded image: //' | head -1)
    
    if [ -z "$IMAGE_INFO" ]; then
      # Try to get image name from filename
      # Filename format: quay_io_argoproj_workflow-controller_v3.5.5.tar
      # Convert: quay_io_argoproj_workflow-controller_v3.5.5 -> quay.io/argoproj/workflow-controller:v3.5.5
      BASE_NAME=$(echo "$filename" | sed 's/\.tar$//')
      # Replace first two underscores with slashes, last underscore with colon
      IMAGE_INFO=$(echo "$BASE_NAME" | sed 's/_/\//' | sed 's/_/\//' | sed 's/_/:/')
    fi
    
    # Extract image name and tag
    if [[ "$IMAGE_INFO" == *":"* ]]; then
      IMAGE_NAME=$(echo "$IMAGE_INFO" | cut -d: -f1)
      IMAGE_TAG=$(echo "$IMAGE_INFO" | cut -d: -f2)
    else
      IMAGE_NAME="$IMAGE_INFO"
      IMAGE_TAG="latest"
    fi
    
    # Create new tag for local registry
    NEW_TAG="${REGISTRY_ENDPOINT}/${IMAGE_NAME}:${IMAGE_TAG}"
    echo "    🏷️  Tagging as: $NEW_TAG"
    docker tag "$IMAGE_INFO" "$NEW_TAG"
    
    # Push to registry
    echo "    📤 Pushing to registry..."
    if docker push "$NEW_TAG"; then
      LOADED=$((LOADED + 1))
      echo "    ✅ Successfully pushed"
    else
      FAILED=$((FAILED + 1))
      echo "    ❌ Failed to push"
    fi
  else
    FAILED=$((FAILED + 1))
    echo "    ❌ Failed to load image"
  fi
  
  echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Image loading complete!"
echo ""
echo "Summary:"
echo "  Total images: $TOTAL"
echo "  Loaded and pushed: $LOADED"
echo "  Failed: $FAILED"
echo ""
echo "Registry endpoint: $REGISTRY_ENDPOINT"
echo ""
echo "Next steps:"
echo "1. Verify images in registry: kubectl exec -n registry deployment/local-registry -- ls /var/lib/registry"
echo "2. Deploy Argo Workflows: ./deploy-argo.sh"


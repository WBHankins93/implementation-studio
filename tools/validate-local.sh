#!/bin/bash
# Validate Kubernetes manifests locally

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🔍 Validating Kubernetes manifests locally..."

# Check for required tools
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required but not installed. Aborting." >&2; exit 1; }
command -v kubeval >/dev/null 2>&1 || { echo "⚠️  kubeval not found. Install for better validation: https://github.com/instrumenta/kubeval" >&2; }

# Find and validate all YAML files
find "$PROJECT_ROOT" -type f \( -name "*.yaml" -o -name "*.yml" \) \
  ! -path "*/node_modules/*" \
  ! -path "*/.git/*" \
  ! -path "*/vendor/*" | while read -r file; do
  
  # Check if it's a Kubernetes manifest
  if grep -q "kind:\|apiVersion:" "$file" 2>/dev/null; then
    echo "  ✓ Validating: $file"
    
    # Dry-run validation
    if kubectl apply --dry-run=client -f "$file" >/dev/null 2>&1; then
      echo "    ✅ Valid"
    else
      echo "    ❌ Invalid"
      kubectl apply --dry-run=client -f "$file" 2>&1 | head -5
      exit 1
    fi
  fi
done

echo "✅ All Kubernetes manifests validated successfully!"


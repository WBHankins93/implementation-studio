#!/bin/bash
# Validate Terraform code

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🔍 Validating Terraform code..."

# Check for required tools
command -v terraform >/dev/null 2>&1 || { echo "❌ terraform is required but not installed. Aborting." >&2; exit 1; }

# Format check
echo "  Checking formatting..."
if terraform fmt -check -recursive "$PROJECT_ROOT"; then
  echo "  ✅ Formatting is correct"
else
  echo "  ❌ Formatting issues found. Run 'terraform fmt -recursive' to fix."
  exit 1
fi

# Validate all Terraform directories
echo "  Validating Terraform modules and labs..."
find "$PROJECT_ROOT" -name "*.tf" -type f -exec dirname {} \; | sort -u | while read -r dir; do
  if [ -f "$dir/main.tf" ] || [ -f "$dir/variables.tf" ]; then
    echo "  ✓ Validating: $dir"
    (
      cd "$dir"
      terraform init -backend=false >/dev/null 2>&1
      if terraform validate >/dev/null 2>&1; then
        echo "    ✅ Valid"
      else
        echo "    ❌ Invalid"
        terraform validate
        exit 1
      fi
    )
  fi
done

echo "✅ All Terraform code validated successfully!"


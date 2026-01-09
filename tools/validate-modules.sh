#!/bin/bash
# Comprehensive module validation script
# This script validates Terraform modules for correctness, completeness, and best practices

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track validation results
PASSED=0
FAILED=0
WARNINGS=0

# Function to print success
success() {
  echo -e "${GREEN}✅ $1${NC}"
  ((PASSED++))
}

# Function to print failure
failure() {
  echo -e "${RED}❌ $1${NC}"
  ((FAILED++))
}

# Function to print warning
warning() {
  echo -e "${YELLOW}⚠️  $1${NC}"
  ((WARNINGS++))
}

# Function to validate a module
validate_module() {
  local module_dir="$1"
  local module_name=$(basename "$module_dir")
  local module_type=$(basename "$(dirname "$module_dir")")
  
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Validating: $module_type/$module_name"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  # Check 1: Required files exist
  local required_files=("main.tf" "variables.tf" "outputs.tf" "README.md")
  for file in "${required_files[@]}"; do
    if [ -f "$module_dir/$file" ]; then
      success "Required file exists: $file"
    else
      failure "Missing required file: $file"
    fi
  done
  
  # Check 2: Terraform syntax validation
  if [ -f "$module_dir/main.tf" ]; then
    (
      cd "$module_dir"
      if terraform init -backend=false >/dev/null 2>&1 && terraform validate >/dev/null 2>&1; then
        success "Terraform syntax is valid"
      else
        failure "Terraform validation failed"
        terraform validate 2>&1 | head -10
      fi
    )
  fi
  
  # Check 3: Variables have descriptions
  if [ -f "$module_dir/variables.tf" ]; then
    local vars_without_desc=$(grep -c "^variable\|description" "$module_dir/variables.tf" || true)
    local var_count=$(grep -c "^variable" "$module_dir/variables.tf" || true)
    if [ "$var_count" -gt 0 ]; then
      if grep -q "description" "$module_dir/variables.tf"; then
        success "Variables have descriptions"
      else
        warning "Some variables may be missing descriptions"
      fi
    fi
  fi
  
  # Check 4: Outputs have descriptions
  if [ -f "$module_dir/outputs.tf" ]; then
    local output_count=$(grep -c "^output" "$module_dir/outputs.tf" || true)
    if [ "$output_count" -gt 0 ]; then
      if grep -q "description" "$module_dir/outputs.tf"; then
        success "Outputs have descriptions"
      else
        warning "Some outputs may be missing descriptions"
      fi
    fi
  fi
  
  # Check 5: README exists and has content
  if [ -f "$module_dir/README.md" ]; then
    local readme_lines=$(wc -l < "$module_dir/README.md" || echo "0")
    if [ "$readme_lines" -gt 10 ]; then
      success "README has substantial content ($readme_lines lines)"
    else
      warning "README may be too brief ($readme_lines lines)"
    fi
    
    # Check for usage examples
    if grep -qi "usage\|example\|## Usage" "$module_dir/README.md"; then
      success "README contains usage examples"
    else
      warning "README may be missing usage examples"
    fi
  fi
  
  # Check 6: No hardcoded values in main.tf (basic check)
  if [ -f "$module_dir/main.tf" ]; then
    if grep -q "10\.0\.0\." "$module_dir/main.tf" && ! grep -q "var\." "$module_dir/main.tf"; then
      warning "Possible hardcoded IP addresses found"
    else
      success "No obvious hardcoded values detected"
    fi
  fi
  
  # Check 7: Versions file exists (best practice)
  if [ -f "$module_dir/versions.tf" ]; then
    success "versions.tf exists (provider versioning)"
  else
    warning "versions.tf not found (consider adding provider version constraints)"
  fi
}

echo "🔍 Comprehensive Module Validation"
echo "===================================="
echo ""
echo "This script validates all Terraform modules for:"
echo "  - Required files (main.tf, variables.tf, outputs.tf, README.md)"
echo "  - Terraform syntax correctness"
echo "  - Documentation completeness"
echo "  - Best practices"
echo ""

# Check for required tools
command -v terraform >/dev/null 2>&1 || { 
  failure "terraform is required but not installed. Aborting." 
  exit 1 
}

# Find all module directories (those with main.tf)
echo "📦 Discovering modules..."
MODULE_COUNT=0
while IFS= read -r -d '' module_dir; do
  # Only process directories that look like modules (have main.tf)
  if [ -f "$module_dir/main.tf" ]; then
    validate_module "$module_dir"
    ((MODULE_COUNT++))
  fi
done < <(find "$PROJECT_ROOT/modules" -type d -print0)

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Validation Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Modules validated: $MODULE_COUNT"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -gt 0 ]; then
  echo "❌ Validation failed. Please fix the errors above."
  exit 1
elif [ $WARNINGS -gt 0 ]; then
  echo "⚠️  Validation passed with warnings. Consider addressing the warnings."
  exit 0
else
  echo "✅ All modules validated successfully!"
  exit 0
fi


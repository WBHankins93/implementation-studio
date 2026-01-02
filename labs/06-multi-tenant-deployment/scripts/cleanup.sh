#!/bin/bash
# Cleanup script for Lab 06: Multi-Tenant Deployment

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🧹 Cleaning up Lab 06: Multi-Tenant Deployment"
echo ""

# Confirm deletion
echo "⚠️  This will destroy all resources created by this lab."
echo "   This includes:"
echo "   - All tenant namespaces"
echo "   - Shared services namespace"
echo "   - Cluster (if using GCP)"
echo ""
read -p "Are you sure you want to continue? (yes/N): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
  echo "Cancelled."
  exit 0
fi

# Delete tenant namespaces
echo "🗑️  Deleting tenant namespaces..."
TENANTS=$(kubectl get namespaces -l tenant --no-headers 2>/dev/null | awk '{print $1}' || echo "")
if [ -n "$TENANTS" ]; then
  for tenant in $TENANTS; do
    echo "  Deleting $tenant..."
    kubectl delete namespace "$tenant" --wait=false || true
  done
fi

# Delete shared services
echo "🗑️  Deleting shared services..."
kubectl delete namespace shared-services --wait=false || true

# Destroy Terraform resources (if using GCP)
if [ -f "$LAB_DIR/terraform.tfvars" ]; then
  USE_GCP=$(grep -E '^use_gcp\s*=' "$LAB_DIR/terraform.tfvars" | cut -d'=' -f2 | tr -d ' "' || echo "false")
  
  if [ "$USE_GCP" = "true" ]; then
    echo "🗑️  Destroying Terraform resources..."
    cd "$LAB_DIR"
    terraform destroy -auto-approve || true
  else
    # Delete Kind cluster
    CLUSTER_NAME=$(grep -E '^cluster_name\s*=' "$LAB_DIR/terraform.tfvars" 2>/dev/null | cut -d'=' -f2 | tr -d ' "' || echo "multi-tenant-cluster")
    if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
      echo "🗑️  Deleting Kind cluster..."
      kind delete cluster --name "$CLUSTER_NAME" || true
    fi
  fi
fi

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "All resources have been destroyed."


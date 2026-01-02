#!/bin/bash
# Validate Lab 06: Multi-Tenant Deployment

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🔍 Validating Lab 06: Multi-Tenant Deployment"
echo ""

# Check if kubectl is configured
if ! kubectl cluster-info &>/dev/null; then
  echo "❌ kubectl is not configured"
  exit 1
fi

# Check shared services namespace
echo "📦 Checking shared services..."
if kubectl get namespace shared-services &>/dev/null; then
  echo "✅ Shared services namespace exists"
  
  # Check network policy
  if kubectl get networkpolicy shared-services-access -n shared-services &>/dev/null; then
    echo "✅ Shared services network policy exists"
  else
    echo "⚠️  Shared services network policy not found"
  fi
else
  echo "⚠️  Shared services namespace not found"
fi

# Check tenant namespaces
echo ""
echo "🏢 Checking tenant namespaces..."
TENANTS=$(kubectl get namespaces -l tenant --no-headers 2>/dev/null | awk '{print $1}' || echo "")

if [ -n "$TENANTS" ]; then
  echo "Found tenants:"
  echo "$TENANTS" | sed 's/^/  - /'
  
  for tenant in $TENANTS; do
    echo ""
    echo "  Tenant: $tenant"
    
    # Check resource quota
    if kubectl get resourcequota -n "$tenant" &>/dev/null; then
      echo "    ✅ Resource quota exists"
    else
      echo "    ⚠️  Resource quota not found"
    fi
    
    # Check limit range
    if kubectl get limitrange -n "$tenant" &>/dev/null; then
      echo "    ✅ Limit range exists"
    else
      echo "    ⚠️  Limit range not found"
    fi
    
    # Check network policy
    if kubectl get networkpolicy -n "$tenant" &>/dev/null; then
      echo "    ✅ Network policy exists"
    else
      echo "    ⚠️  Network policy not found"
    fi
    
    # Check RBAC
    if kubectl get role -n "$tenant" &>/dev/null; then
      echo "    ✅ RBAC roles exist"
    else
      echo "    ⚠️  RBAC roles not found"
    fi
  done
else
  echo "⚠️  No tenant namespaces found"
  echo "   Create tenants with: ./tenant-onboarding/create-tenant.sh <tenant-name>"
fi

# Test isolation
echo ""
echo "🛡️  Testing tenant isolation..."

if [ -n "$TENANTS" ]; then
  FIRST_TENANT=$(echo "$TENANTS" | head -1)
  SECOND_TENANT=$(echo "$TENANTS" | head -2 | tail -1)
  
  if [ -n "$SECOND_TENANT" ]; then
    echo "Testing connectivity between $FIRST_TENANT and $SECOND_TENANT..."
    
    # Try to create a pod in first tenant that pings second tenant
    # This should fail if isolation is working
    echo "  (Isolation test would go here - requires pods in both namespaces)"
  else
    echo "  (Need at least 2 tenants to test isolation)"
  fi
fi

# Check resource usage
echo ""
echo "📊 Resource usage summary:"
for tenant in $TENANTS; do
  if kubectl get resourcequota -n "$tenant" &>/dev/null; then
    echo ""
    echo "  $tenant:"
    kubectl describe resourcequota -n "$tenant" | grep -A 10 "Resource Quotas" || true
  fi
done

echo ""
echo "✅ Validation complete!"
echo ""
echo "To create a tenant: ./tenant-onboarding/create-tenant.sh <tenant-name>"


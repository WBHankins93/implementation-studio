#!/bin/bash
# Create a new tenant namespace with isolation, RBAC, and quotas

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
MODULES_DIR="$LAB_DIR/../../modules/kubernetes"

if [ $# -lt 1 ]; then
  echo "Usage: $0 <tenant-name> [quota-type] [user-email]"
  echo ""
  echo "  tenant-name: Name of the tenant (e.g., tenant-a, acme-corp)"
  echo "  quota-type:  standard (default) or limited"
  echo "  user-email:  Email of user to grant namespace-admin access"
  echo ""
  echo "Example:"
  echo "  $0 tenant-a standard user@example.com"
  exit 1
fi

TENANT_NAME="$1"
QUOTA_TYPE="${2:-standard}"
USER_EMAIL="${3:-}"

echo "🏢 Creating tenant: $TENANT_NAME"
echo ""

# Create namespace
echo "📝 Creating namespace..."
kubectl create namespace "$TENANT_NAME" --dry-run=client -o yaml | kubectl apply -f -

# Label namespace
kubectl label namespace "$TENANT_NAME" name="$TENANT_NAME" --overwrite
kubectl label namespace "$TENANT_NAME" tenant="$TENANT_NAME" --overwrite

# Apply resource quota
echo "📊 Applying resource quota ($QUOTA_TYPE)..."
if [ "$QUOTA_TYPE" = "limited" ]; then
  QUOTA_FILE="$MODULES_DIR/resource-quotas/limited-quota.yaml"
else
  QUOTA_FILE="$MODULES_DIR/resource-quotas/standard-quota.yaml"
fi

sed "s/{{NAMESPACE}}/$TENANT_NAME/g" "$QUOTA_FILE" | kubectl apply -f -

# Apply network policy (namespace isolation)
echo "🛡️  Applying network policy..."
sed "s/{{NAMESPACE}}/$TENANT_NAME/g" "$MODULES_DIR/network-policies/namespace-isolation.yaml" | \
  kubectl apply -f - -n "$TENANT_NAME"

# Apply RBAC (namespace admin)
echo "🔐 Applying RBAC..."
if [ -n "$USER_EMAIL" ]; then
  sed "s/{{NAMESPACE}}/$TENANT_NAME/g; s/{{USER}}/$USER_EMAIL/g" \
    "$MODULES_DIR/rbac-patterns/namespace-admin.yaml" | \
    kubectl apply -f - -n "$TENANT_NAME"
else
  echo "   (Skipping user RBAC - no user email provided)"
  # Create service account only
  kubectl create serviceaccount namespace-admin -n "$TENANT_NAME" --dry-run=client -o yaml | kubectl apply -f -
fi

# Create tenant info
echo "📋 Tenant information:"
echo ""
echo "Namespace: $TENANT_NAME"
echo "Quota Type: $QUOTA_TYPE"
if [ -n "$USER_EMAIL" ]; then
  echo "Admin User: $USER_EMAIL"
fi
echo ""
echo "✅ Tenant created successfully!"
echo ""
echo "Next steps:"
echo "1. Deploy applications to namespace: kubectl apply -f <manifests> -n $TENANT_NAME"
echo "2. Check quota usage: kubectl describe resourcequota -n $TENANT_NAME"
echo "3. Test isolation: kubectl run test --image=busybox -n $TENANT_NAME --rm -it -- sh"


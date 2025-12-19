#!/bin/bash
# Validate Lab 01 deployment

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🔍 Validating Lab 01 deployment"
echo ""

# Check if kubectl is configured
if ! kubectl cluster-info &>/dev/null; then
  echo "❌ kubectl is not configured"
  exit 1
fi

# Check namespaces
echo "📦 Checking namespaces..."
kubectl get namespace argo >/dev/null 2>&1 || { echo "❌ Namespace 'argo' not found"; exit 1; }
kubectl get namespace ingress-nginx >/dev/null 2>&1 || { echo "❌ Namespace 'ingress-nginx' not found"; exit 1; }
echo "✅ Namespaces exist"

# Check Argo Workflows
echo "⚙️  Checking Argo Workflows..."
if kubectl get deployment argo-workflows-server -n argo &>/dev/null; then
  READY=$(kubectl get deployment argo-workflows-server -n argo -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
  DESIRED=$(kubectl get deployment argo-workflows-server -n argo -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "0")
  if [ "$READY" = "$DESIRED" ] && [ "$READY" != "0" ]; then
    echo "✅ Argo Workflows server is ready"
  else
    echo "⚠️  Argo Workflows server is not ready (${READY}/${DESIRED} replicas)"
  fi
else
  echo "❌ Argo Workflows deployment not found"
fi

# Check Ingress NGINX
echo "🌐 Checking Ingress NGINX..."
if kubectl get deployment ingress-nginx-controller -n ingress-nginx &>/dev/null; then
  READY=$(kubectl get deployment ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
  DESIRED=$(kubectl get deployment ingress-nginx-controller -n ingress-nginx -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "0")
  if [ "$READY" = "$DESIRED" ] && [ "$READY" != "0" ]; then
    echo "✅ Ingress NGINX controller is ready"
  else
    echo "⚠️  Ingress NGINX controller is not ready (${READY}/${DESIRED} replicas)"
  fi
else
  echo "❌ Ingress NGINX deployment not found"
fi

# Check Ingress service
echo "🔍 Checking Ingress service..."
INGRESS_IP=$(kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
if [ -n "$INGRESS_IP" ]; then
  echo "✅ Ingress IP assigned: $INGRESS_IP"
else
  echo "⚠️  Ingress IP not yet assigned"
fi

echo ""
echo "✅ Validation complete!"


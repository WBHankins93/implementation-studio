#!/bin/bash
# Validate Lab 03 deployment

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🔍 Validating Lab 03: Private Network Deployment"
echo ""

# Check if kubectl is configured
if ! kubectl cluster-info &>/dev/null; then
  echo "❌ kubectl is not configured"
  echo "   Note: For private clusters, you must access via bastion host"
  echo "   Run: ./scripts/bastion-access.sh"
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

# Check Ingress service (should be internal)
echo "🔍 Checking Ingress service..."
INGRESS_IP=$(kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
INGRESS_TYPE=$(kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.spec.type}' 2>/dev/null || echo "")
if [ -n "$INGRESS_IP" ]; then
  echo "✅ Ingress IP assigned: $INGRESS_IP"
  if [ "$INGRESS_TYPE" = "LoadBalancer" ]; then
    # Check if it's internal
    INTERNAL_LB=$(kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.metadata.annotations.cloud\.google\.com/load-balancer-type}' 2>/dev/null || echo "")
    if [ "$INTERNAL_LB" = "Internal" ]; then
      echo "✅ Ingress is configured as internal load balancer"
    else
      echo "⚠️  Ingress may not be configured as internal load balancer"
    fi
  fi
else
  echo "⚠️  Ingress IP not yet assigned"
fi

# Check cluster endpoint (should be private)
echo "🔍 Checking cluster configuration..."
CLUSTER_ENDPOINT=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' 2>/dev/null || echo "")
if [[ "$CLUSTER_ENDPOINT" == *"private"* ]] || [[ "$CLUSTER_ENDPOINT" == *"internal"* ]]; then
  echo "✅ Cluster endpoint appears to be private"
else
  echo "⚠️  Cluster endpoint may not be private: $CLUSTER_ENDPOINT"
fi

echo ""
echo "✅ Validation complete!"
echo ""
echo "Note: This cluster is private and only accessible from within the VPC"
echo "Access the cluster via bastion host: ./scripts/bastion-access.sh"


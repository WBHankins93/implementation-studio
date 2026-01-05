#!/bin/bash
# Validate Lab 07: Integration Patterns (works for both GCP and AWS)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🔍 Validating Lab 07: Integration Patterns"
echo ""

# Detect cloud provider
cd "$LAB_DIR"
CLOUD_PROVIDER=$(grep -E '^cloud_provider\s*=' terraform.tfvars 2>/dev/null | sed 's/.*=\s*"\(.*\)".*/\1/' | tr -d ' ' || echo "gcp")

echo "☁️  Cloud Provider: $CLOUD_PROVIDER"
echo ""

# Check if kubectl is configured
if ! kubectl cluster-info &>/dev/null; then
  echo "❌ kubectl is not configured"
  exit 1
fi

# Check cluster
echo "📦 Checking cluster..."
kubectl get nodes

# Check namespaces
echo ""
echo "📝 Checking namespaces..."
kubectl get namespaces | grep -E "argo|oauth-proxy|database|kong" || echo "  (Integration namespaces not yet created)"

# Check OAuth2 Proxy (if deployed)
echo ""
echo "🔐 Checking OAuth2 Proxy..."
if kubectl get deployment oauth2-proxy -n oauth-proxy &>/dev/null; then
  echo "✅ OAuth2 Proxy deployed"
  kubectl get pods -n oauth-proxy
else
  echo "⚠️  OAuth2 Proxy not deployed"
  echo "   Deploy with: kubectl apply -f auth-integration/oauth-proxy/"
fi

# Check Database Proxy (if deployed)
echo ""
if [ "$CLOUD_PROVIDER" = "gcp" ]; then
  echo "🗄️  Checking Cloud SQL Proxy..."
  if kubectl get deployment cloud-sql-proxy -n database &>/dev/null; then
    echo "✅ Cloud SQL Proxy deployed"
    kubectl get pods -n database
  else
    echo "⚠️  Cloud SQL Proxy not deployed"
    echo "   Deploy with: kubectl apply -f database-connectivity/cloud-sql-proxy/"
  fi
elif [ "$CLOUD_PROVIDER" = "aws" ]; then
  echo "🗄️  Checking RDS Proxy..."
  if kubectl get deployment rds-proxy -n database &>/dev/null; then
    echo "✅ RDS Proxy deployed"
    kubectl get pods -n database
  else
    echo "⚠️  RDS Proxy not deployed"
    echo "   Deploy with: kubectl apply -f database-connectivity/rds-proxy/"
  fi
fi

# Check Kong (if deployed)
echo ""
echo "🌐 Checking Kong API Gateway..."
if kubectl get deployment kong -n kong &>/dev/null; then
  echo "✅ Kong deployed"
  kubectl get pods -n kong
  kubectl get svc kong-proxy -n kong
else
  echo "⚠️  Kong not deployed"
  echo "   Deploy with: kubectl apply -f api-gateway/kong-example/"
fi

echo ""
echo "✅ Validation complete!"
echo ""
echo "Integration patterns are optional - deploy the ones you want to learn about."

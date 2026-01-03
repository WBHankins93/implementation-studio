#!/bin/bash
# Validate Lab 01 deployment (GCP or AWS)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🔍 Validating Lab 01 deployment"
echo ""

cd "$LAB_DIR"

# Detect cloud provider
CLOUD_PROVIDER=$(grep -E '^cloud_provider\s*=' terraform.tfvars 2>/dev/null | sed 's/.*=\s*"\(.*\)".*/\1/' | tr -d ' ' || echo "gcp")

echo "☁️  Cloud Provider: $CLOUD_PROVIDER"
echo ""

# Check Terraform state
echo "📋 Checking Terraform state..."
if ! terraform output cluster_name >/dev/null 2>&1; then
  echo "❌ Terraform outputs not available. Run 'terraform apply' first."
  exit 1
fi

CLUSTER_NAME=$(terraform output -raw cluster_name)
echo "✅ Cluster: $CLUSTER_NAME"
echo ""

# Check kubectl access
echo "🔍 Checking cluster access..."
if ! kubectl cluster-info >/dev/null 2>&1; then
  echo "⚠️  Cannot access cluster. Getting credentials..."
  
  if [ "$CLOUD_PROVIDER" = "gcp" ]; then
    REGION=$(grep -E '^region\s*=' terraform.tfvars | sed 's/.*=\s*"\(.*\)".*/\1/' | tr -d ' ' || echo "us-central1")
    PROJECT_ID=$(grep -E '^project_id\s*=' terraform.tfvars | sed 's/.*=\s*"\(.*\)".*/\1/' | tr -d ' ' || echo "")
    gcloud container clusters get-credentials "$CLUSTER_NAME" --region "$REGION" --project "$PROJECT_ID"
  elif [ "$CLOUD_PROVIDER" = "aws" ]; then
    REGION=$(grep -E '^region\s*=' terraform.tfvars | sed 's/.*=\s*"\(.*\)".*/\1/' | tr -d ' ' || echo "us-west-2")
    aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME"
  fi
fi

kubectl cluster-info
echo ""

# Check nodes
echo "🖥️  Checking nodes..."
kubectl get nodes
NODE_COUNT=$(kubectl get nodes --no-headers 2>/dev/null | wc -l | tr -d ' ')
if [ "$NODE_COUNT" -eq 0 ]; then
  echo "❌ No nodes found in cluster"
  exit 1
fi
echo "✅ Found $NODE_COUNT node(s)"
echo ""

# Check namespaces
echo "📦 Checking namespaces..."
kubectl get namespaces | grep -E "(argo|ingress-nginx|default)" || true
echo ""

# Check Argo Workflows
echo "🔄 Checking Argo Workflows..."
if kubectl get namespace argo >/dev/null 2>&1; then
  kubectl get pods -n argo
  ARGO_PODS=$(kubectl get pods -n argo --no-headers 2>/dev/null | grep -c Running || echo "0")
  if [ "$ARGO_PODS" -gt 0 ]; then
    echo "✅ Argo Workflows is running ($ARGO_PODS pod(s))"
  else
    echo "⚠️  Argo Workflows pods not running"
  fi
else
  echo "⚠️  Argo namespace not found. Run ./scripts/deploy-argo.sh"
fi
echo ""

# Check Ingress NGINX
echo "🌐 Checking Ingress NGINX..."
if kubectl get namespace ingress-nginx >/dev/null 2>&1; then
  kubectl get pods -n ingress-nginx
  INGRESS_PODS=$(kubectl get pods -n ingress-nginx --no-headers 2>/dev/null | grep -c Running || echo "0")
  if [ "$INGRESS_PODS" -gt 0 ]; then
    echo "✅ Ingress NGINX is running ($INGRESS_PODS pod(s))"
  else
    echo "⚠️  Ingress NGINX pods not running"
  fi
else
  echo "⚠️  Ingress NGINX namespace not found. Run ./scripts/deploy-argo.sh"
fi
echo ""

# Check sample workflow
echo "📝 Checking sample workflow..."
if kubectl get workflow -n argo hello-world >/dev/null 2>&1; then
  WORKFLOW_STATUS=$(kubectl get workflow -n argo hello-world -o jsonpath='{.status.phase}' 2>/dev/null || echo "Unknown")
  echo "✅ Sample workflow found (Status: $WORKFLOW_STATUS)"
else
  echo "⚠️  Sample workflow not found. Apply manifests/sample-workflow.yaml"
fi
echo ""

echo "✅ Validation complete!"
echo ""
echo "Summary:"
echo "  Cloud Provider: $CLOUD_PROVIDER"
echo "  Cluster: $CLUSTER_NAME"
echo "  Nodes: $NODE_COUNT"
echo "  Argo Workflows: $ARGO_PODS pod(s) running"
echo "  Ingress NGINX: $INGRESS_PODS pod(s) running"

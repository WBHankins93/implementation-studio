#!/bin/bash
# Validate air-gapped deployment
# This script verifies that Argo Workflows is running and accessible

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔍 Validating air-gapped deployment"
echo ""

# Check prerequisites
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required but not installed." >&2; exit 1; }

# Check namespaces
echo "📦 Checking namespaces..."
if kubectl get namespace argo &>/dev/null; then
  echo "✅ Namespace 'argo' exists"
else
  echo "❌ Namespace 'argo' not found"
  exit 1
fi

if kubectl get namespace registry &>/dev/null; then
  echo "✅ Namespace 'registry' exists"
else
  echo "❌ Namespace 'registry' not found"
  exit 1
fi

# Check registry
echo ""
echo "📦 Checking registry..."
if kubectl get deployment local-registry -n registry &>/dev/null; then
  READY=$(kubectl get deployment local-registry -n registry -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
  DESIRED=$(kubectl get deployment local-registry -n registry -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "0")
  if [ "$READY" = "$DESIRED" ] && [ "$READY" != "0" ]; then
    echo "✅ Registry is ready ($READY/$DESIRED replicas)"
  else
    echo "⚠️  Registry is not ready ($READY/$DESIRED replicas)"
  fi
else
  echo "❌ Registry deployment not found"
fi

# Check Argo Workflows
echo ""
echo "⚙️  Checking Argo Workflows..."
if kubectl get deployment argo-workflows-server -n argo &>/dev/null; then
  READY=$(kubectl get deployment argo-workflows-server -n argo -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
  DESIRED=$(kubectl get deployment argo-workflows-server -n argo -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "0")
  if [ "$READY" = "$DESIRED" ] && [ "$READY" != "0" ]; then
    echo "✅ Argo Workflows server is ready ($READY/$DESIRED replicas)"
  else
    echo "⚠️  Argo Workflows server is not ready ($READY/$DESIRED replicas)"
  fi
else
  echo "❌ Argo Workflows server deployment not found"
fi

if kubectl get deployment workflow-controller -n argo &>/dev/null; then
  READY=$(kubectl get deployment workflow-controller -n argo -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
  DESIRED=$(kubectl get deployment workflow-controller -n argo -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "0")
  if [ "$READY" = "$DESIRED" ] && [ "$READY" != "0" ]; then
    echo "✅ Workflow controller is ready ($READY/$DESIRED replicas)"
  else
    echo "⚠️  Workflow controller is not ready ($READY/$DESIRED replicas)"
  fi
else
  echo "❌ Workflow controller deployment not found"
fi

# Check pod images
echo ""
echo "🖼️  Checking pod images (should use local registry)..."
kubectl get pods -n argo -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[0].image}{"\n"}{end}' | while read -r pod image; do
  if [[ "$image" == *"local-registry"* ]] || [[ "$image" == *"registry.svc.cluster.local"* ]]; then
    echo "  ✅ $pod: Using local registry"
  else
    echo "  ⚠️  $pod: May not be using local registry ($image)"
  fi
done

# Verify no external access
echo ""
echo "🔒 Verifying air-gap (external access should fail)..."
if kubectl run airgap-test --image=busybox --rm -i --restart=Never --timeout=10s -- wget -O- https://www.google.com &>/dev/null; then
  echo "  ⚠️  WARNING: External access succeeded (air-gap may not be properly configured)"
else
  echo "  ✅ External access blocked (air-gap verified)"
fi

echo ""
echo "✅ Validation complete!"
echo ""
echo "To test Argo Workflows:"
echo "  kubectl apply -f ../../reference-app/workflows/hello-world.yaml"
echo "  kubectl get workflows -n argo"


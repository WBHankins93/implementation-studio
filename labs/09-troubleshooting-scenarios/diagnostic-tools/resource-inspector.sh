#!/bin/bash
# Resource Inspector Tool

set -euo pipefail

NAMESPACE="${1:-all}"

echo "🔍 Resource Inspector Tool"
echo ""

if [ "$NAMESPACE" = "all" ]; then
  echo "📊 Cluster-Wide Resource Usage:"
  kubectl top nodes
  echo ""
  
  echo "📊 All Pods Resource Usage:"
  kubectl top pods --all-namespaces | head -20
  echo ""
else
  echo "📊 Resource Usage in namespace: $NAMESPACE"
  echo ""
  
  # Check resource quotas
  echo "📋 Resource Quotas:"
  kubectl get resourcequota -n "$NAMESPACE" || echo "  No resource quotas found"
  echo ""
  
  # Describe quotas
  for quota in $(kubectl get resourcequota -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}'); do
    echo "📋 Resource Quota Details: $quota"
    kubectl describe resourcequota "$quota" -n "$NAMESPACE"
    echo ""
  done
  
  # Check pod resource usage
  echo "📊 Pod Resource Usage:"
  kubectl top pods -n "$NAMESPACE" || echo "  No metrics available"
  echo ""
  
  # Check pod resource requests/limits
  echo "📋 Pod Resource Requests/Limits:"
  for pod in $(kubectl get pods -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}'); do
    echo "  Pod: $pod"
    kubectl get pod "$pod" -n "$NAMESPACE" -o jsonpath='{.spec.containers[*].resources}' | jq '.' 2>/dev/null || echo "    (No jq installed, showing raw)"
    echo ""
  done
fi

# Check for OOMKilled pods
echo "⚠️  OOMKilled Pods:"
kubectl get pods --all-namespaces -o json | jq -r '.items[] | select(.status.containerStatuses[]?.lastState.terminated.reason=="OOMKilled") | "\(.metadata.namespace)/\(.metadata.name)"' 2>/dev/null || \
kubectl get pods --all-namespaces | grep OOMKilled || echo "  No OOMKilled pods found"
echo ""

# Check pending pods
echo "⏳ Pending Pods:"
kubectl get pods --all-namespaces | grep Pending || echo "  No pending pods found"
echo ""

echo "✅ Resource inspection complete"


#!/bin/bash
# Connectivity Check Tool

set -euo pipefail

NAMESPACE="${1:-default}"
POD_NAME="${2:-}"

echo "🔍 Connectivity Diagnostic Tool"
echo ""

if [ -z "$POD_NAME" ]; then
  echo "Usage: $0 <namespace> <pod-name>"
  echo ""
  echo "Example: $0 default my-pod"
  exit 1
fi

echo "Checking connectivity for pod: $POD_NAME in namespace: $NAMESPACE"
echo ""

# Check pod exists
if ! kubectl get pod "$POD_NAME" -n "$NAMESPACE" &>/dev/null; then
  echo "❌ Pod $POD_NAME not found in namespace $NAMESPACE"
  exit 1
fi

# Check pod status
echo "📊 Pod Status:"
kubectl get pod "$POD_NAME" -n "$NAMESPACE" -o wide
echo ""

# Check service endpoints
echo "🔗 Service Endpoints:"
kubectl get svc -n "$NAMESPACE" -o wide
echo ""

# Test DNS resolution
echo "🌐 DNS Resolution Test:"
kubectl exec "$POD_NAME" -n "$NAMESPACE" -- nslookup kubernetes.default || echo "  DNS resolution failed"
echo ""

# Test service connectivity
echo "🔌 Service Connectivity Test:"
for svc in $(kubectl get svc -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}'); do
  echo "  Testing $svc..."
  kubectl exec "$POD_NAME" -n "$NAMESPACE" -- wget -O- "http://$svc" --timeout=5 2>&1 | head -1 || echo "    ❌ Failed to connect"
done
echo ""

# Check network policies
echo "🛡️  Network Policies:"
kubectl get networkpolicies -n "$NAMESPACE" || echo "  No network policies found"
echo ""

# Check pod IP
POD_IP=$(kubectl get pod "$POD_NAME" -n "$NAMESPACE" -o jsonpath='{.status.podIP}')
echo "📍 Pod IP: $POD_IP"
echo ""

# Check events
echo "📋 Recent Events:"
kubectl get events -n "$NAMESPACE" --field-selector involvedObject.name="$POD_NAME" --sort-by='.lastTimestamp' | tail -5
echo ""

echo "✅ Connectivity check complete"


#!/bin/bash
# Cluster Health Check Tool

set -euo pipefail

echo "🏥 Cluster Health Check"
echo ""

# Check cluster connectivity
echo "🔌 Cluster Connectivity:"
if kubectl cluster-info &>/dev/null; then
  echo "  ✅ Cluster is accessible"
  kubectl cluster-info | head -1
else
  echo "  ❌ Cannot connect to cluster"
  exit 1
fi
echo ""

# Check nodes
echo "🖥️  Node Status:"
kubectl get nodes
echo ""

# Check for not-ready nodes
NOT_READY=$(kubectl get nodes --no-headers | grep -v Ready | wc -l)
if [ "$NOT_READY" -gt 0 ]; then
  echo "  ⚠️  Warning: $NOT_READY node(s) not ready"
  kubectl get nodes | grep -v Ready
else
  echo "  ✅ All nodes are ready"
fi
echo ""

# Check pods
echo "📦 Pod Status Summary:"
kubectl get pods --all-namespaces --no-headers | awk '{print $4}' | sort | uniq -c
echo ""

# Check for failed pods
FAILED=$(kubectl get pods --all-namespaces --no-headers | grep -E 'Error|CrashLoopBackOff|ImagePullBackOff|OOMKilled' | wc -l)
if [ "$FAILED" -gt 0 ]; then
  echo "  ⚠️  Warning: $FAILED pod(s) in error state"
  kubectl get pods --all-namespaces | grep -E 'Error|CrashLoopBackOff|ImagePullBackOff|OOMKilled'
else
  echo "  ✅ No pods in error state"
fi
echo ""

# Check for pending pods
PENDING=$(kubectl get pods --all-namespaces --no-headers | grep Pending | wc -l)
if [ "$PENDING" -gt 0 ]; then
  echo "  ⚠️  Warning: $PENDING pod(s) pending"
  kubectl get pods --all-namespaces | grep Pending | head -5
else
  echo "  ✅ No pending pods"
fi
echo ""

# Check resource usage (if metrics available)
echo "📊 Resource Usage:"
if kubectl top nodes &>/dev/null; then
  kubectl top nodes
  echo ""
  echo "Top resource-consuming pods:"
  kubectl top pods --all-namespaces | head -10
else
  echo "  ℹ️  Metrics server not available"
fi
echo ""

# Check recent events
echo "📋 Recent Critical Events:"
kubectl get events --all-namespaces --sort-by='.lastTimestamp' | grep -iE 'error|warning|failed' | tail -10 || echo "  No recent critical events"
echo ""

# Check system components
echo "🔧 System Components:"
kubectl get pods -n kube-system | grep -E 'Running|Pending' | wc -l | xargs -I {} echo "  System pods: {} running/pending"
echo ""

echo "✅ Cluster health check complete"
echo ""
echo "💡 Review any warnings or errors above"


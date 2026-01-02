#!/bin/bash
# Simulate Resource Exhaustion

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCENARIO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LAB_DIR="$(cd "$SCENARIO_DIR/../.." && pwd)"

echo "🔴 Simulating Resource Exhaustion"
echo ""

# Create namespace
kubectl create namespace resource-test --dry-run=client -o yaml | kubectl apply -f -

# Create a restrictive resource quota
kubectl apply -f - <<EOF
apiVersion: v1
kind: ResourceQuota
metadata:
  name: restrictive-quota
  namespace: resource-test
spec:
  hard:
    requests.cpu: "500m"
    requests.memory: 512Mi
    limits.cpu: "1"
    limits.memory: 1Gi
    pods: "2"
EOF

# Create a pod that requests too much memory (will exceed quota)
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: memory-hungry-pod
  namespace: resource-test
spec:
  containers:
  - name: memory-consumer
    image: polinux/stress
    command: ['stress']
    args: ['--vm', '1', '--vm-bytes', '600M', '--vm-hang', '1']
    resources:
      requests:
        memory: "600Mi"
        cpu: "200m"
      limits:
        memory: "600Mi"
        cpu: "200m"
EOF

# Create another pod that will be OOMKilled
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: oom-pod
  namespace: resource-test
spec:
  containers:
  - name: oom-container
    image: polinux/stress
    command: ['stress']
    args: ['--vm', '1', '--vm-bytes', '800M', '--vm-hang', '1']
    resources:
      requests:
        memory: "400Mi"
        cpu: "200m"
      limits:
        memory: "400Mi"  # Will be exceeded, causing OOMKill
        cpu: "200m"
EOF

# Create a pod that can't be scheduled due to quota
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: pending-pod
  namespace: resource-test
spec:
  containers:
  - name: app
    image: nginx
    resources:
      requests:
        memory: "300Mi"
        cpu: "300m"
      limits:
        memory: "500Mi"
        cpu: "500m"
EOF

echo ""
echo "✅ Resource exhaustion problem created!"
echo ""
echo "The issues:"
echo "  - ResourceQuota limits namespace to 1Gi memory and 1 CPU"
echo "  - memory-hungry-pod requests 600Mi (may exceed quota)"
echo "  - oom-pod will be OOMKilled (tries to use 800M with 400Mi limit)"
echo "  - pending-pod can't be scheduled (quota exhausted)"
echo ""
echo "Now diagnose the problem:"
echo "  1. Check pod status: kubectl get pods -n resource-test"
echo "  2. Check resource quota: kubectl describe resourcequota -n resource-test"
echo "  3. Check resource usage: kubectl top pods -n resource-test"
echo "  4. Follow diagnosis guide: cat $SCRIPT_DIR/diagnosis.md"


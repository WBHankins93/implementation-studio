#!/bin/bash
# Simulate Permission Denied Error

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔴 Simulating Permission Denied Error"
echo ""

# Create namespace
kubectl create namespace permission-test --dry-run=client -o yaml | kubectl apply -f -

# Create a pod with a service account that has no permissions
kubectl create serviceaccount no-permissions -n permission-test

# Create a pod that tries to list pods (will fail due to no permissions)
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: permission-test-pod
  namespace: permission-test
spec:
  serviceAccountName: no-permissions
  containers:
  - name: test
    image: bitnami/kubectl
    command: ['sh', '-c', 'kubectl get pods -n permission-test && sleep 3600']
EOF

echo ""
echo "✅ Permission denied problem created!"
echo ""
echo "The issue:"
echo "  - Pod uses service account 'no-permissions'"
echo "  - Service account has no RBAC permissions"
echo "  - Pod tries to list pods (requires permissions)"
echo "  - Will fail with 'Forbidden' error"
echo ""
echo "Now diagnose the problem:"
echo "  1. Check pod logs: kubectl logs permission-test-pod -n permission-test"
echo "  2. Check service account: kubectl get serviceaccount -n permission-test"
echo "  3. Check RBAC: kubectl get role,rolebinding -n permission-test"
echo "  4. Follow diagnosis guide: cat $SCRIPT_DIR/diagnosis.md"


#!/bin/bash
# Simulate Image Pull Failure

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔴 Simulating Image Pull Failure"
echo ""

# Create namespace
kubectl create namespace image-test --dry-run=client -o yaml | kubectl apply -f -

# Create a pod with a non-existent image
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: image-pull-fail-pod
  namespace: image-test
spec:
  containers:
  - name: app
    image: nonexistent-registry.example.com/nonexistent-image:latest
    imagePullPolicy: Always
EOF

echo ""
echo "✅ Image pull failure problem created!"
echo ""
echo "The issue:"
echo "  - Pod tries to pull from nonexistent-registry.example.com"
echo "  - Image 'nonexistent-image:latest' doesn't exist"
echo "  - Will fail with ImagePullBackOff"
echo ""
echo "Now diagnose the problem:"
echo "  1. Check pod status: kubectl get pods -n image-test"
echo "  2. Check pod events: kubectl describe pod image-pull-fail-pod -n image-test"
echo "  3. Check image pull secrets: kubectl get secrets -n image-test"
echo "  4. Follow diagnosis guide: cat $SCRIPT_DIR/diagnosis.md"


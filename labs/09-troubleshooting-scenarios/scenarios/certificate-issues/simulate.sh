#!/bin/bash
# Simulate Certificate/TLS Issue

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔴 Simulating Certificate/TLS Issue"
echo ""

# Create namespace
kubectl create namespace cert-test --dry-run=client -o yaml | kubectl apply -f -

# Create a pod that tries to connect to a service with invalid certificate
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: cert-test-pod
  namespace: cert-test
spec:
  containers:
  - name: test
    image: curlimages/curl
    command: ['sh', '-c', 'curl -v https://expired.badssl.com && sleep 3600']
EOF

echo ""
echo "✅ Certificate/TLS problem created!"
echo ""
echo "The issue:"
echo "  - Pod tries to connect to expired.badssl.com"
echo "  - This site has an expired certificate"
echo "  - Will fail with certificate validation error"
echo ""
echo "Now diagnose the problem:"
echo "  1. Check pod logs: kubectl logs cert-test-pod -n cert-test"
echo "  2. Test certificate: kubectl exec cert-test-pod -n cert-test -- curl -v https://expired.badssl.com"
echo "  3. Check certificate details: kubectl exec cert-test-pod -n cert-test -- openssl s_client -connect expired.badssl.com:443"
echo "  4. Follow diagnosis guide: cat $SCRIPT_DIR/diagnosis.md"


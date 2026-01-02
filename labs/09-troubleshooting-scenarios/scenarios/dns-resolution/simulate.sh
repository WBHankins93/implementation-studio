#!/bin/bash
# Simulate DNS Resolution Issue

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔴 Simulating DNS Resolution Issue"
echo ""

# Create namespace
kubectl create namespace dns-test --dry-run=client -o yaml | kubectl apply -f -

# Create a service
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: test-service
  namespace: dns-test
spec:
  selector:
    app: test-app
  ports:
  - port: 80
    targetPort: 8080
EOF

# Create a pod that tries to resolve DNS
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: dns-test-pod
  namespace: dns-test
spec:
  containers:
  - name: test
    image: busybox
    command: ['sh', '-c', 'nslookup test-service.dns-test.svc.cluster.local && sleep 3600']
  dnsPolicy: None
  dnsConfig:
    nameservers:
    - 1.1.1.1  # Wrong DNS server (will fail for cluster DNS)
EOF

echo ""
echo "✅ DNS resolution problem created!"
echo ""
echo "The issue:"
echo "  - Pod uses custom DNS server (1.1.1.1)"
echo "  - Custom DNS doesn't know about cluster services"
echo "  - DNS resolution for cluster services will fail"
echo ""
echo "Now diagnose the problem:"
echo "  1. Check pod status: kubectl get pods -n dns-test"
echo "  2. Test DNS: kubectl exec dns-test-pod -n dns-test -- nslookup test-service"
echo "  3. Check CoreDNS: kubectl get pods -n kube-system | grep coredns"
echo "  4. Follow diagnosis guide: cat $SCRIPT_DIR/diagnosis.md"


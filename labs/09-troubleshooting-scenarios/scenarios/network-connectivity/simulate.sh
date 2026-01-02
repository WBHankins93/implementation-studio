#!/bin/bash
# Simulate Network Connectivity Failure

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCENARIO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LAB_DIR="$(cd "$SCENARIO_DIR/../.." && pwd)"

echo "🔴 Simulating Network Connectivity Failure"
echo ""

# Create namespace
kubectl create namespace network-test --dry-run=client -o yaml | kubectl apply -f -

# Create a service
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: test-service
  namespace: network-test
spec:
  selector:
    app: test-app
  ports:
  - port: 80
    targetPort: 8080
EOF

# Create a pod that should connect to the service
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: client-pod
  namespace: network-test
spec:
  containers:
  - name: client
    image: busybox
    command: ['sh', '-c', 'sleep 3600']
EOF

# Create a restrictive network policy that blocks traffic
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: network-test
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: kube-system
    ports:
    - protocol: UDP
      port: 53
EOF

# Create a pod that should be reachable but isn't due to network policy
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: server-pod
  namespace: network-test
  labels:
    app: test-app
spec:
  containers:
  - name: server
    image: nginx
    ports:
    - containerPort: 80
EOF

echo ""
echo "✅ Network connectivity problem created!"
echo ""
echo "The issue:"
echo "  - NetworkPolicy 'deny-all' is blocking all traffic"
echo "  - client-pod cannot reach server-pod"
echo "  - Service exists but traffic is blocked"
echo ""
echo "Now diagnose the problem:"
echo "  1. Check pod status: kubectl get pods -n network-test"
echo "  2. Try to connect: kubectl exec -it client-pod -n network-test -- wget -O- http://test-service"
echo "  3. Check network policies: kubectl get networkpolicies -n network-test"
echo "  4. Follow diagnosis guide: cat $SCRIPT_DIR/diagnosis.md"


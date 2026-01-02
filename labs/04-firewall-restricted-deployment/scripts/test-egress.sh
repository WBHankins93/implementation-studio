#!/bin/bash
# Test egress connectivity and firewall restrictions

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🧪 Testing Egress Connectivity"
echo ""

# Check if kubectl is configured
if ! kubectl cluster-info &>/dev/null; then
  echo "❌ kubectl is not configured"
  exit 1
fi

# Get proxy IP
cd "$LAB_DIR"
PROXY_IP=$(terraform output -raw proxy_internal_ip 2>/dev/null || echo "")
if [ -z "$PROXY_IP" ]; then
  echo "⚠️  Could not get proxy IP"
  exit 1
fi

echo "🔌 Proxy IP: $PROXY_IP"
echo ""

# Test 1: Direct egress (should fail if firewall is strict)
echo "Test 1: Direct egress (without proxy) - should fail with strict firewall"
kubectl run test-direct-egress \
  --image=curlimages/curl:latest \
  --rm -i --restart=Never \
  -- sh -c "curl -v --max-time 5 https://www.google.com 2>&1 || echo '✅ Direct egress blocked (expected)'" || true

echo ""

# Test 2: Egress through proxy (should succeed)
echo "Test 2: Egress through proxy - should succeed"
kubectl run test-proxy-egress \
  --image=curlimages/curl:latest \
  --rm -i --restart=Never \
  --env="HTTP_PROXY=http://$PROXY_IP:3128" \
  --env="HTTPS_PROXY=http://$PROXY_IP:3128" \
  --env="NO_PROXY=localhost,127.0.0.1,.svc,.svc.cluster.local" \
  -- sh -c "curl -v --max-time 10 https://www.google.com 2>&1 && echo '✅ Proxy egress working'" || echo "❌ Proxy egress failed"

echo ""

# Test 3: Internal connectivity (should work without proxy)
echo "Test 3: Internal cluster connectivity - should work without proxy"
kubectl run test-internal \
  --image=curlimages/curl:latest \
  --rm -i --restart=Never \
  -- sh -c "curl -v http://kubernetes.default.svc.cluster.local 2>&1 && echo '✅ Internal connectivity working'" || echo "❌ Internal connectivity failed"

echo ""

# Test 4: DNS resolution
echo "Test 4: DNS resolution - should work"
kubectl run test-dns \
  --image=busybox:latest \
  --rm -i --restart=Never \
  -- nslookup google.com || echo "❌ DNS resolution failed"

echo ""
echo "✅ Egress testing complete!"
echo ""
echo "Summary:"
echo "- Direct egress should be blocked (strict firewall)"
echo "- Proxy egress should work"
echo "- Internal connectivity should work"
echo "- DNS should work"


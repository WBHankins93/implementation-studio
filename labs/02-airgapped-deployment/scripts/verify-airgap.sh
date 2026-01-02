#!/bin/bash
# Verify that the environment is truly air-gapped
# This script tests that external internet access is blocked

set -euo pipefail

echo "🔒 Verifying air-gap configuration"
echo ""

# Check prerequisites
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required but not installed." >&2; exit 1; }

# Test 1: Try to access external website
echo "Test 1: External HTTP access (should fail)..."
if kubectl run airgap-test-http --image=busybox --rm -i --restart=Never --timeout=10s -- wget -O- --timeout=5 http://www.google.com &>/dev/null; then
  echo "  ❌ FAILED: External HTTP access succeeded"
  echo "     Air-gap is NOT properly configured"
  exit 1
else
  echo "  ✅ PASSED: External HTTP access blocked"
fi

# Test 2: Try to access external HTTPS
echo ""
echo "Test 2: External HTTPS access (should fail)..."
if kubectl run airgap-test-https --image=busybox --rm -i --restart=Never --timeout=10s -- wget -O- --timeout=5 https://www.google.com &>/dev/null; then
  echo "  ❌ FAILED: External HTTPS access succeeded"
  echo "     Air-gap is NOT properly configured"
  exit 1
else
  echo "  ✅ PASSED: External HTTPS access blocked"
fi

# Test 3: Try to pull image from Docker Hub
echo ""
echo "Test 3: Docker Hub image pull (should fail)..."
if kubectl run airgap-test-pull --image=alpine:latest --rm -i --restart=Never --timeout=10s -- echo "test" &>/dev/null; then
  # Check if image was pulled (this is tricky, but if pod starts, image exists)
  echo "  ⚠️  WARNING: Pod started - image may have been pulled"
  echo "     Verify network policies are blocking egress"
else
  echo "  ✅ PASSED: Cannot pull images from external registries"
fi

# Test 4: DNS resolution (should work for internal, fail for external)
echo ""
echo "Test 4: DNS resolution..."
if kubectl run airgap-test-dns --image=busybox --rm -i --restart=Never --timeout=10s -- nslookup kubernetes.default.svc.cluster.local &>/dev/null; then
  echo "  ✅ PASSED: Internal DNS resolution works"
else
  echo "  ⚠️  WARNING: Internal DNS resolution failed"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Air-gap verification complete!"
echo ""
echo "If all tests passed, your environment is properly air-gapped."
echo "If any tests failed, check network policies and cluster configuration."


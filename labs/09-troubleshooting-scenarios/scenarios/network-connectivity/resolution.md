# Resolving Network Connectivity Issues

## Solution Options

### Option 1: Remove Restrictive Network Policy (Quick Fix)

**If the network policy is too restrictive:**
```bash
kubectl delete networkpolicy deny-all -n network-test
```

**Verify Fix:**
```bash
kubectl exec -it client-pod -n network-test -- wget -O- http://test-service
```

**Expected:** Should succeed now

### Option 2: Update Network Policy (Recommended)

**Create a more permissive network policy:**
```bash
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-internal
  namespace: network-test
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: network-test
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: network-test
  - to:
    - namespaceSelector:
        matchLabels:
          name: kube-system
    ports:
    - protocol: UDP
      port: 53
  - to: []  # Allow external traffic
EOF
```

**Delete the old policy:**
```bash
kubectl delete networkpolicy deny-all -n network-test
```

**Verify Fix:**
```bash
kubectl exec -it client-pod -n network-test -- wget -O- http://test-service
```

## Verification Steps

### 1. Test Internal Connectivity

```bash
# Test service connectivity
kubectl exec -it client-pod -n network-test -- wget -O- http://test-service

# Test direct pod connectivity
SERVER_IP=$(kubectl get pod server-pod -n network-test -o jsonpath='{.status.podIP}')
kubectl exec -it client-pod -n network-test -- wget -O- http://$SERVER_IP
```

**Expected:** Both should succeed

### 2. Test DNS Resolution

```bash
kubectl exec -it client-pod -n network-test -- nslookup test-service
```

**Expected:** Should resolve correctly

### 3. Test External Connectivity (If Allowed)

```bash
kubectl exec -it client-pod -n network-test -- wget -O- http://www.google.com --timeout=5
```

**Expected:** Should succeed if external traffic is allowed

## Prevention

### Best Practices

1. **Start Permissive, Then Restrict:**
   - Begin with allow-all policies
   - Gradually restrict based on requirements
   - Test after each change

2. **Document Network Policies:**
   - Document why each policy exists
   - Document what traffic is allowed/denied
   - Review policies regularly

3. **Test Network Policies:**
   - Test policies in non-production first
   - Verify expected traffic works
   - Verify unwanted traffic is blocked

4. **Monitor Network Policies:**
   - Monitor for connection failures
   - Alert on policy violations
   - Review policies during incidents

## Common Mistakes

### Mistake 1: Empty Pod Selector

**Problem:**
```yaml
spec:
  podSelector: {}  # Matches ALL pods
```

**Solution:** Be specific with pod selectors:
```yaml
spec:
  podSelector:
    matchLabels:
      app: my-app
```

### Mistake 2: Forgetting DNS

**Problem:** Blocking all egress, including DNS

**Solution:** Always allow DNS:
```yaml
egress:
- to:
  - namespaceSelector:
      matchLabels:
        name: kube-system
  ports:
  - protocol: UDP
    port: 53
```

### Mistake 3: Not Testing

**Problem:** Applying network policy without testing

**Solution:** Always test connectivity after applying policies

## Resolution Summary

| Action | Command | Result |
|--------|---------|--------|
| Identify issue | `kubectl get networkpolicies` | Found deny-all policy |
| Remove/update policy | `kubectl delete networkpolicy deny-all` | Policy removed |
| Verify fix | `kubectl exec ... wget` | Connection succeeds |
| Test prevention | Apply proper policy | Traffic allowed as intended |

## Key Learnings

1. **Network policies can silently block traffic** - pods may be healthy but unreachable
2. **Always check network policies** when diagnosing connectivity issues
3. **Test after applying policies** - verify expected behavior
4. **Document policies** - understand why they exist
5. **Start permissive, then restrict** - easier to debug

## Related Documentation

- [Kubernetes Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [Network Policy Examples](https://kubernetes.io/docs/tasks/administer-cluster/declare-network-policy/)


# Resolving DNS Resolution Issues

## Solution: Fix DNS Configuration

### Option 1: Use Default DNS Policy (Recommended)

**Delete and Recreate Pod with Default DNS:**
```bash
kubectl delete pod dns-test-pod -n dns-test

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
  # Remove dnsPolicy and dnsConfig to use default
EOF
```

**Verify Fix:**
```bash
kubectl exec dns-test-pod -n dns-test -- nslookup test-service.dns-test.svc.cluster.local
```

**Expected:** Should resolve correctly

### Option 2: Configure Custom DNS with Cluster DNS

**If custom DNS is required, include cluster DNS:**
```bash
# Get cluster DNS IP
CLUSTER_DNS=$(kubectl get svc kube-dns -n kube-system -o jsonpath='{.spec.clusterIP}')

kubectl delete pod dns-test-pod -n dns-test

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
    - $CLUSTER_DNS  # Cluster DNS first
    - 1.1.1.1       # External DNS as fallback
    searches:
    - dns-test.svc.cluster.local
    - svc.cluster.local
    - cluster.local
EOF
```

## Verification Steps

### 1. Test Service DNS

```bash
kubectl exec dns-test-pod -n dns-test -- nslookup test-service.dns-test.svc.cluster.local
```

**Expected:** Should resolve to service IP

### 2. Test Short Name

```bash
kubectl exec dns-test-pod -n dns-test -- nslookup test-service
```

**Expected:** Should resolve (if search domains configured)

### 3. Test External DNS

```bash
kubectl exec dns-test-pod -n dns-test -- nslookup www.google.com
```

**Expected:** Should resolve external domains

### 4. Check DNS Configuration

```bash
kubectl exec dns-test-pod -n dns-test -- cat /etc/resolv.conf
```

**Expected:** Should show cluster DNS server

## Prevention

### Best Practices

1. **Use Default DNS Policy:**
   - Use `ClusterFirst` (default) when possible
   - Only use custom DNS when necessary
   - Include cluster DNS in custom config

2. **Verify DNS Configuration:**
   - Test DNS resolution after deployment
   - Check `/etc/resolv.conf` in pods
   - Verify CoreDNS is running

3. **Monitor CoreDNS:**
   - Check CoreDNS pod status
   - Monitor CoreDNS logs
   - Alert on CoreDNS failures

4. **Test DNS:**
   - Test service discovery
   - Test external DNS
   - Test DNS resolution regularly

## Common Mistakes

### Mistake 1: Custom DNS Without Cluster DNS

**Problem:** Using external DNS only, losing cluster service discovery

**Solution:** Include cluster DNS in custom configuration

### Mistake 2: Wrong DNS Policy

**Problem:** Using `None` when `ClusterFirst` would work

**Solution:** Use default DNS policy when possible

### Mistake 3: Not Testing DNS

**Problem:** Assuming DNS works without testing

**Solution:** Always test DNS resolution after deployment

## Resolution Summary

| Issue | Solution | Result |
|-------|----------|--------|
| Custom DNS config | Use default or include cluster DNS | DNS resolution works |
| DNS policy None | Change to ClusterFirst or fix config | Cluster DNS accessible |
| Service discovery | Fix DNS configuration | Services resolvable |

## Key Learnings

1. **DNS resolution fails = check DNS config** - Verify dnsPolicy and dnsConfig
2. **Default DNS policy works** - Use ClusterFirst when possible
3. **Include cluster DNS** - If using custom DNS, include cluster DNS
4. **Test DNS resolution** - Always verify DNS works
5. **Check CoreDNS** - Ensure CoreDNS is running

## Related Documentation

- [DNS for Services and Pods](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)
- [CoreDNS](https://coredns.io/)


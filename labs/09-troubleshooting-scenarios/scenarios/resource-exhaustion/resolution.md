# Resolving Resource Exhaustion

## Solution Options

### Option 1: Increase Resource Quota (Quick Fix)

**Update Resource Quota:**
```bash
kubectl patch resourcequota restrictive-quota -n resource-test --type merge -p '
{
  "spec": {
    "hard": {
      "requests.cpu": "2",
      "requests.memory": "2Gi",
      "limits.cpu": "4",
      "limits.memory": "4Gi",
      "pods": "10"
    }
  }
}'
```

**Verify Fix:**
```bash
kubectl get pods -n resource-test
```

**Expected:** Pending pods should now schedule

### Option 2: Adjust Pod Resource Requests/Limits

**Reduce Resource Requests:**
```bash
kubectl patch pod memory-hungry-pod -n resource-test --type merge -p '
{
  "spec": {
    "containers": [{
      "name": "memory-consumer",
      "resources": {
        "requests": {
          "memory": "300Mi",
          "cpu": "100m"
        },
        "limits": {
          "memory": "400Mi",
          "cpu": "200m"
        }
      }
    }]
  }
}'
```

**Note:** Pods can't be patched directly. Delete and recreate with new limits.

### Option 3: Fix OOMKilled Pod

**Increase Memory Limit:**
```bash
kubectl delete pod oom-pod -n resource-test

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
    args: ['--vm', '1', '--vm-bytes', '600M', '--vm-hang', '1']
    resources:
      requests:
        memory: "400Mi"
        cpu: "200m"
      limits:
        memory: "800Mi"  # Increased to match usage
        cpu: "200m"
EOF
```

## Verification Steps

### 1. Check Pod Status

```bash
kubectl get pods -n resource-test
```

**Expected:** All pods should be Running

### 2. Check Resource Quota Usage

```bash
kubectl describe resourcequota restrictive-quota -n resource-test
```

**Expected:** Should show available resources

### 3. Monitor Resource Usage

```bash
kubectl top pods -n resource-test
```

**Expected:** Pods should be using resources within limits

### 4. Check Events

```bash
kubectl get events -n resource-test --sort-by='.lastTimestamp'
```

**Expected:** No OOMKilling or scheduling failures

## Prevention

### Best Practices

1. **Right-Size Resources:**
   - Monitor actual usage
   - Set requests based on average usage
   - Set limits based on peak usage + buffer
   - Review and adjust regularly

2. **Use Resource Quotas Wisely:**
   - Set quotas based on actual needs
   - Allow headroom for growth
   - Monitor quota usage
   - Alert on high quota usage

3. **Monitor Resource Usage:**
   - Set up alerts for high usage
   - Monitor trends over time
   - Identify resource-intensive workloads
   - Plan capacity accordingly

4. **Handle OOMKilled Gracefully:**
   - Increase limits if usage is legitimate
   - Fix memory leaks if usage is abnormal
   - Use resource quotas to prevent over-allocation
   - Monitor and alert on OOMKilled events

## Common Mistakes

### Mistake 1: Requests = Limits

**Problem:**
```yaml
resources:
  requests:
    memory: "500Mi"
  limits:
    memory: "500Mi"  # No headroom
```

**Solution:** Allow headroom:
```yaml
resources:
  requests:
    memory: "400Mi"  # Guaranteed
  limits:
    memory: "600Mi"  # Can burst
```

### Mistake 2: Too Restrictive Quotas

**Problem:** Quota set too low, causing frequent failures

**Solution:** Set quotas based on actual needs with headroom

### Mistake 3: Not Monitoring

**Problem:** Not aware of resource issues until failures occur

**Solution:** Monitor resource usage and set up alerts

## Resolution Summary

| Issue | Solution | Result |
|-------|----------|--------|
| OOMKilled pod | Increase memory limit | Pod runs successfully |
| Pending pods | Increase quota | Pods can schedule |
| Resource quota | Adjust quota limits | More resources available |
| Resource usage | Right-size requests/limits | Efficient resource usage |

## Key Learnings

1. **OOMKilled means memory limit exceeded** - increase limit or fix memory leak
2. **Pending pods often mean quota exhausted** - check resource quotas
3. **Monitor resource usage** - prevent issues before they occur
4. **Right-size resources** - requests based on average, limits with headroom
5. **Use resource quotas** - prevent resource exhaustion

## Related Documentation

- [Resource Quotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/)
- [Resource Requests and Limits](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
- [OOMKilled Troubleshooting](https://kubernetes.io/docs/tasks/administer-cluster/out-of-resource/)


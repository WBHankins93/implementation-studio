# Scenario 2: Resource Exhaustion

## Problem Description

Pods are being killed or failing to start due to insufficient CPU, memory, or disk resources. Applications are experiencing performance degradation.

## Symptoms

**What You'll Observe:**
- Pods in `OOMKilled` state
- Pods in `Pending` state with "Insufficient resources"
- High CPU/memory usage
- Slow application performance
- Pods restarting frequently

**Example Errors:**
```
OOMKilled
Insufficient cpu
Insufficient memory
Evicted
```

## Initial Observations

**Check Pod Status:**
```bash
kubectl get pods -A
```

**Check Resource Usage:**
```bash
kubectl top pods -A
kubectl top nodes
```

**Check Events:**
```bash
kubectl get events --sort-by='.lastTimestamp'
```

## Common Causes

1. **Resource Quotas:** Namespace resource quotas too restrictive
2. **Node Capacity:** Cluster nodes don't have enough resources
3. **Resource Requests:** Pods requesting more than available
4. **Memory Leaks:** Applications consuming increasing memory
5. **CPU Throttling:** CPU limits too low

## Investigation Checklist

- [ ] Check pod status and reasons
- [ ] Check resource usage (CPU, memory, disk)
- [ ] Check resource quotas
- [ ] Check node capacity
- [ ] Check pod resource requests/limits
- [ ] Review application logs for memory leaks
- [ ] Check for resource contention

## Expected Learning Outcomes

After completing this scenario, you will:
- Know how to diagnose resource exhaustion
- Understand resource quotas and limits
- Be able to identify OOMKilled pods
- Know how to check node capacity
- Understand resource requests vs limits
- Know how to resolve resource issues

## Next Steps

1. Run the simulation: `./simulate.sh`
2. Follow the diagnosis guide: `./diagnosis.md`
3. Apply the resolution: `./resolution.md`
4. Verify the fix works


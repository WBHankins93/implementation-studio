# Scenario 5: DNS Resolution Issues

## Problem Description

Applications cannot resolve DNS names, preventing them from connecting to services or external endpoints.

## Symptoms

**What You'll Observe:**
- Connection failures to services
- DNS resolution timeouts
- "Name or service not known" errors
- Services unreachable by name
- External DNS failures

**Example Errors:**
```
Name or service not known
Temporary failure in name resolution
DNS resolution failed
```

## Initial Observations

**Check Pod Status:**
```bash
kubectl get pods -A
```

**Test DNS from Pod:**
```bash
kubectl exec [pod-name] -n [namespace] -- nslookup [service-name]
```

**Check CoreDNS:**
```bash
kubectl get pods -n kube-system | grep coredns
```

## Common Causes

1. **CoreDNS Issues:** CoreDNS pods not running
2. **Service Discovery:** Service not properly configured
3. **DNS Configuration:** Incorrect DNS configuration
4. **Network Policies:** Network policies blocking DNS
5. **External DNS:** External DNS resolution failing

## Investigation Checklist

- [ ] Check CoreDNS pods status
- [ ] Test DNS resolution from pod
- [ ] Check service endpoints
- [ ] Verify DNS configuration
- [ ] Check network policies
- [ ] Test external DNS resolution
- [ ] Review DNS logs

## Expected Learning Outcomes

After completing this scenario, you will:
- Know how to diagnose DNS issues
- Understand CoreDNS configuration
- Be able to test DNS resolution
- Know how to check service discovery
- Understand DNS in Kubernetes
- Know how to resolve DNS issues

## Next Steps

1. Run the simulation: `./simulate.sh`
2. Follow the diagnosis guide: `./diagnosis.md`
3. Apply the resolution: `./resolution.md`
4. Verify the fix works


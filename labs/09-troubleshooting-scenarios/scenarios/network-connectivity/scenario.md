# Scenario 1: Network Connectivity Failures

## Problem Description

Pods in your cluster cannot communicate with each other or with external services. Applications are failing with connection timeout errors.

## Symptoms

**What You'll Observe:**
- Pods are running but can't reach other services
- Connection timeout errors in logs
- `Connection refused` errors
- Services appear healthy but unreachable
- Network policy blocking traffic

**Example Errors:**
```
Connection timeout
Connection refused
Network unreachable
No route to host
```

## Initial Observations

**Check Pod Status:**
```bash
kubectl get pods -A
```

**Check Service Status:**
```bash
kubectl get svc -A
```

**Check Events:**
```bash
kubectl get events --sort-by='.lastTimestamp'
```

## Common Causes

1. **Network Policies:** Restrictive network policies blocking traffic
2. **Service Endpoints:** Service has no endpoints
3. **DNS Issues:** DNS resolution failing
4. **Firewall Rules:** Firewall blocking traffic
5. **Network Configuration:** Misconfigured network

## Investigation Checklist

- [ ] Check pod status
- [ ] Check service endpoints
- [ ] Test connectivity from pod
- [ ] Check network policies
- [ ] Verify DNS resolution
- [ ] Check firewall rules
- [ ] Review network configuration

## Expected Learning Outcomes

After completing this scenario, you will:
- Know how to diagnose network connectivity issues
- Understand network policies and their impact
- Be able to test connectivity from pods
- Know how to verify service endpoints
- Understand DNS resolution in Kubernetes

## Next Steps

1. Run the simulation: `./simulate.sh`
2. Follow the diagnosis guide: `./diagnosis.md`
3. Apply the resolution: `./resolution.md`
4. Verify the fix works


# Step-by-Step Guide: Troubleshooting Scenarios

This guide walks through using the troubleshooting scenarios to build your debugging skills.

## Prerequisites

- `kubectl` installed
- `kind` installed
- Basic Kubernetes knowledge
- Willingness to learn!

## Setup

### Step 1: Create Cluster

```bash
cd labs/09-troubleshooting-scenarios

# Create Kind cluster
kind create cluster --name troubleshooting-lab

# Verify cluster
kubectl cluster-info
```

### Step 2: Setup Scenarios

```bash
# Run setup script
./scripts/setup-scenarios.sh
```

## Working Through Scenarios

### Scenario Workflow

For each scenario:

1. **Read the Scenario:**
   ```bash
   cat scenarios/[scenario-name]/scenario.md
   ```

2. **Run the Simulation:**
   ```bash
   ./scenarios/[scenario-name]/simulate.sh
   ```

3. **Observe the Problem:**
   ```bash
   kubectl get pods -A
   kubectl get events --sort-by='.lastTimestamp'
   ```

4. **Diagnose (Try First!):**
   - Use systematic debugging methodology
   - Use diagnostic tools
   - Form hypotheses
   - Test hypotheses

5. **Follow Diagnosis Guide (If Stuck):**
   ```bash
   cat scenarios/[scenario-name]/diagnosis.md
   ```

6. **Apply Resolution:**
   ```bash
   cat scenarios/[scenario-name]/resolution.md
   ```

7. **Verify Fix:**
   - Check pod status
   - Test functionality
   - Verify resolution

## Scenario 1: Network Connectivity

### Step 1: Run Simulation

```bash
./scenarios/network-connectivity/simulate.sh
```

### Step 2: Observe

```bash
kubectl get pods -n network-test
kubectl get events -n network-test
```

### Step 3: Diagnose

**Try First:**
- Check pod status
- Test connectivity
- Check network policies
- Review service endpoints

**If Stuck:**
```bash
cat scenarios/network-connectivity/diagnosis.md
```

### Step 4: Resolve

```bash
cat scenarios/network-connectivity/resolution.md
# Follow resolution steps
```

### Step 5: Verify

```bash
kubectl exec client-pod -n network-test -- wget -O- http://test-service
```

## Scenario 2: Resource Exhaustion

### Step 1: Run Simulation

```bash
./scenarios/resource-exhaustion/simulate.sh
```

### Step 2: Observe

```bash
kubectl get pods -n resource-test
kubectl top pods -n resource-test
kubectl get resourcequota -n resource-test
```

### Step 3: Diagnose

**Try First:**
- Check pod status
- Check resource usage
- Check resource quotas
- Review events

**If Stuck:**
```bash
cat scenarios/resource-exhaustion/diagnosis.md
```

### Step 4: Resolve

```bash
cat scenarios/resource-exhaustion/resolution.md
# Follow resolution steps
```

### Step 5: Verify

```bash
kubectl get pods -n resource-test
# All pods should be Running
```

## Scenario 3: Permission Denied

### Step 1: Run Simulation

```bash
./scenarios/permission-denied/simulate.sh
```

### Step 2: Observe

```bash
kubectl get pods -n permission-test
kubectl logs permission-test-pod -n permission-test
```

### Step 3: Diagnose

**Try First:**
- Check pod logs
- Check service account
- Check RBAC configuration
- Test permissions

**If Stuck:**
```bash
cat scenarios/permission-denied/diagnosis.md
```

### Step 4: Resolve

```bash
cat scenarios/permission-denied/resolution.md
# Follow resolution steps
```

### Step 5: Verify

```bash
kubectl logs permission-test-pod -n permission-test
# Should show successful pod list
```

## Scenario 4: Image Pull Failures

### Step 1: Run Simulation

```bash
./scenarios/image-pull-failures/simulate.sh
```

### Step 2: Observe

```bash
kubectl get pods -n image-test
kubectl describe pod image-pull-fail-pod -n image-test
```

### Step 3: Diagnose

**Try First:**
- Check pod events
- Verify image name
- Check image pull secrets
- Test image pull

**If Stuck:**
```bash
cat scenarios/image-pull-failures/diagnosis.md
```

### Step 4: Resolve

```bash
cat scenarios/image-pull-failures/resolution.md
# Follow resolution steps
```

### Step 5: Verify

```bash
kubectl get pods -n image-test
# Pod should be Running
```

## Scenario 5: DNS Resolution

### Step 1: Run Simulation

```bash
./scenarios/dns-resolution/simulate.sh
```

### Step 2: Observe

```bash
kubectl get pods -n dns-test
kubectl exec dns-test-pod -n dns-test -- nslookup test-service
```

### Step 3: Diagnose

**Try First:**
- Test DNS resolution
- Check DNS configuration
- Check CoreDNS
- Review DNS policy

**If Stuck:**
```bash
cat scenarios/dns-resolution/diagnosis.md
```

### Step 4: Resolve

```bash
cat scenarios/dns-resolution/resolution.md
# Follow resolution steps
```

### Step 5: Verify

```bash
kubectl exec dns-test-pod -n dns-test -- nslookup test-service.dns-test.svc.cluster.local
```

## Scenario 6: Certificate Issues

### Step 1: Run Simulation

```bash
./scenarios/certificate-issues/simulate.sh
```

### Step 2: Observe

```bash
kubectl logs cert-test-pod -n cert-test
kubectl exec cert-test-pod -n cert-test -- curl -v https://expired.badssl.com
```

### Step 3: Diagnose

**Try First:**
- Check certificate expiration
- Test certificate validity
- Review error messages
- Check certificate chain

**If Stuck:**
```bash
cat scenarios/certificate-issues/diagnosis.md
```

### Step 4: Resolve

```bash
cat scenarios/certificate-issues/resolution.md
# Follow resolution steps
```

### Step 5: Verify

```bash
# Test with valid certificate
kubectl exec cert-test-pod -n cert-test -- curl -v https://www.google.com
```

## Using Diagnostic Tools

### Connectivity Check

```bash
./diagnostic-tools/connectivity-check.sh [namespace] [pod-name]
```

### Resource Inspector

```bash
./diagnostic-tools/resource-inspector.sh [namespace]
```

### Log Collector

```bash
./diagnostic-tools/log-collector.sh [namespace] [pod-name] [output-dir]
```

### Cluster Health

```bash
./diagnostic-tools/cluster-health.sh
```

## Best Practices

### 1. Try First, Then Look

**Approach:**
- Try to diagnose before reading guides
- Use systematic debugging
- Form your own hypotheses
- Learn from mistakes

### 2. Practice Multiple Times

**Repetition:**
- Run scenarios multiple times
- Try different approaches
- Build pattern recognition
- Improve speed

### 3. Document Your Process

**Documentation:**
- What you observed
- What you tried
- What worked
- What didn't work

### 4. Build Your Toolkit

**Toolkit:**
- Favorite commands
- Diagnostic scripts
- Pattern library
- Runbooks

## Cleanup

### Clean Up Scenarios

```bash
./scripts/cleanup-all.sh
```

### Delete Cluster

```bash
kind delete cluster --name troubleshooting-lab
```

## Next Steps

After completing all scenarios:

1. **Practice Regularly:** Run scenarios to maintain skills
2. **Build Patterns:** Document patterns you recognize
3. **Share Knowledge:** Teach others what you learned
4. **Apply to Real Issues:** Use methodology on real problems
5. **Continuous Improvement:** Keep learning and improving

## Related Documentation

- [Systematic Debugging](./systematic-debugging.md)
- [Common Patterns](./common-patterns.md)
- [Escalation Guide](./escalation-guide.md)
- [Troubleshooting Reference](./troubleshooting-reference.md)

---

**Remember:** Practice makes perfect. The more you troubleshoot, the better you'll become!


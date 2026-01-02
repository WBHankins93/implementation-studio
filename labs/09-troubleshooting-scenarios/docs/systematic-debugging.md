# Systematic Debugging Methodology

**Purpose:** A proven methodology for diagnosing and resolving issues in Kubernetes deployments.

## Overview

Systematic debugging is a structured approach to problem-solving that ensures nothing is missed and issues are resolved efficiently. This methodology applies to all troubleshooting scenarios.

## The Four-Step Process

### Step 1: Observe

**Goal:** Gather information about the problem

**Actions:**
1. **Check Pod Status:**
   ```bash
   kubectl get pods -A
   kubectl get pods -n [namespace] -o wide
   ```

2. **Check Events:**
   ```bash
   kubectl get events --sort-by='.lastTimestamp'
   kubectl get events -n [namespace] --sort-by='.lastTimestamp'
   ```

3. **Check Logs:**
   ```bash
   kubectl logs [pod-name] -n [namespace]
   kubectl logs [pod-name] -n [namespace] --previous  # If pod restarted
   ```

4. **Describe Resources:**
   ```bash
   kubectl describe pod [pod-name] -n [namespace]
   kubectl describe service [service-name] -n [namespace]
   ```

5. **Check Resource Status:**
   ```bash
   kubectl get all -n [namespace]
   kubectl top pods -n [namespace]
   kubectl top nodes
   ```

**Key Questions:**
- What is the current state?
- What error messages appear?
- When did it start?
- What changed recently?

### Step 2: Hypothesize

**Goal:** Form theories about what might be wrong

**Process:**
1. **Review Observations:**
   - What error messages did you see?
   - What patterns emerge?
   - What resources are affected?

2. **Consider Common Causes:**
   - Network issues (policies, connectivity)
   - Resource constraints (CPU, memory, disk)
   - Permission issues (RBAC, file permissions)
   - Configuration errors (wrong values, missing config)
   - Image issues (pull failures, wrong image)

3. **Prioritize Hypotheses:**
   - Most likely cause first
   - Easiest to verify first
   - Highest impact first

**Key Questions:**
- What is the most likely cause?
- What changed that could cause this?
- What patterns match known issues?
- What's the simplest explanation?

### Step 3: Investigate

**Goal:** Test your hypotheses systematically

**Process:**
1. **Test Most Likely Hypothesis:**
   - Check the most probable cause first
   - Use diagnostic tools
   - Verify or rule out

2. **If Hypothesis is Wrong:**
   - Move to next most likely
   - Don't get stuck on one theory
   - Keep investigating

3. **Gather Evidence:**
   - Collect logs
   - Run diagnostic commands
   - Test connectivity
   - Verify configuration

**Key Questions:**
- Does the evidence support the hypothesis?
- What else could cause this?
- What am I missing?
- Have I checked everything?

### Step 4: Resolve

**Goal:** Fix the issue and verify the solution

**Process:**
1. **Apply Fix:**
   - Make the necessary changes
   - Follow resolution procedures
   - Test the fix

2. **Verify Resolution:**
   - Check pod status
   - Verify functionality
   - Monitor for recurrence

3. **Document:**
   - Document the issue
   - Document the solution
   - Update runbooks if needed

**Key Questions:**
- Is the issue resolved?
- Does everything work as expected?
- Could this happen again?
- What can we learn from this?

## Diagnostic Tools

### Essential Commands

**Pod Information:**
```bash
kubectl get pods -o wide
kubectl describe pod [pod-name]
kubectl logs [pod-name]
kubectl logs [pod-name] --previous
```

**Service Information:**
```bash
kubectl get svc
kubectl describe svc [service-name]
kubectl get endpoints [service-name]
```

**Resource Information:**
```bash
kubectl top pods
kubectl top nodes
kubectl get resourcequota
kubectl describe resourcequota
```

**Network Information:**
```bash
kubectl get networkpolicies
kubectl describe networkpolicy [policy-name]
kubectl exec [pod-name] -- nslookup [service-name]
```

**RBAC Information:**
```bash
kubectl get role,rolebinding
kubectl describe role [role-name]
kubectl auth can-i [verb] [resource] --as=system:serviceaccount:[ns]:[sa]
```

### Diagnostic Scripts

Use the provided diagnostic tools:
- `connectivity-check.sh` - Network connectivity
- `resource-inspector.sh` - Resource usage
- `log-collector.sh` - Log collection
- `cluster-health.sh` - Overall health

## Common Patterns

### Pattern 1: Pod Not Starting

**Symptoms:** Pod in Pending, CrashLoopBackOff, or Error state

**Investigation:**
1. Check pod status and events
2. Check resource availability
3. Check image pull status
4. Check configuration errors

**Common Causes:**
- Resource constraints
- Image pull failures
- Configuration errors
- Permission issues

### Pattern 2: Pod Running But Not Working

**Symptoms:** Pod is Running but application failing

**Investigation:**
1. Check application logs
2. Test connectivity
3. Check configuration
4. Verify dependencies

**Common Causes:**
- Network connectivity issues
- Configuration errors
- Dependency failures
- Application errors

### Pattern 3: Service Unreachable

**Symptoms:** Cannot connect to service

**Investigation:**
1. Check service endpoints
2. Check network policies
3. Test DNS resolution
4. Verify service configuration

**Common Causes:**
- No endpoints
- Network policy blocking
- DNS issues
- Service misconfiguration

### Pattern 4: Resource Exhaustion

**Symptoms:** Pods being killed or can't schedule

**Investigation:**
1. Check resource usage
2. Check resource quotas
3. Check node capacity
4. Review resource requests/limits

**Common Causes:**
- Resource quotas too restrictive
- Node capacity exhausted
- Resource requests too high
- Memory leaks

## Debugging Best Practices

### 1. Start Broad, Then Narrow

**Approach:**
- Start with overall cluster health
- Narrow to specific namespace
- Focus on specific pod
- Drill into specific issue

### 2. Use the Right Tool

**Tool Selection:**
- `kubectl get` - Quick status check
- `kubectl describe` - Detailed information
- `kubectl logs` - Application logs
- `kubectl exec` - Interactive debugging

### 3. Document Everything

**Documentation:**
- What you observed
- What you tested
- What you found
- What you fixed

### 4. Don't Assume

**Verification:**
- Verify assumptions
- Test hypotheses
- Check multiple sources
- Confirm with evidence

### 5. Learn from Patterns

**Pattern Recognition:**
- Recognize common issues
- Build mental models
- Create runbooks
- Share knowledge

## Escalation Criteria

**When to Escalate:**
- Issue exceeds your expertise
- Resolution taking too long
- Business impact increasing
- Need additional resources

**What to Provide:**
- Problem description
- Symptoms observed
- Investigation done
- Evidence collected
- Hypotheses tested

## Related Documentation

- [Common Patterns](./common-patterns.md)
- [Escalation Guide](./escalation-guide.md)
- [Troubleshooting Reference](./troubleshooting-reference.md)

---

**Remember:** Systematic debugging is about method, not magic. Follow the process, use the right tools, and document everything.


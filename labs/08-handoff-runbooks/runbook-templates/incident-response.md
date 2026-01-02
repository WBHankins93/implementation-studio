# Incident Response Playbook

**Application:** [Application Name]  
**Last Updated:** [Date]  
**Owner:** [Team/Contact]

## Overview

This playbook provides procedures for responding to incidents affecting [Application Name].

## Incident Severity Levels

### P0 - Critical
- **Impact:** Complete service outage or data loss
- **Response Time:** Immediate
- **Example:** All pods down, database unreachable

### P1 - High
- **Impact:** Significant service degradation affecting many users
- **Response Time:** < 15 minutes
- **Example:** High error rate, slow response times

### P2 - Medium
- **Impact:** Service degradation affecting some users
- **Response Time:** < 1 hour
- **Example:** Intermittent errors, minor performance issues

### P3 - Low
- **Impact:** Minor issues, workarounds available
- **Response Time:** < 4 hours
- **Example:** Non-critical feature not working

## Incident Response Process

### 1. Detection and Triage

**Detection Sources:**
- Monitoring alerts (Prometheus/Grafana)
- User reports
- Application logs
- Health check failures

**Initial Assessment:**
```bash
# Check cluster status
kubectl get nodes
kubectl get pods --all-namespaces

# Check application status
kubectl get pods -n [namespace-name]
kubectl get svc -n [namespace-name]

# Check recent events
kubectl get events --sort-by='.lastTimestamp' -n [namespace-name]

# Check logs
kubectl logs -f deployment/[deployment-name] -n [namespace-name] --tail=100
```

**Determine Severity:**
- Assess impact (users affected, functionality lost)
- Assess urgency (can it wait?)
- Classify severity level

### 2. Communication

**Immediate Actions:**
- [ ] Acknowledge incident
- [ ] Notify on-call engineer
- [ ] Create incident ticket
- [ ] Update status page (if applicable)

**Stakeholder Communication:**
- P0/P1: Immediate notification to stakeholders
- P2/P3: Notification within response time window

### 3. Investigation

**Gather Information:**
```bash
# Pod status
kubectl get pods -n [namespace-name] -o wide

# Pod events
kubectl describe pod [pod-name] -n [namespace-name]

# Application logs
kubectl logs [pod-name] -n [namespace-name] --tail=200

# Resource usage
kubectl top pods -n [namespace-name]
kubectl top nodes

# Network connectivity
kubectl exec [pod-name] -n [namespace-name] -- ping [service-name]

# Check metrics
# Access Grafana and review dashboards
```

**Common Investigation Areas:**
- Pod status (CrashLoopBackOff, ImagePullBackOff, etc.)
- Resource constraints (CPU, memory, disk)
- Network connectivity
- Configuration issues
- Application errors
- External dependencies

### 4. Resolution

**Immediate Mitigation (P0/P1):**
- Restart failing pods: `kubectl rollout restart deployment/[deployment-name] -n [namespace-name]`
- Scale up if needed: `kubectl scale deployment/[deployment-name] --replicas=[count] -n [namespace-name]`
- Rollback if recent deployment: `kubectl rollout undo deployment/[deployment-name] -n [namespace-name]`

**Root Cause Resolution:**
- Fix underlying issue
- Apply configuration changes
- Update application code
- Address infrastructure issues

### 5. Verification

**Verify Resolution:**
```bash
# Check pod status
kubectl get pods -n [namespace-name]

# Verify health checks
curl https://[application-url]/health

# Check metrics
# Review Grafana dashboards

# Test functionality
# Perform smoke tests
```

**Verification Checklist:**
- [ ] All pods running
- [ ] Health checks passing
- [ ] No error logs
- [ ] Metrics back to normal
- [ ] Functionality verified
- [ ] Alerts cleared

### 6. Post-Incident

**Documentation:**
- [ ] Document incident timeline
- [ ] Document root cause
- [ ] Document resolution steps
- [ ] Update runbook with lessons learned

**Follow-Up:**
- [ ] Schedule post-mortem (P0/P1)
- [ ] Create action items
- [ ] Implement preventive measures
- [ ] Update monitoring/alerting

## Common Incidents and Solutions

### Pod Crash Loops

**Symptoms:**
- Pods restarting repeatedly
- `CrashLoopBackOff` status

**Investigation:**
```bash
# Check pod logs
kubectl logs [pod-name] -n [namespace-name] --previous

# Check pod events
kubectl describe pod [pod-name] -n [namespace-name]

# Check resource limits
kubectl describe pod [pod-name] -n [namespace-name] | grep -A 5 Limits
```

**Common Causes:**
- Application errors
- Resource limits too low
- Configuration errors
- Missing dependencies

**Resolution:**
- Fix application code
- Increase resource limits
- Fix configuration
- Add missing dependencies

### High CPU/Memory Usage

**Symptoms:**
- Pods using >80% CPU/memory
- Slow response times
- OOMKilled pods

**Investigation:**
```bash
# Check resource usage
kubectl top pods -n [namespace-name]

# Check resource limits
kubectl describe pod [pod-name] -n [namespace-name] | grep -A 5 Limits
```

**Resolution:**
- Scale up deployment
- Increase resource limits
- Optimize application
- Add more nodes

### Network Connectivity Issues

**Symptoms:**
- Pods can't reach services
- Timeout errors
- Connection refused

**Investigation:**
```bash
# Check service endpoints
kubectl get endpoints [service-name] -n [namespace-name]

# Test connectivity
kubectl exec [pod-name] -n [namespace-name] -- curl [service-name].[namespace-name].svc.cluster.local

# Check network policies
kubectl get networkpolicies -n [namespace-name]
```

**Resolution:**
- Fix service endpoints
- Update network policies
- Check DNS resolution
- Verify service configuration

### Image Pull Errors

**Symptoms:**
- `ImagePullBackOff` status
- Pods can't start

**Investigation:**
```bash
# Check pod events
kubectl describe pod [pod-name] -n [namespace-name]

# Verify image exists
docker pull [image]:[version]
```

**Resolution:**
- Verify image exists in registry
- Check registry credentials
- Fix image pull secrets
- Use correct image tag

## Escalation

**When to Escalate:**
- Incident exceeds response time
- Unable to resolve after investigation
- Requires expertise not available
- Business impact increasing

**Escalation Path:**
1. On-call engineer
2. Team lead
3. Engineering manager
4. CTO/VP Engineering

## Emergency Contacts

- **On-Call Engineer:** [Contact Information]
- **Team Lead:** [Contact Information]
- **Engineering Manager:** [Contact Information]
- **Escalation:** [Contact Information]

## Related Documentation

- [Deployment Runbook](./deployment-runbook.md)
- [Scaling Guide](./scaling-guide.md)
- [Troubleshooting Guide](../docs/troubleshooting.md)

---

**Remember:** User impact is the priority. Mitigate first, investigate second.


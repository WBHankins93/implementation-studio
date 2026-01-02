# Troubleshooting Quick Reference

**Purpose:** Quick reference for common troubleshooting commands and patterns.

## Quick Command Reference

### Pod Information

```bash
# List pods
kubectl get pods -A
kubectl get pods -n [namespace] -o wide

# Pod details
kubectl describe pod [pod-name] -n [namespace]

# Pod logs
kubectl logs [pod-name] -n [namespace]
kubectl logs [pod-name] -n [namespace] --previous
kubectl logs [pod-name] -n [namespace] --tail=100 -f

# Pod YAML
kubectl get pod [pod-name] -n [namespace] -o yaml
```

### Service Information

```bash
# List services
kubectl get svc -A
kubectl get svc -n [namespace]

# Service details
kubectl describe svc [service-name] -n [namespace]

# Service endpoints
kubectl get endpoints [service-name] -n [namespace]
```

### Resource Information

```bash
# Resource usage
kubectl top pods -n [namespace]
kubectl top nodes

# Resource quotas
kubectl get resourcequota -n [namespace]
kubectl describe resourcequota [quota-name] -n [namespace]

# Resource requests/limits
kubectl get pod [pod-name] -n [namespace] -o jsonpath='{.spec.containers[*].resources}'
```

### Network Information

```bash
# Network policies
kubectl get networkpolicies -n [namespace]
kubectl describe networkpolicy [policy-name] -n [namespace]

# Test connectivity
kubectl exec [pod-name] -n [namespace] -- wget -O- http://[service]
kubectl exec [pod-name] -n [namespace] -- ping [host]

# DNS test
kubectl exec [pod-name] -n [namespace] -- nslookup [service]
kubectl exec [pod-name] -n [namespace] -- cat /etc/resolv.conf
```

### RBAC Information

```bash
# Roles and bindings
kubectl get role,rolebinding -n [namespace]
kubectl describe role [role-name] -n [namespace]

# Service accounts
kubectl get serviceaccount -n [namespace]
kubectl describe serviceaccount [sa-name] -n [namespace]

# Test permissions
kubectl auth can-i [verb] [resource] --namespace=[namespace] --as=system:serviceaccount:[ns]:[sa]
```

### Events and Logs

```bash
# Events
kubectl get events --sort-by='.lastTimestamp'
kubectl get events -n [namespace] --sort-by='.lastTimestamp'

# Recent events
kubectl get events -n [namespace] --field-selector involvedObject.name=[pod-name]
```

### Configuration

```bash
# ConfigMaps
kubectl get configmap -n [namespace]
kubectl get configmap [name] -n [namespace] -o yaml

# Secrets
kubectl get secret -n [namespace]
kubectl get secret [name] -n [namespace] -o yaml

# Decode secret
kubectl get secret [name] -n [namespace] -o jsonpath='{.data.[key]}' | base64 -d
```

## Common Issue Patterns

### Pod Not Starting

**Quick Checks:**
```bash
kubectl get pods -n [namespace]
kubectl describe pod [pod-name] -n [namespace]
kubectl get events -n [namespace] --field-selector involvedObject.name=[pod-name]
```

**Common Causes:**
- Image pull failure
- Resource constraints
- Configuration errors
- Permission issues

### Pod Crash Looping

**Quick Checks:**
```bash
kubectl logs [pod-name] -n [namespace] --previous
kubectl describe pod [pod-name] -n [namespace]
kubectl get events -n [namespace] --field-selector involvedObject.name=[pod-name]
```

**Common Causes:**
- Application errors
- Resource limits exceeded
- Configuration errors
- Missing dependencies

### Service Unreachable

**Quick Checks:**
```bash
kubectl get endpoints [service-name] -n [namespace]
kubectl get networkpolicies -n [namespace]
kubectl exec [pod-name] -n [namespace] -- wget -O- http://[service]
```

**Common Causes:**
- No endpoints
- Network policy blocking
- DNS issues
- Service misconfiguration

### High Resource Usage

**Quick Checks:**
```bash
kubectl top pods -n [namespace]
kubectl top nodes
kubectl get resourcequota -n [namespace]
kubectl describe pod [pod-name] -n [namespace] | grep -A 5 Limits
```

**Common Causes:**
- Resource limits too low
- Resource quota exhausted
- Memory leaks
- High load

## Diagnostic Workflows

### Network Issue Workflow

1. Check pod status
2. Check service endpoints
3. Test connectivity
4. Check network policies
5. Verify DNS

### Resource Issue Workflow

1. Check pod status
2. Check resource usage
3. Check resource quotas
4. Check node capacity
5. Review resource requests/limits

### Permission Issue Workflow

1. Check pod logs
2. Check service account
3. Check RBAC configuration
4. Test permissions
5. Verify role bindings

### Image Pull Issue Workflow

1. Check pod events
2. Verify image name
3. Check image pull secrets
4. Test image pull
5. Verify registry access

## Quick Fixes

### Restart Pod

```bash
kubectl delete pod [pod-name] -n [namespace]
# Pod will be recreated if part of Deployment
```

### Scale Deployment

```bash
kubectl scale deployment [name] --replicas=[count] -n [namespace]
```

### Update Image

```bash
kubectl set image deployment/[name] [container]=[image]:[tag] -n [namespace]
```

### Rollback Deployment

```bash
kubectl rollout undo deployment/[name] -n [namespace]
```

### Delete Network Policy

```bash
kubectl delete networkpolicy [name] -n [namespace]
```

### Increase Resource Quota

```bash
kubectl patch resourcequota [name] -n [namespace] --type merge -p '{"spec":{"hard":{"memory":"2Gi"}}}'
```

## Emergency Commands

### Get Everything

```bash
kubectl get all -n [namespace]
```

### Describe Everything

```bash
kubectl describe all -n [namespace]
```

### Export Everything

```bash
kubectl get all -n [namespace] -o yaml > backup.yaml
```

### Delete Everything (Careful!)

```bash
kubectl delete all --all -n [namespace]
```

## Related Documentation

- [Systematic Debugging](./systematic-debugging.md)
- [Common Patterns](./common-patterns.md)
- [Escalation Guide](./escalation-guide.md)

---

**Remember:** This is a quick reference. For detailed procedures, see the scenario guides and systematic debugging methodology.


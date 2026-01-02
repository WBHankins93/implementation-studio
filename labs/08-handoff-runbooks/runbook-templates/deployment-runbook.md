# Deployment Runbook

**Application:** [Application Name]  
**Version:** [Version Number]  
**Last Updated:** [Date]  
**Owner:** [Team/Contact]

## Overview

This runbook provides step-by-step procedures for deploying [Application Name] to production.

## Prerequisites

### Required Access

- Kubernetes cluster access (`kubectl` configured)
- Container registry access
- Helm 3.x installed
- Access to configuration management system

### Required Information

- [ ] Cluster credentials obtained
- [ ] Container images built and pushed
- [ ] Configuration values prepared
- [ ] Database migrations ready (if applicable)
- [ ] Backup of current deployment (if upgrading)

## Pre-Deployment Checklist

- [ ] Review release notes and breaking changes
- [ ] Verify all dependencies are available
- [ ] Test deployment in staging environment
- [ ] Notify stakeholders of deployment window
- [ ] Schedule maintenance window (if required)
- [ ] Prepare rollback plan

## Deployment Steps

### Step 1: Verify Cluster Access

```bash
# Verify cluster connectivity
kubectl cluster-info

# Verify namespace exists
kubectl get namespace [namespace-name]

# Check current deployment status
kubectl get pods -n [namespace-name]
```

### Step 2: Backup Current State (If Upgrading)

```bash
# Export current configuration
kubectl get configmap [config-name] -n [namespace-name] -o yaml > config-backup.yaml

# Export current secrets (base64 encoded)
kubectl get secret [secret-name] -n [namespace-name] -o yaml > secret-backup.yaml

# Export current deployment
kubectl get deployment [deployment-name] -n [namespace-name] -o yaml > deployment-backup.yaml
```

### Step 3: Update Configuration

```bash
# Review configuration changes
diff config-backup.yaml new-config.yaml

# Apply new configuration
kubectl apply -f new-config.yaml -n [namespace-name]

# Verify configuration
kubectl get configmap [config-name] -n [namespace-name] -o yaml
```

### Step 4: Update Container Images

```bash
# Set new image version
kubectl set image deployment/[deployment-name] \
  [container-name]=[registry]/[image]:[version] \
  -n [namespace-name]

# Or use Helm upgrade
helm upgrade [release-name] [chart-path] \
  --set image.tag=[version] \
  --namespace [namespace-name]
```

### Step 5: Monitor Deployment

```bash
# Watch deployment rollout
kubectl rollout status deployment/[deployment-name] -n [namespace-name]

# Watch pods
kubectl get pods -n [namespace-name] -w

# Check pod logs
kubectl logs -f deployment/[deployment-name] -n [namespace-name]
```

### Step 6: Verify Deployment

```bash
# Check pod status
kubectl get pods -n [namespace-name]

# Verify all pods are running
kubectl get pods -n [namespace-name] | grep -v Running

# Test application endpoints
curl https://[application-url]/health

# Check metrics (if available)
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
# Open Grafana and verify application metrics
```

### Step 7: Post-Deployment Validation

- [ ] All pods are running
- [ ] Application health checks passing
- [ ] No error logs in recent entries
- [ ] Application functionality verified
- [ ] Performance metrics within normal range
- [ ] No alerts triggered

## Rollback Procedure

If deployment fails, rollback immediately:

```bash
# Rollback to previous version
kubectl rollout undo deployment/[deployment-name] -n [namespace-name]

# Or rollback to specific revision
kubectl rollout undo deployment/[deployment-name] --to-revision=[revision-number] -n [namespace-name]

# Restore configuration
kubectl apply -f config-backup.yaml -n [namespace-name]

# Verify rollback
kubectl rollout status deployment/[deployment-name] -n [namespace-name]
```

## Troubleshooting

### Pods Not Starting

1. Check pod events: `kubectl describe pod [pod-name] -n [namespace-name]`
2. Check pod logs: `kubectl logs [pod-name] -n [namespace-name]`
3. Verify image exists: `docker pull [image]:[version]`
4. Check resource limits: `kubectl describe pod [pod-name] -n [namespace-name] | grep -A 5 Limits`

### Configuration Issues

1. Verify ConfigMap: `kubectl get configmap [config-name] -n [namespace-name] -o yaml`
2. Check environment variables: `kubectl exec [pod-name] -n [namespace-name] -- env`
3. Verify secrets: `kubectl get secret [secret-name] -n [namespace-name]`

### Application Errors

1. Check application logs: `kubectl logs -f deployment/[deployment-name] -n [namespace-name]`
2. Check application metrics in Grafana
3. Review recent changes in configuration
4. Check database connectivity (if applicable)

## Post-Deployment

### Documentation Updates

- [ ] Update deployment log
- [ ] Document any issues encountered
- [ ] Update runbook with lessons learned
- [ ] Update version information

### Communication

- [ ] Notify stakeholders of successful deployment
- [ ] Update status page (if applicable)
- [ ] Document deployment in change log

## Emergency Contacts

- **On-Call Engineer:** [Contact Information]
- **Team Lead:** [Contact Information]
- **Escalation:** [Contact Information]

## Related Documentation

- [Architecture Documentation](../docs/architecture.md)
- [Incident Response Playbook](./incident-response.md)
- [Scaling Guide](./scaling-guide.md)
- [Upgrade Procedure](./upgrade-procedure.md)

---

**Remember:** Always test deployments in staging first. When in doubt, rollback and investigate.


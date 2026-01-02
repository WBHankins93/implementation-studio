# Upgrade Procedure

**Application:** [Application Name]  
**Last Updated:** [Date]  
**Owner:** [Team/Contact]

## Overview

This procedure provides step-by-step instructions for safely upgrading [Application Name].

## Pre-Upgrade Checklist

### Information Gathering

- [ ] Review release notes for new version
- [ ] Identify breaking changes
- [ ] Review upgrade path (can we upgrade directly or need intermediate versions?)
- [ ] Check compatibility with dependencies
- [ ] Review known issues

### Preparation

- [ ] Schedule maintenance window (if required)
- [ ] Notify stakeholders
- [ ] Backup current deployment (see [Backup and Restore](./backup-restore.md))
- [ ] Test upgrade in staging environment
- [ ] Prepare rollback plan
- [ ] Document current version and configuration

### Verification

- [ ] Current deployment is stable
- [ ] No active incidents
- [ ] Monitoring is functional
- [ ] Backup completed successfully
- [ ] Staging upgrade successful

## Upgrade Strategies

### Rolling Update (Default)

**Best for:** Most upgrades

**Process:**
- Kubernetes updates pods one at a time
- Zero downtime
- Automatic rollback on failure

**Command:**
```bash
kubectl set image deployment/[deployment-name] \
  [container-name]=[new-image]:[new-version] \
  -n [namespace-name]
```

### Blue-Green Deployment

**Best for:** Major upgrades, zero-downtime requirements

**Process:**
- Deploy new version alongside old
- Switch traffic when ready
- Keep old version for quick rollback

**Steps:**
1. Deploy new version with different label
2. Test new version
3. Update service to point to new version
4. Monitor
5. Remove old version when stable

### Canary Deployment

**Best for:** Testing new version with limited users

**Process:**
- Deploy new version to small subset
- Gradually increase traffic
- Monitor for issues
- Full rollout when stable

## Upgrade Steps

### Step 1: Pre-Upgrade Backup

```bash
# Backup configuration
kubectl get all -n [namespace-name] -o yaml > pre-upgrade-backup-$(date +%Y%m%d).yaml

# Backup database (if applicable)
# See backup-restore.md

# Export Helm values
helm get values [release-name] -n [namespace-name] > pre-upgrade-values-$(date +%Y%m%d).yaml
```

### Step 2: Review Changes

```bash
# Compare current and new configuration
diff pre-upgrade-values.yaml new-values.yaml

# Review breaking changes in release notes
```

### Step 3: Update Configuration

**If configuration changes required:**
```bash
# Update ConfigMaps
kubectl apply -f new-configmap.yaml -n [namespace-name]

# Update Secrets (if needed)
kubectl apply -f new-secret.yaml -n [namespace-name]
```

### Step 4: Perform Upgrade

**Helm Upgrade:**
```bash
# Upgrade with new version
helm upgrade [release-name] [chart-path] \
  --version [new-version] \
  --set image.tag=[new-version] \
  --namespace [namespace-name] \
  --wait

# Or upgrade with values file
helm upgrade [release-name] [chart-path] \
  -f new-values.yaml \
  --namespace [namespace-name] \
  --wait
```

**Kubectl Upgrade:**
```bash
# Update image
kubectl set image deployment/[deployment-name] \
  [container-name]=[new-image]:[new-version] \
  -n [namespace-name]

# Watch rollout
kubectl rollout status deployment/[deployment-name] -n [namespace-name]
```

### Step 5: Monitor Upgrade

```bash
# Watch pods
kubectl get pods -n [namespace-name] -w

# Check rollout status
kubectl rollout status deployment/[deployment-name] -n [namespace-name]

# Monitor logs
kubectl logs -f deployment/[deployment-name] -n [namespace-name]

# Check events
kubectl get events -n [namespace-name] --sort-by='.lastTimestamp'
```

### Step 6: Verify Upgrade

**Functional Verification:**
```bash
# Check pod status
kubectl get pods -n [namespace-name]

# Verify all pods running
kubectl get pods -n [namespace-name] | grep -v Running

# Test health endpoint
curl https://[application-url]/health

# Test functionality
# Perform smoke tests
```

**Metrics Verification:**
- [ ] No increase in error rates
- [ ] Response times within normal range
- [ ] Resource usage acceptable
- [ ] No alerts triggered

### Step 7: Post-Upgrade Validation

- [ ] All pods running
- [ ] Application functional
- [ ] No error logs
- [ ] Performance metrics normal
- [ ] Database migrations complete (if applicable)
- [ ] Configuration changes applied
- [ ] Monitoring working

## Rollback Procedure

### Immediate Rollback

**If upgrade fails:**
```bash
# Rollback deployment
kubectl rollout undo deployment/[deployment-name] -n [namespace-name]

# Or rollback to specific revision
kubectl rollout undo deployment/[deployment-name] \
  --to-revision=[revision-number] \
  -n [namespace-name]

# Helm rollback
helm rollback [release-name] [revision-number] -n [namespace-name]
```

**Restore Configuration:**
```bash
# Restore previous configuration
kubectl apply -f pre-upgrade-backup-$(date +%Y%m%d).yaml -n [namespace-name]

# Restore database (if applicable)
# See backup-restore.md
```

### Rollback Verification

- [ ] Previous version running
- [ ] Application functional
- [ ] No data loss
- [ ] Configuration restored

## Database Migrations

### Pre-Migration

- [ ] Backup database
- [ ] Test migration in staging
- [ ] Review migration scripts
- [ ] Plan rollback procedure

### Migration Execution

**If migration required:**
```bash
# Run migration job
kubectl apply -f migration-job.yaml -n [namespace-name]

# Monitor migration
kubectl logs -f job/[migration-job-name] -n [namespace-name]

# Verify migration
kubectl wait --for=condition=complete job/[migration-job-name] -n [namespace-name]
```

### Post-Migration

- [ ] Verify migration success
- [ ] Test application with new schema
- [ ] Verify data integrity
- [ ] Document migration completion

## Troubleshooting

### Upgrade Stuck

**Check:**
```bash
# Check rollout status
kubectl rollout status deployment/[deployment-name] -n [namespace-name]

# Check pod events
kubectl describe pod [pod-name] -n [namespace-name]

# Check logs
kubectl logs [pod-name] -n [namespace-name]
```

**Common Issues:**
- Image pull errors
- Resource constraints
- Configuration errors
- Health check failures

### Pods Not Starting

**Investigation:**
```bash
# Check pod status
kubectl get pods -n [namespace-name]

# Check pod events
kubectl describe pod [pod-name] -n [namespace-name]

# Check logs
kubectl logs [pod-name] -n [namespace-name] --previous
```

**Resolution:**
- Fix configuration issues
- Resolve resource constraints
- Fix image pull issues
- Update health checks

### Application Errors

**Investigation:**
```bash
# Check application logs
kubectl logs -f deployment/[deployment-name] -n [namespace-name]

# Check metrics
# Review Grafana dashboards

# Check events
kubectl get events -n [namespace-name] --sort-by='.lastTimestamp'
```

**Resolution:**
- Fix application code
- Update configuration
- Rollback if necessary

## Post-Upgrade

### Documentation

- [ ] Update version information
- [ ] Document upgrade completion
- [ ] Update runbooks if needed
- [ ] Document any issues encountered
- [ ] Update configuration documentation

### Communication

- [ ] Notify stakeholders of successful upgrade
- [ ] Update status page
- [ ] Document in change log

### Cleanup

- [ ] Remove old images (if space constrained)
- [ ] Archive pre-upgrade backups
- [ ] Update monitoring dashboards (if needed)

## Upgrade Schedule

### Recommended Schedule

- **Patch Releases:** As needed (security, critical bugs)
- **Minor Releases:** Monthly or quarterly
- **Major Releases:** Annually or as needed

### Maintenance Windows

- **Planned Upgrades:** Schedule during low-traffic periods
- **Emergency Upgrades:** As needed for security/critical issues
- **Communication:** Notify users in advance

## Related Documentation

- [Deployment Runbook](./deployment-runbook.md)
- [Backup and Restore](./backup-restore.md)
- [Incident Response Playbook](./incident-response.md)
- [Rolling Updates](https://kubernetes.io/docs/tutorials/kubernetes-basics/update/update-intro/)

---

**Remember:** Always test upgrades in staging first. When in doubt, rollback and investigate.


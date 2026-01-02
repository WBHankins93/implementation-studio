# Update Strategies for Air-Gapped Environments

How to update applications in air-gapped environments without internet access.

## The Challenge

In air-gapped environments, you cannot:
- Pull new images from public registries
- Download updated Helm charts
- Use package managers
- Access external update services

Updates must be planned, prepared, and transferred manually.

## Update Process Overview

```
1. Identify Updates Needed
   ↓
2. Prepare Update Bundle (with internet)
   ↓
3. Test Updates (in non-production air-gap)
   ↓
4. Transfer Update Bundle
   ↓
5. Apply Updates (in production air-gap)
   ↓
6. Verify Updates
```

## Strategy 1: Full Bundle Replacement

### When to Use

- Major version upgrades
- Multiple component updates
- Complete system refresh

### Process

1. **Prepare New Bundle** (with internet)
   - Pull new image versions
   - Package new Helm charts
   - Create complete new bundle

2. **Transfer Bundle**
   - Use approved transfer method
   - Verify integrity

3. **Deploy Updates**
   - Load new images into registry
   - Upgrade Helm releases
   - Verify functionality

### Advantages

- Clean slate
- All components updated together
- Easier to track versions

### Disadvantages

- Larger transfer size
- More downtime risk
- Requires full testing

## Strategy 2: Incremental Updates

### When to Use

- Minor version updates
- Security patches
- Single component updates

### Process

1. **Identify What Needs Update**
   ```bash
   # Current versions
   kubectl get deployments -n argo -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.template.spec.containers[0].image}{"\n"}{end}'
   ```

2. **Prepare Update Package**
   - Pull only updated images
   - Package only updated charts
   - Create minimal update bundle

3. **Apply Updates**
   - Load new images
   - Upgrade specific Helm releases
   - Verify updates

### Advantages

- Smaller transfer size
- Faster updates
- Lower risk

### Disadvantages

- More frequent updates needed
- Version tracking complexity
- Potential compatibility issues

## Strategy 3: Hot-Fix Updates

### When to Use

- Critical security patches
- Emergency fixes
- Urgent bug fixes

### Process

1. **Prepare Minimal Fix**
   - Only affected images/charts
   - Minimal change set
   - Fast-track approval

2. **Emergency Transfer**
   - Use fastest approved method
   - Skip non-critical testing

3. **Apply Fix**
   - Minimal deployment
   - Verify fix works
   - Plan full update later

## Update Preparation Checklist

### Before Preparing Updates

- [ ] Review release notes for breaking changes
- [ ] Check compatibility requirements
- [ ] Identify all affected components
- [ ] Plan rollback strategy
- [ ] Document current versions

### Preparing Update Bundle

- [ ] Pull new image versions
- [ ] Package updated Helm charts
- [ ] Update values files if needed
- [ ] Create update documentation
- [ ] Test in non-production first

### Transfer and Deployment

- [ ] Verify bundle integrity
- [ ] Transfer using approved method
- [ ] Backup current deployment
- [ ] Apply updates in staging first
- [ ] Verify updates work
- [ ] Apply to production
- [ ] Document new versions

## Image Update Process

### Step 1: Identify Current Versions

```bash
# Get current images
kubectl get pods -n argo -o jsonpath='{range .items[*]}{.spec.containers[0].image}{"\n"}{end}' | sort -u
```

### Step 2: Prepare New Images

```bash
# Pull new versions
docker pull quay.io/argoproj/workflow-controller:v3.6.0

# Save images
docker save quay.io/argoproj/workflow-controller:v3.6.0 -o workflow-controller-v3.6.0.tar
```

### Step 3: Load and Push New Images

```bash
# Load image
docker load -i workflow-controller-v3.6.0.tar

# Tag for registry
docker tag quay.io/argoproj/workflow-controller:v3.6.0 \
  local-registry:5000/argoproj/workflow-controller:v3.6.0

# Push to registry
docker push local-registry:5000/argoproj/workflow-controller:v3.6.0
```

### Step 4: Update Deployment

```bash
# Update Helm values
helm upgrade argo-workflows ./argo-workflows-*.tgz \
  --set controller.image.tag=v3.6.0 \
  -n argo
```

## Chart Update Process

### Step 1: Download New Chart

```bash
# Pull new chart version
helm pull argo/argo-workflows --version 0.44.0
```

### Step 2: Review Changes

```bash
# Compare values
diff <(helm show values argo-workflows-0.43.1.tgz) \
     <(helm show values argo-workflows-0.44.0.tgz)
```

### Step 3: Update Values

Update your values file for new chart version.

### Step 4: Upgrade Release

```bash
helm upgrade argo-workflows ./argo-workflows-0.44.0.tgz \
  -f values.yaml \
  -n argo
```

## Rollback Strategies

### Helm Rollback

```bash
# List releases
helm history argo-workflows -n argo

# Rollback to previous version
helm rollback argo-workflows -n argo

# Rollback to specific revision
helm rollback argo-workflows 3 -n argo
```

### Image Rollback

```bash
# Update to previous image version
helm upgrade argo-workflows ./argo-workflows-*.tgz \
  --set controller.image.tag=v3.5.5 \
  -n argo
```

### Full Rollback

If complete rollback needed:
1. Restore previous bundle
2. Load previous images
3. Reinstall previous chart version
4. Verify functionality

## Testing Updates

### Pre-Deployment Testing

1. **Test in Non-Production Air-Gap**
   - Deploy updates to staging
   - Run full test suite
   - Verify all functionality

2. **Smoke Tests**
   - Basic functionality
   - Critical workflows
   - Integration points

3. **Performance Tests**
   - Resource usage
   - Response times
   - Throughput

### Post-Deployment Verification

```bash
# Check pod status
kubectl get pods -n argo

# Check logs for errors
kubectl logs -n argo -l app=workflow-controller

# Test workflows
kubectl apply -f test-workflow.yaml
kubectl get workflows -n argo

# Verify versions
kubectl get pods -n argo -o jsonpath='{range .items[*]}{.spec.containers[0].image}{"\n"}{end}'
```

## Version Management

### Documenting Versions

Keep a version manifest:

```yaml
# versions.yaml
components:
  argo-workflows:
    chart: 0.44.0
    controller: v3.6.0
    server: v3.6.0
    executor: v3.6.0
  registry:
    image: registry:2.8
```

### Version Tracking

- Git repository for version manifests
- Change logs for each update
- Approval records
- Test results

## Best Practices

1. **Plan Updates** - Schedule regular update windows
2. **Test First** - Always test in non-production
3. **Document Everything** - Versions, changes, test results
4. **Have Rollback Plan** - Know how to revert
5. **Minimize Changes** - Update only what's needed
6. **Verify Integrity** - Check checksums, signatures
7. **Monitor After Update** - Watch for issues

## Real-World Considerations

### Change Management

- Get approvals before updates
- Document all changes
- Follow customer change procedures
- Schedule maintenance windows

### Security Updates

- Prioritize security patches
- Fast-track critical vulnerabilities
- Test security updates thoroughly
- Document security improvements

### Compatibility

- Check compatibility matrices
- Test with existing workloads
- Verify API compatibility
- Plan for breaking changes

## Emergency Updates

For critical security issues:

1. **Fast-Track Approval** - Expedite approval process
2. **Minimal Bundle** - Only affected components
3. **Quick Testing** - Focus on critical functionality
4. **Rapid Deployment** - Use fastest transfer method
5. **Monitor Closely** - Watch for issues
6. **Full Update Later** - Plan complete update after emergency

## Next Steps

- [Image Mirroring Guide](./image-mirroring-guide.md) - How to mirror images
- [Offline Helm Guide](./offline-helm-guide.md) - How to package charts


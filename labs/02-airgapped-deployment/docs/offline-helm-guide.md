# Offline Helm Guide

Deep dive into packaging and using Helm charts in air-gapped environments.

## What is Helm Chart Packaging?

Helm charts are Kubernetes application packages. For air-gapped deployments, you need to download and package charts so they can be installed without internet access.

## Why Package Charts?

- **No Internet** - Cannot access Helm repositories
- **Version Control** - Lock specific chart versions
- **Reproducibility** - Same chart version every time
- **Security** - Review charts before deployment

## The Packaging Process

### Step 1: Add Helm Repository

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
```

### Step 2: Search for Charts

```bash
# List available charts
helm search repo argo

# List versions
helm search repo argo/argo-workflows --versions
```

### Step 3: Pull Chart

```bash
# Pull latest version
helm pull argo/argo-workflows

# Pull specific version
helm pull argo/argo-workflows --version 0.43.1

# Pull to specific directory
helm pull argo/argo-workflows --destination ./charts
```

### Step 4: Verify Chart

```bash
# Inspect chart
helm show chart argo-workflows-0.43.1.tgz

# Show values
helm show values argo-workflows-0.43.1.tgz

# Template chart (dry-run)
helm template test argo-workflows-0.43.1.tgz
```

### Step 5: Package Dependencies

If chart has dependencies:

```bash
# Download dependencies
helm dependency update

# Package with dependencies
helm package .
```

## Installing from Packaged Charts

### Basic Installation

```bash
# Install from local chart
helm install argo-workflows ./argo-workflows-0.43.1.tgz \
  -n argo --create-namespace
```

### With Custom Values

```bash
# Install with values file
helm install argo-workflows ./argo-workflows-0.43.1.tgz \
  -f values.yaml \
  -n argo --create-namespace
```

### With Overrides

```bash
# Install with inline overrides
helm install argo-workflows ./argo-workflows-0.43.1.tgz \
  --set controller.image.repository=local-registry:5000/argoproj/workflow-controller \
  -n argo --create-namespace
```

## Modifying Charts for Air-Gap

### Update Image References

Charts reference images that need to be changed for local registry:

**Original values.yaml:**
```yaml
controller:
  image:
    repository: quay.io/argoproj/workflow-controller
    tag: v3.5.5
```

**Modified for air-gap:**
```yaml
controller:
  image:
    repository: local-registry:5000/argoproj/workflow-controller
    tag: v3.5.5
```

### Using Values File Override

Instead of modifying the chart, use a values file:

```yaml
# airgap-values.yaml
controller:
  image:
    repository: local-registry:5000/argoproj/workflow-controller
    tag: v3.5.5
    pullPolicy: IfNotPresent

server:
  image:
    repository: local-registry:5000/argoproj/workflow-controller
    tag: v3.5.5
    pullPolicy: IfNotPresent
```

Then install:

```bash
helm install argo-workflows ./argo-workflows-0.43.1.tgz \
  -f airgap-values.yaml \
  -n argo --create-namespace
```

## Chart Dependencies

Some charts depend on other charts:

### Handling Dependencies

```bash
# Download dependencies
helm dependency update

# Package with dependencies
helm package .

# Or pull dependencies separately
helm pull stable/prometheus
helm pull stable/grafana
```

### Installing Dependencies

```bash
# Install dependencies first
helm install prometheus ./prometheus-*.tgz -n monitoring

# Then install main chart
helm install argo-workflows ./argo-workflows-*.tgz -n argo
```

## Verifying Chart Installation

```bash
# Check release
helm list -n argo

# Get release values
helm get values argo-workflows -n argo

# Get release manifest
helm get manifest argo-workflows -n argo

# Check status
helm status argo-workflows -n argo
```

## Updating Charts

### Download New Version

```bash
# Pull new version
helm pull argo/argo-workflows --version 0.44.0

# Compare versions
diff <(helm show values argo-workflows-0.43.1.tgz) \
     <(helm show values argo-workflows-0.44.0.tgz)
```

### Upgrade Installation

```bash
# Upgrade with new chart
helm upgrade argo-workflows ./argo-workflows-0.44.0.tgz \
  -f values.yaml \
  -n argo
```

## Common Issues

### Chart Not Found

**Problem:** Cannot find chart in repository

**Solutions:**
- Update repository: `helm repo update`
- Check repository URL is correct
- Verify chart name is correct
- Check if chart requires authentication

### Dependency Errors

**Problem:** Chart dependencies fail to download

**Solutions:**
- Download dependencies manually
- Update Chart.yaml dependencies
- Use `helm dependency update`
- Package dependencies separately

### Image Pull Errors After Install

**Problem:** Pods fail with ImagePullBackOff

**Solutions:**
- Verify image references in values.yaml
- Check images are in local registry
- Verify registry address is correct
- Check image pull policy

## Best Practices

1. **Version Pinning** - Always use specific chart versions
2. **Document Versions** - Keep list of chart versions used
3. **Review Charts** - Inspect charts before deployment
4. **Test Values** - Test with `helm template` before install
5. **Backup Values** - Save values files used for deployment

## Chart Repository Options

### Public Repositories
- Helm Hub / Artifact Hub
- GitHub releases
- Vendor repositories

### Private Repositories
- Harbor (supports Helm)
- Artifactory
- Nexus
- Simple HTTP server

## Real-World Considerations

### Enterprise Chart Management

For production:
- Use private chart repositories
- Implement chart signing
- Version control charts
- Review charts before deployment

### Chart Customization

- Fork charts for customizations
- Use values files for configuration
- Document all customizations
- Keep customizations minimal

## Next Steps

- [Image Mirroring Guide](./image-mirroring-guide.md) - Mirroring container images
- [Update Strategies](./update-strategies.md) - Updating without internet


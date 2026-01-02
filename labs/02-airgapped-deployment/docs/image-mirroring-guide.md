# Image Mirroring Guide

Deep dive into container image mirroring for air-gapped deployments.

## What is Image Mirroring?

Image mirroring is the process of copying container images from public registries (Docker Hub, Quay.io) to a private registry that's accessible in your air-gapped environment.

## Why Mirror Images?

- **Air-Gapped Access** - Public registries aren't accessible
- **Version Control** - Lock specific image versions
- **Security** - Scan images before deployment
- **Performance** - Faster pulls from local registry
- **Compliance** - Meet regulatory requirements

## The Mirroring Process

### Step 1: Identify Required Images

Start with the base image list:

```bash
cat modules/kubernetes/argo-workflows-airgap/images.txt
```

**For your application, you need to identify:**
- Application images
- Base images used by your application
- Sidecar containers
- Init containers
- Any dependencies

**How to find all images:**

```bash
# From Helm charts
helm template . | grep image: | sort -u

# From Kubernetes manifests
grep -r "image:" manifests/ | sort -u

# From running pods (if you have a test cluster)
kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{.spec.containers[*].image}{"\n"}{end}' | sort -u
```

### Step 2: Pull Images

```bash
# Single image
docker pull quay.io/argoproj/workflow-controller:v3.5.5

# From list
while IFS= read -r image; do
  [[ "$image" =~ ^#.*$ ]] && continue
  docker pull "$image"
done < images.txt
```

### Step 3: Save Images

```bash
# Single image
docker save quay.io/argoproj/workflow-controller:v3.5.5 -o workflow-controller.tar

# From list
while IFS= read -r image; do
  [[ "$image" =~ ^#.*$ ]] && continue
  safe_name=$(echo "$image" | sed 's/[\/:]/_/g')
  docker save "$image" -o "${safe_name}.tar"
done < images.txt
```

### Step 4: Transfer to Air-Gap

**USB Drive:**
```bash
# Copy tar files
cp *.tar /Volumes/USB-DRIVE/images/
```

**Network Transfer:**
```bash
scp *.tar user@airgap-machine:/path/to/images/
```

### Step 5: Load in Air-Gap

```bash
# Load image
docker load -i workflow-controller.tar

# Verify
docker images | grep workflow-controller
```

### Step 6: Tag for Local Registry

```bash
# Tag with registry address
docker tag quay.io/argoproj/workflow-controller:v3.5.5 \
  local-registry:5000/argoproj/workflow-controller:v3.5.5
```

### Step 7: Push to Local Registry

```bash
# Push to registry
docker push local-registry:5000/argoproj/workflow-controller:v3.5.5
```

## Complete Workflow Example

```bash
# Preparation (with internet)
docker pull quay.io/argoproj/workflow-controller:v3.5.5
docker save quay.io/argoproj/workflow-controller:v3.5.5 -o workflow-controller.tar

# Transfer to air-gap (USB, network, etc.)

# Deployment (air-gapped)
docker load -i workflow-controller.tar
docker tag quay.io/argoproj/workflow-controller:v3.5.5 \
  local-registry:5000/argoproj/workflow-controller:v3.5.5
docker push local-registry:5000/argoproj/workflow-controller:v3.5.5
```

## Image Naming Conventions

### Public Registry Format
```
registry.io/namespace/image:tag
quay.io/argoproj/workflow-controller:v3.5.5
```

### Local Registry Format
```
local-registry:5000/namespace/image:tag
local-registry:5000/argoproj/workflow-controller:v3.5.5
```

**Important:** Keep the namespace/image path the same to avoid manifest changes.

## Handling Multi-Architecture Images

Some images support multiple architectures (amd64, arm64):

```bash
# Inspect image architecture
docker manifest inspect quay.io/argoproj/workflow-controller:v3.5.5

# Pull specific architecture
docker pull --platform linux/amd64 quay.io/argoproj/workflow-controller:v3.5.5
```

## Image Size Optimization

Large images take longer to transfer and use more storage:

```bash
# Check image sizes
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# Use multi-stage builds to reduce size
# Use distroless images when possible
# Remove unnecessary layers
```

## Verifying Images

```bash
# List images in registry
curl http://local-registry:5000/v2/_catalog

# List tags for an image
curl http://local-registry:5000/v2/argoproj/workflow-controller/tags/list

# Verify image exists
docker pull local-registry:5000/argoproj/workflow-controller:v3.5.5
```

## Common Issues

### Image Pull Errors

**Problem:** Cannot pull image from public registry

**Solutions:**
- Check internet connection
- Verify image name and tag are correct
- Check if image requires authentication
- Try pulling manually to see error

### Image Save/Load Errors

**Problem:** Image save or load fails

**Solutions:**
- Check disk space: `df -h`
- Verify image exists: `docker images`
- Check file permissions
- Try with different filename (no special characters)

### Registry Push Errors

**Problem:** Cannot push to local registry

**Solutions:**
- Verify registry is running: `kubectl get pods -n registry`
- Check registry is accessible: `curl http://local-registry:5000/v2/`
- For Kind: Use port-forward
- Check registry logs: `kubectl logs -n registry deployment/local-registry`

## Best Practices

1. **Version Pinning** - Always use specific tags, not `latest`
2. **Document Versions** - Keep a list of all image versions
3. **Verify Integrity** - Use checksums to verify image integrity
4. **Test First** - Test image loading in non-production first
5. **Update Strategy** - Plan how to update images without internet

## Real-World Considerations

### Production Registries

For production, use enterprise registries:
- **Harbor** - Full-featured with UI, scanning, replication
- **Artifactory** - Enterprise artifact management
- **Nexus** - Repository manager

### Image Scanning

Before deploying to air-gap:
1. Scan images for vulnerabilities
2. Review scan results
3. Update vulnerable images
4. Re-scan before deployment

### Image Signing

For security:
1. Sign images with cosign or similar
2. Verify signatures in air-gap
3. Only deploy signed images

## Next Steps

- [Offline Helm Guide](./offline-helm-guide.md) - Packaging Helm charts
- [Update Strategies](./update-strategies.md) - Updating without internet


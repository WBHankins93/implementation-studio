# Lab 02 Troubleshooting

Common issues and solutions for air-gapped deployment.

## Preparation Phase Issues

### Images Fail to Pull

**Symptoms:**
- `docker pull` fails
- Network timeout errors
- Authentication errors

**Solutions:**

```bash
# Check internet connection
ping google.com

# Verify Docker is running
docker ps

# Try pulling manually
docker pull quay.io/argoproj/workflow-controller:v3.5.5

# Check if image requires authentication
# Some images may require login:
docker login quay.io

# Verify image name and tag are correct
# Check images.txt for correct format
```

**Common Causes:**
- No internet connection
- Incorrect image name/tag
- Docker Hub rate limiting
- Image requires authentication
- Registry is down

### Insufficient Disk Space

**Symptoms:**
- `docker save` fails
- "No space left on device" error

**Solutions:**

```bash
# Check disk space
df -h .

# Free up space
docker system prune -a

# Use external drive
export OUTPUT_DIR=/path/to/external/drive/images
./mirror-images.sh

# Check image sizes
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
```

### Helm Chart Download Fails

**Symptoms:**
- `helm pull` fails
- Repository not found errors

**Solutions:**

```bash
# Update Helm repositories
helm repo update

# Verify repository exists
helm repo list

# Try adding repository again
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Pull manually to see error
helm pull argo/argo-workflows --debug
```

## Deployment Phase Issues

### Registry Not Accessible

**Symptoms:**
- Cannot push images to registry
- Connection refused errors
- Image pull errors from registry

**Solutions:**

```bash
# Check registry is running
kubectl get pods -n registry
kubectl logs -n registry deployment/local-registry

# Check registry service
kubectl get svc -n registry
kubectl describe svc local-registry -n registry

# For Kind clusters, port-forward may be needed
kubectl port-forward svc/local-registry 5000:5000 -n registry &

# Then use localhost:5000 as registry
export REGISTRY=localhost:5000
./load-images.sh

# Test registry connectivity
curl http://local-registry.registry.svc.cluster.local:5000/v2/
```

### Images Fail to Load

**Symptoms:**
- `docker load` fails
- Image not found errors
- Tar file corruption

**Solutions:**

```bash
# Verify tar files exist
ls -lh images/

# Check tar file integrity
file images/*.tar

# Try loading manually
docker load -i images/quay_io_argoproj_workflow-controller_v3.5.5.tar

# Verify image loaded
docker images | grep workflow-controller

# Check for disk space
df -h .
```

### Images Fail to Push

**Symptoms:**
- `docker push` fails
- Connection refused
- Authentication errors

**Solutions:**

```bash
# Verify registry is accessible
curl http://local-registry:5000/v2/

# For insecure registries (local), may need to configure Docker
# Edit /etc/docker/daemon.json (Linux) or Docker Desktop settings (Mac)
{
  "insecure-registries": ["localhost:5000", "local-registry:5000"]
}

# Restart Docker after configuration change

# Verify image is tagged correctly
docker images | grep local-registry

# Try pushing manually
docker push local-registry:5000/argoproj/workflow-controller:v3.5.5
```

### Argo Workflows Pods Stuck in ImagePullBackOff

**Symptoms:**
- Pods not starting
- ImagePullBackOff status
- Cannot pull image errors

**Solutions:**

```bash
# Check pod status
kubectl get pods -n argo
kubectl describe pod <pod-name> -n argo

# Check events
kubectl get events -n argo --sort-by='.lastTimestamp'

# Verify images are in registry
kubectl exec -n registry deployment/local-registry -- \
  ls /var/lib/registry/docker/registry/v2/repositories/

# Check image names in values file match registry
cat ../../modules/kubernetes/argo-workflows-airgap/helm-values.yaml | grep image

# Verify registry address is correct
# Should be: local-registry.registry.svc.cluster.local:5000
# Or for Kind: localhost:5000 (with port-forward)

# Check network policies allow registry access
kubectl get networkpolicies -n argo
```

### Pods Using Wrong Images

**Symptoms:**
- Pods running but using public registry images
- Not using local registry

**Solutions:**

```bash
# Check what images pods are using
kubectl get pods -n argo -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[0].image}{"\n"}{end}'

# Verify Helm values
helm get values argo-workflows -n argo

# Upgrade with correct image references
helm upgrade argo-workflows ./charts/argo-workflows-*.tgz \
  --set controller.image.repository=local-registry:5000/argoproj/workflow-controller \
  --set server.image.repository=local-registry:5000/argoproj/workflow-controller \
  -n argo
```

### External Access Still Works

**Symptoms:**
- Can still access internet from pods
- Air-gap not enforced

**Solutions:**

```bash
# Check network policies
kubectl get networkpolicies --all-namespaces
kubectl describe networkpolicy deny-all-egress -n default

# Verify network policies are blocking
kubectl run test --image=busybox --rm -it --restart=Never -- wget -O- https://www.google.com
# Should fail

# Reapply network policies if needed
kubectl apply -f <network-policy-file>

# For Kind, verify cluster configuration
kind get clusters
kubectl get nodes
```

### Workflows Fail to Execute

**Symptoms:**
- Workflows created but not running
- Workflow pods failing
- Executor errors

**Solutions:**

```bash
# Check workflow status
kubectl get workflows -n argo
kubectl describe workflow <workflow-name> -n argo

# Check workflow controller logs
kubectl logs -n argo -l app=workflow-controller

# Check executor logs
kubectl logs -n argo <workflow-pod-name>

# Verify executor image is in registry
# Executor may need different image
kubectl get workflows <workflow-name> -n argo -o yaml | grep image

# Check resource quotas
kubectl get resourcequota -n argo
kubectl describe resourcequota -n argo
```

## Kind-Specific Issues

### Kind Cluster Creation Fails

**Symptoms:**
- `kind create cluster` fails
- Timeout errors

**Solutions:**

```bash
# Check Docker is running
docker ps

# Check available resources
docker info | grep -i memory
docker info | grep -i cpu

# Try with more resources
# Edit kind-config.yaml to reduce node count

# Delete and recreate
kind delete cluster --name airgap-simulation
kind create cluster --name airgap-simulation --config kind-config.yaml
```

### Cannot Access Registry from Host

**Symptoms:**
- Cannot push images from host to Kind registry

**Solutions:**

```bash
# Port-forward registry
kubectl port-forward svc/local-registry 5000:5000 -n registry &

# Use localhost:5000
export REGISTRY=localhost:5000
./load-images.sh

# Or load images directly into Kind
kind load image-archive images/*.tar --name airgap-simulation
```

## General Debugging Commands

### Check Cluster Status

```bash
# Nodes
kubectl get nodes -o wide

# All pods
kubectl get pods --all-namespaces

# Services
kubectl get svc --all-namespaces

# Events
kubectl get events --all-namespaces --sort-by='.lastTimestamp'
```

### Check Registry

```bash
# Registry pods
kubectl get pods -n registry

# Registry service
kubectl get svc -n registry

# Registry logs
kubectl logs -n registry deployment/local-registry

# Test registry
curl http://local-registry.registry.svc.cluster.local:5000/v2/_catalog
```

### Check Argo Workflows

```bash
# Argo pods
kubectl get pods -n argo

# Argo services
kubectl get svc -n argo

# Controller logs
kubectl logs -n argo -l app=workflow-controller

# Server logs
kubectl logs -n argo -l app=argo-workflows-server
```

### Verify Air-Gap

```bash
# Test external access (should fail)
kubectl run test --image=busybox --rm -it --restart=Never -- wget -O- https://www.google.com

# Or use verification script
./scripts/verify-airgap.sh
```

## Getting Help

If you're stuck:

1. **Check Logs** - Most issues show up in logs
2. **Review Events** - Kubernetes events show what's happening
3. **Verify Configuration** - Check values files, manifests
4. **Test Components** - Test registry, images, charts separately
5. **Start Fresh** - Sometimes clean slate helps

## Common Patterns

### Pattern: Image Pull Always Fails

**Likely Cause:** Registry not accessible or image not in registry

**Fix:**
1. Verify registry is running
2. Check images are loaded
3. Verify image names match
4. Check network policies

### Pattern: Everything Works But No Internet Block

**Likely Cause:** Network policies not applied correctly

**Fix:**
1. Check network policies exist
2. Verify policies block egress
3. Test with verification script
4. Reapply policies if needed

### Pattern: Works in Lab But Not in Production

**Likely Cause:** Production environment differences

**Fix:**
1. Compare environments
2. Check registry configuration
3. Verify network policies
4. Review production-specific requirements


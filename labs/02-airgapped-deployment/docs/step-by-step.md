# Lab 02: Step-by-Step Guide

Complete walkthrough of the air-gapped deployment process.

## Phase 1: Preparation (With Internet)

### Step 1: Prerequisites Check

```bash
# Check tools are installed
docker --version
kind --version
helm version
kubectl version --client

# Check disk space (need ~10GB)
df -h .

# Check Docker is running
docker ps
```

### Step 2: Navigate to Preparation Directory

```bash
cd labs/02-airgapped-deployment/preparation
```

### Step 3: Mirror Container Images

This pulls all required images and saves them as tar files.

```bash
./mirror-images.sh
```

**What happens:**
1. Script reads `modules/kubernetes/argo-workflows-airgap/images.txt`
2. For each image:
   - Pulls from Docker Hub/Quay.io
   - Saves as tar file in `images/` directory
3. Shows progress for each image

**Expected output:**
```
🖼️  Mirroring container images for air-gapped deployment
[1] Processing: quay.io/argoproj/workflow-controller:v3.5.5
    📥 Pulling image...
    💾 Saving to: images/quay_io_argoproj_workflow-controller_v3.5.5.tar
    ✅ Saved successfully
...
✅ Image mirroring complete!
```

**Time:** 10-25 minutes (depends on internet speed)

**Verify:**
```bash
ls -lh images/
# Should see multiple .tar files
```

### Step 4: Package Helm Charts

This downloads and packages Helm charts for offline use.

```bash
./package-helm.sh
```

**What happens:**
1. Adds Argo Helm repository
2. Downloads latest Argo Workflows chart
3. Packages as .tgz file in `charts/` directory

**Expected output:**
```
📦 Packaging Helm charts for offline installation
📥 Adding Helm repositories...
📦 Packaging Argo Workflows chart...
    Version: 0.43.1
    ✅ Chart packaged successfully
```

**Time:** 1-2 minutes

**Verify:**
```bash
ls -lh charts/
# Should see argo-workflows-*.tgz
```

### Step 5: Create Deployment Bundle

This packages everything into a complete bundle.

```bash
./create-bundle.sh
```

**What happens:**
1. Creates bundle directory with timestamp
2. Copies all images to bundle
3. Copies all charts to bundle
4. Copies deployment scripts
5. Creates checksums for verification
6. Creates bundle README

**Expected output:**
```
📦 Creating deployment bundle for air-gapped environment
📁 Creating bundle structure...
📋 Copying images...
    ✅ Copied 5 image files
📋 Copying Helm charts...
    ✅ Copied 1 chart files
...
✅ Bundle created successfully!
Bundle location: preparation/airgap-deployment-bundle-20260105-143022
Total size: 2.5G
```

**Time:** 1-2 minutes

**Verify:**
```bash
ls -lh airgap-deployment-bundle-*/
# Should see: images/, charts/, scripts/, manifests/, checksums.txt, README.md
```

### Step 6: Verify Bundle Integrity

```bash
cd airgap-deployment-bundle-*
sha256sum -c checksums.txt
# All files should show "OK"
```

### Step 7: Transfer Bundle (For Real Air-Gap)

**USB Drive:**
```bash
# Copy bundle to USB
cp -r airgap-deployment-bundle-* /Volumes/USB-DRIVE/

# On air-gapped machine, copy from USB
cp -r /Volumes/USB-DRIVE/airgap-deployment-bundle-* ~/
```

**Network Transfer (if available):**
```bash
# From preparation machine
scp -r airgap-deployment-bundle-* user@airgap-machine:/path/to/destination/

# Verify on air-gapped machine
sha256sum -c checksums.txt
```

**For Lab (Local Simulation):**
- Skip transfer step
- Bundle is already on your machine

---

## Phase 2: Deployment (Air-Gapped)

### Step 1: Setup Air-Gap Simulation (Local Testing)

For local testing, create a Kind cluster that simulates air-gap.

```bash
cd ../local-simulation
./setup-airgap-sim.sh
```

**What happens:**
1. Creates Kind cluster named `airgap-simulation`
2. Applies network policies to block external access
3. Creates `argo` and `registry` namespaces
4. Configures cluster for air-gap simulation

**Expected output:**
```
🚀 Setting up Kind cluster for air-gap simulation
📦 Creating Kind cluster...
✅ Cluster created successfully
🔒 Applying network policies...
✅ Network policies applied
✅ Air-gap simulation setup complete!
```

**Time:** 5-10 minutes

**Verify:**
```bash
kubectl get nodes
kubectl get networkpolicies --all-namespaces
```

**For Real Air-Gapped Environment:**
- Skip this step
- Use your existing air-gapped Kubernetes cluster
- Ensure network policies block external egress

### Step 2: Configure kubectl Context

```bash
# For Kind cluster
export KUBECONFIG=$(kind get kubeconfig-path --name airgap-simulation)
kubectl config use-context kind-airgap-simulation

# Verify
kubectl get nodes
```

### Step 3: Deploy Local Registry

Deploy a Docker registry inside your cluster.

```bash
cd ../deployment
./deploy-registry.sh
```

**What happens:**
1. Creates `registry` namespace
2. Deploys Docker registry deployment
3. Creates registry service
4. Waits for registry to be ready

**Expected output:**
```
📦 Deploying local container registry
📋 Applying registry manifests...
⏳ Waiting for registry to be ready...
✅ Registry deployed successfully!

Registry endpoint: 10.96.0.1:5000
Registry service: local-registry.registry.svc.cluster.local:5000
```

**Time:** 2-3 minutes

**Verify:**
```bash
kubectl get pods -n registry
kubectl get svc -n registry
```

### Step 4: Load Images into Registry

Load images from bundle into the local registry.

**Important for Kind:** You may need to port-forward the registry first:

```bash
# In a separate terminal, port-forward registry
kubectl port-forward svc/local-registry 5000:5000 -n registry &
```

Then set registry to localhost:

```bash
export REGISTRY=localhost:5000
./load-images.sh
```

**What happens:**
1. Reads image tar files from bundle
2. Loads each image into Docker
3. Tags images with registry address
4. Pushes images to local registry

**Expected output:**
```
📥 Loading container images into local registry
[1] Processing: quay_io_argoproj_workflow-controller_v3.5.5.tar
    📥 Loading image...
    🏷️  Tagging as: localhost:5000/quay.io/argoproj/workflow-controller:v3.5.5
    📤 Pushing to registry...
    ✅ Successfully pushed
...
✅ Image loading complete!
```

**Time:** 10-20 minutes (depends on image sizes)

**Verify:**
```bash
# Check registry has images
kubectl exec -n registry deployment/local-registry -- ls /var/lib/registry/docker/registry/v2/repositories/
```

### Step 5: Deploy Argo Workflows

Install Argo Workflows using local charts and images.

```bash
./deploy-argo.sh
```

**What happens:**
1. Creates `argo` namespace
2. Finds packaged Helm chart
3. Updates values file with registry address
4. Installs Argo Workflows from local chart
5. Uses images from local registry
6. Waits for deployment to be ready

**Expected output:**
```
⚙️  Deploying Argo Workflows from local images
📦 Found chart: argo-workflows-0.43.1.tgz
📝 Creating namespace...
📋 Installing Argo Workflows...
✅ Argo Workflows installed successfully
⏳ Waiting for Argo Workflows to be ready...
✅ Argo Workflows deployment complete!
```

**Time:** 5-10 minutes

**Verify:**
```bash
kubectl get pods -n argo
kubectl get svc -n argo
```

### Step 6: Validate Deployment

Verify everything is working correctly.

```bash
./validate.sh
```

**What it checks:**
- Namespaces exist
- Registry is running
- Argo Workflows components are ready
- Pods are using local registry images
- External access is blocked

**Expected output:**
```
🔍 Validating air-gapped deployment
📦 Checking namespaces...
✅ Namespace 'argo' exists
✅ Namespace 'registry' exists
...
✅ Validation complete!
```

### Step 7: Verify Air-Gap

Confirm that external access is blocked.

```bash
# This should FAIL (proving we're air-gapped)
kubectl run test --image=busybox --rm -it --restart=Never -- wget -O- https://www.google.com

# Expected: Connection refused or timeout
```

Or use the verification script:

```bash
../scripts/verify-airgap.sh
```

### Step 8: Test Argo Workflows

Submit a test workflow to verify everything works.

```bash
# Submit test workflow
kubectl apply -f ../../reference-app/workflows/hello-world.yaml

# Check workflow status
kubectl get workflows -n argo

# View workflow details
kubectl describe workflow hello-world -n argo

# View logs
kubectl logs -n argo -l app=workflow-controller
```

**Expected:**
- Workflow should be created
- Workflow should execute successfully
- No image pull errors
- Workflow completes

### Step 9: Access Argo UI (Optional)

Since we're air-gapped, use port-forward to access the UI:

```bash
kubectl port-forward svc/argo-workflows-server 2746:2746 -n argo
```

Then open: http://localhost:2746

---

## Troubleshooting Steps

If something fails:

1. **Check pod status:**
   ```bash
   kubectl get pods --all-namespaces
   kubectl describe pod <pod-name> -n <namespace>
   ```

2. **Check logs:**
   ```bash
   kubectl logs <pod-name> -n <namespace>
   ```

3. **Check events:**
   ```bash
   kubectl get events --all-namespaces --sort-by='.lastTimestamp'
   ```

4. **Verify registry:**
   ```bash
   kubectl get svc -n registry
   kubectl logs -n registry deployment/local-registry
   ```

5. **Check network policies:**
   ```bash
   kubectl get networkpolicies --all-namespaces
   ```

See [Troubleshooting Guide](./troubleshooting.md) for detailed solutions.

---

## Success Criteria

You've successfully completed the lab when:

- ✅ All images are loaded into local registry
- ✅ Argo Workflows is deployed and running
- ✅ All pods are using local registry images
- ✅ External internet access is blocked
- ✅ Test workflow executes successfully
- ✅ No image pull errors in pod logs

---

## Next Steps

After completing this lab:

1. Review the patterns learned
2. Experiment with different workflows
3. Read about update strategies
4. Understand how to apply this to real engagements
5. Proceed to Lab 03: Private Network Deployment


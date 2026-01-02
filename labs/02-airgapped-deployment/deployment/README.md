# Deployment Phase: Air-Gapped Environment

This phase is performed in an **air-gapped environment** (no internet access). You'll deploy Argo Workflows using the bundle prepared in the preparation phase.

## Overview

The deployment phase involves:
1. **Setup Air-Gap Simulation** - Create Kind cluster with network policies (for lab)
2. **Deploy Registry** - Deploy local container registry
3. **Load Images** - Load images from bundle into registry
4. **Deploy Argo** - Install Argo Workflows from local charts and images
5. **Validate** - Verify deployment works without internet

## Prerequisites

- Deployment bundle transferred from preparation phase
- Kind installed (for local simulation)
- kubectl configured
- Docker installed and running
- Helm 3.x installed

## Quick Start

### Option 1: Using Main Setup Script

```bash
cd labs/02-airgapped-deployment
./scripts/setup.sh
# Choose option 2 (Deployment Phase)
```

### Option 2: Manual Steps

```bash
cd labs/02-airgapped-deployment/deployment

# Step 1: Setup air-gap simulation (if using Kind)
cd ../local-simulation
./setup-airgap-sim.sh
cd ../deployment

# Step 2: Deploy registry
./deploy-registry.sh

# Step 3: Load images
./load-images.sh

# Step 4: Deploy Argo Workflows
./deploy-argo.sh

# Step 5: Validate
./validate.sh
```

## Detailed Steps

### Step 1: Setup Air-Gap Simulation (Local Testing)

For local testing, set up a Kind cluster that simulates air-gap:

```bash
cd local-simulation
./setup-airgap-sim.sh
```

This creates a Kind cluster with network policies blocking external access.

**For Real Air-Gapped Environments:**
- Skip this step
- Use your existing air-gapped Kubernetes cluster
- Ensure network policies block external egress

### Step 2: Deploy Local Registry

Deploy a Docker registry inside your cluster:

```bash
./deploy-registry.sh
```

**What it does:**
- Creates `registry` namespace
- Deploys Docker registry deployment
- Creates registry service
- Waits for registry to be ready

**Registry Endpoint:**
- Service: `local-registry.registry.svc.cluster.local:5000`
- ClusterIP: Available via `kubectl get svc -n registry`

### Step 3: Load Images into Registry

Load images from the bundle into the local registry:

```bash
./load-images.sh
```

**What it does:**
- Reads image tar files from bundle
- Loads each image into Docker
- Tags images with registry address
- Pushes images to local registry

**Requirements:**
- Images directory from bundle must be accessible
- Docker must be able to access the cluster registry
- For Kind: Use port-forward or load directly

**For Kind Clusters:**
You may need to port-forward the registry:

```bash
kubectl port-forward svc/local-registry 5000:5000 -n registry &
```

Then set registry to localhost:

```bash
export REGISTRY=localhost:5000
./load-images.sh
```

### Step 4: Deploy Argo Workflows

Install Argo Workflows using local charts and images:

```bash
./deploy-argo.sh
```

**What it does:**
- Creates `argo` namespace
- Installs Argo Workflows from packaged Helm chart
- Uses images from local registry
- Configures for air-gapped operation
- Waits for deployment to be ready

### Step 5: Validate Deployment

Verify everything is working:

```bash
./validate.sh
```

**What it checks:**
- Namespaces exist
- Registry is running
- Argo Workflows components are ready
- Pods are using local registry images
- External access is blocked

## Testing the Deployment

### Submit a Test Workflow

```bash
# Submit a simple workflow
kubectl apply -f ../../reference-app/workflows/hello-world.yaml

# Check workflow status
kubectl get workflows -n argo

# View workflow details
kubectl describe workflow hello-world -n argo

# View workflow logs
kubectl logs -n argo -l app=workflow-controller
```

### Access Argo UI

Since we're air-gapped, use port-forward:

```bash
kubectl port-forward svc/argo-workflows-server 2746:2746 -n argo
```

Then open: http://localhost:2746

## Troubleshooting

### Images Fail to Load

**Problem:** Cannot push images to registry

**Solutions:**
- Verify registry is running: `kubectl get pods -n registry`
- Check registry logs: `kubectl logs -n registry deployment/local-registry`
- For Kind: Use port-forward and set REGISTRY=localhost:5000
- Verify images directory exists and contains tar files

### Argo Workflows Pods Not Starting

**Problem:** Pods stuck in ImagePullBackOff

**Solutions:**
- Verify images are in registry: `kubectl exec -n registry deployment/local-registry -- ls /var/lib/registry`
- Check image names match in helm-values.yaml
- Verify registry address is correct
- Check pod events: `kubectl describe pod <pod-name> -n argo`

### External Access Still Works

**Problem:** Can still access internet from pods

**Solutions:**
- Verify network policies: `kubectl get networkpolicies --all-namespaces`
- Check Kind cluster configuration
- Verify no egress rules allow external access
- Run verify-airgap.sh script

## Next Steps

After successful deployment:

1. **Test Workflows** - Submit sample workflows
2. **Explore UI** - Access Argo Workflows UI via port-forward
3. **Understand Patterns** - Review how images and charts were packaged
4. **Real-World Application** - See README.md for how to use in real engagements

## Real Air-Gapped Environments

For real air-gapped deployments:

1. **Transfer Bundle** - Use approved transfer method (USB, secure network, etc.)
2. **Verify Integrity** - Check checksums before deployment
3. **Follow Same Steps** - Use same deployment process
4. **Document Changes** - Note any modifications needed for your environment
5. **Update Strategies** - Plan how to update without internet (see docs/update-strategies.md)


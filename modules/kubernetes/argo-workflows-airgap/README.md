# Argo Workflows Air-Gap Module

## What is This?

This module provides the configuration and tools needed to deploy Argo Workflows in an air-gapped (offline) environment. It includes image lists, Helm chart packaging scripts, and modified configurations for private container registries.

## When to Use This Module

- Deploying Argo Workflows in environments without internet access
- Working with air-gapped Kubernetes clusters
- Preparing offline deployment packages
- Learning air-gap deployment patterns

## Files

- `images.txt` - Complete list of required container images
- `helm-values.yaml` - Helm values configured for private registry
- `package-charts.sh` - Script to package Helm charts for offline use
- `README.md` - This documentation

## Usage

### Step 1: Package Helm Charts

```bash
cd modules/kubernetes/argo-workflows-airgap
./package-charts.sh
```

This creates a `charts/` directory with packaged Helm charts.

### Step 2: Mirror Images

Use the `images.txt` file with your image mirroring script:

```bash
# In your preparation environment (with internet)
while IFS= read -r image; do
  [[ "$image" =~ ^#.*$ ]] && continue  # Skip comments
  docker pull "$image"
  docker save "$image" -o "images/$(echo $image | tr '/:' '_').tar"
done < images.txt
```

### Step 3: Deploy in Air-Gapped Environment

1. Transfer charts and images to air-gapped environment
2. Load images into local registry
3. Install using packaged charts with modified values

## Image Registry Configuration

The `helm-values.yaml` is pre-configured to use a local registry at `local-registry:5000`. 

**Important:** You must:
1. Tag images with your registry prefix before loading
2. Update the registry address in helm-values.yaml if different
3. Ensure the registry is accessible from your cluster

## Harbor Notes

While this module uses Docker Registry by default, Harbor is a common choice for production air-gapped environments:

**Harbor Advantages:**
- Web UI for image management
- Vulnerability scanning
- Image replication and synchronization
- RBAC and project-based organization
- Better suited for large-scale deployments

**When to Consider Harbor:**
- Multiple air-gapped environments to manage
- Need vulnerability scanning
- Require image replication between sites
- Need fine-grained access control

**Harbor Migration:**
To use Harbor instead of Docker Registry:
1. Deploy Harbor in your air-gapped environment
2. Update registry address in helm-values.yaml
3. Use Harbor's replication features for image sync
4. Configure Harbor projects for organization

For Harbor-specific deployment, see Harbor documentation for detailed setup instructions.

## Learn More

- [Argo Workflows Documentation](https://argoproj.github.io/workflows/)
- [Docker Registry Documentation](https://docs.docker.com/registry/)
- [Harbor Documentation](https://goharbor.io/docs/)


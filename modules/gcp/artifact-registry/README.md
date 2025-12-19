# Artifact Registry Module

## What is This?

This module creates a Docker container registry in Google Artifact Registry. Artifact Registry is GCP's service for storing and managing container images, similar to Docker Hub but integrated with GCP services.

## When to Use This Module

- Need to store container images for your applications
- Want images close to your GKE clusters (faster pulls)
- Require integration with GCP IAM for access control
- Building CI/CD pipelines that push images

## What It Creates

- **Artifact Registry Repository**: A Docker registry where you can push/pull images
- **IAM Bindings** (optional): Grants GKE service accounts permission to pull images

## How It Works

```
Developer/CI
   │
   ▼
┌─────────────────────────────┐
│  docker push                │
│  <registry-url>/image:tag   │
└─────────────────────────────┘
   │
   ▼
┌─────────────────────────────┐
│  Artifact Registry          │
│  - Stores images            │
│  - Manages versions         │
│  - Handles access control   │
└─────────────────────────────┘
   │
   ▼
┌─────────────────────────────┐
│  GKE Cluster                │
│  - Pulls images on demand   │
│  - Uses IAM for auth        │
└─────────────────────────────┘
```

## Features

- **Docker Registry**: Standard Docker registry API
- **IAM Integration**: Use GCP IAM for access control
- **Regional**: Store images close to your workloads
- **Versioning**: Automatic version management
- **Vulnerability Scanning**: Optional security scanning

## Usage

### Basic Example

```hcl
module "artifact_registry" {
  source = "../../modules/gcp/artifact-registry"
  
  project_id    = var.project_id
  region        = "us-central1"
  repository_id = "my-app-images"
}
```

### With GKE Service Account Access

```hcl
module "artifact_registry" {
  source = "../../modules/gcp/artifact-registry"
  
  project_id    = var.project_id
  region        = "us-central1"
  repository_id = "my-app-images"
  
  # Grant GKE nodes permission to pull images
  gke_service_account = module.gke_cluster.node_service_account_email
}
```

## Working with Images

### Authenticate Docker

```bash
gcloud auth configure-docker <region>-docker.pkg.dev
```

### Push an Image

```bash
# Tag your image
docker tag my-app:latest \
  <region>-docker.pkg.dev/<project-id>/<repository-id>/my-app:latest

# Push
docker push \
  <region>-docker.pkg.dev/<project-id>/<repository-id>/my-app:latest
```

### Pull an Image

```bash
docker pull \
  <region>-docker.pkg.dev/<project-id>/<repository-id>/my-app:latest
```

### Use in Kubernetes

```yaml
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: my-app
    image: <region>-docker.pkg.dev/<project-id>/<repository-id>/my-app:latest
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | GCP project ID | `string` | n/a | yes |
| region | GCP region for the registry | `string` | n/a | yes |
| repository_id | Unique repository identifier | `string` | n/a | yes |
| description | Human-readable description | `string` | `"Container image repository"` | no |
| labels | Key-value labels | `map(string)` | `{}` | no |
| gke_service_account | GKE SA email for IAM binding | `string` | `null` | no |

**Repository ID Rules:**
- Lowercase letters, numbers, hyphens, underscores
- Must start with a letter
- 4-63 characters

## Outputs

| Name | Description | Usage |
|------|-------------|-------|
| repository_id | Repository identifier | For reference |
| repository_name | Full repository name | For API calls |
| repository_url | Full Docker registry URL | For `docker push/pull` commands |

**Example Output:**
```
repository_url = "us-central1-docker.pkg.dev/my-project/my-repo"
```

## Prerequisites

Before using this module:

1. **Enable API**:
   ```bash
   gcloud services enable artifactregistry.googleapis.com
   ```

2. **IAM Permissions**: Your account needs:
   - `roles/artifactregistry.admin` (to create)
   - `roles/artifactregistry.writer` (to push)
   - `roles/artifactregistry.reader` (to pull)

## Cost Considerations

- **Storage**: ~$0.10/GB/month
- **Operations**: Free (push/pull operations)
- **Network Egress**: Standard GCP egress pricing

**Tip**: Delete old image versions regularly to reduce storage costs.

## Security Best Practices

1. **Use IAM**: Grant minimal permissions (reader for pull, writer for push)
2. **Private Registry**: Keep images private (default)
3. **Vulnerability Scanning**: Enable scanning for production images
4. **Service Accounts**: Use service accounts instead of user accounts when possible

## Troubleshooting

### Cannot Push Image

- Verify authentication: `gcloud auth configure-docker`
- Check IAM permissions: `gcloud artifacts repositories get-iam-policy <repo>`
- Verify repository exists: `gcloud artifacts repositories list`

### GKE Cannot Pull Images

- Verify service account has `roles/artifactregistry.reader`
- Check image URL is correct
- Ensure repository is in same region as cluster (for performance)

### Authentication Errors

```bash
# Re-authenticate
gcloud auth login
gcloud auth configure-docker <region>-docker.pkg.dev
```

## Related Modules

- `gke-cluster` - Clusters that pull images from this registry

## Learn More

- [Artifact Registry Documentation](https://cloud.google.com/artifact-registry/docs)
- [Docker Registry Guide](https://cloud.google.com/artifact-registry/docs/docker)
- [IAM and Access Control](https://cloud.google.com/artifact-registry/docs/access-control)


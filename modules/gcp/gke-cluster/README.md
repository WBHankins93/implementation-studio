# GKE Cluster Module

## What is This?

This module creates a production-ready Google Kubernetes Engine (GKE) cluster. GKE is Google's managed Kubernetes service that provides a fully managed environment for deploying, managing, and scaling containerized applications.

## When to Use This Module

- Deploying Kubernetes workloads on GCP
- Need a managed Kubernetes service (no master node management)
- Require integration with other GCP services
- Want production-ready defaults (auto-repair, auto-upgrade, monitoring)

## What It Creates

- **GKE Cluster**: A Kubernetes cluster with a managed control plane
- **Node Pool**: Worker nodes that run your workloads
- **Service Account**: IAM service account for nodes with appropriate permissions
- **Network Configuration**: Integrates with your VPC network

## Features

- **Private Node Pools**: Nodes have no external IPs (more secure)
- **Configurable Endpoint**: Public or private API endpoint
- **Network Policy**: Kubernetes network policies enabled
- **Workload Identity**: Secure service account access
- **Auto-Repair**: Automatically repairs unhealthy nodes
- **Auto-Upgrade**: Automatically upgrades node software
- **Node Autoscaling**: Automatically scales nodes based on demand
- **VPC-Native**: Uses GCP VPC networking (better performance)

## How It Works

1. Creates a service account for GKE nodes with necessary permissions
2. Provisions the GKE cluster with your specified configuration
3. Creates a node pool with your specified machine type and count
4. Configures auto-scaling, auto-repair, and auto-upgrade
5. Enables logging and monitoring integration

## Usage

### Basic Example

```hcl
module "gke_cluster" {
  source = "../../modules/gcp/gke-cluster"
  
  project_id     = var.project_id
  cluster_name   = "my-cluster"
  region         = "us-central1"
  network        = module.vpc.network_name
  subnetwork     = module.vpc.private_subnet_name
  
  node_count     = 2
  machine_type   = "e2-medium"
  min_node_count = 1
  max_node_count = 5
}
```

### With Private Endpoint

```hcl
module "gke_cluster" {
  source = "../../modules/gcp/gke-cluster"
  
  # ... other variables ...
  
  private_endpoint = true  # Cluster API only accessible from VPC
}
```

### With Custom Labels

```hcl
module "gke_cluster" {
  source = "../../modules/gcp/gke-cluster"
  
  # ... other variables ...
  
  resource_labels = {
    environment = "production"
    team        = "platform"
    cost-center = "engineering"
  }
}
```

## Prerequisites

Before using this module, ensure:

1. **GCP Project**: Project with billing enabled
2. **IAM Permissions**: Your account needs:
   - `roles/container.admin` (or equivalent)
   - `roles/iam.serviceAccountUser`
   - `roles/compute.admin` (for network resources)
3. **VPC Network**: A VPC network and subnet must exist (use `vpc-standard` module)
4. **APIs Enabled**:
   ```bash
   gcloud services enable \
     container.googleapis.com \
     compute.googleapis.com \
     logging.googleapis.com \
     monitoring.googleapis.com
   ```

## Inputs

See `variables.tf` for complete list. Key variables:

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | GCP project ID | `string` | n/a | yes |
| cluster_name | Name of the GKE cluster | `string` | n/a | yes |
| region | GCP region | `string` | n/a | yes |
| network | VPC network name | `string` | n/a | yes |
| subnetwork | Subnet name | `string` | n/a | yes |
| private_endpoint | Enable private endpoint (private cluster) | `bool` | `false` | no |
| node_count | Number of nodes per zone | `number` | `1` | no |
| machine_type | Machine type for nodes | `string` | `"e2-medium"` | no |
| min_node_count | Minimum nodes for autoscaling | `number` | `1` | no |
| max_node_count | Maximum nodes for autoscaling | `number` | `3` | no |
| network_policy_enabled | Enable Kubernetes network policies | `bool` | `true` | no |
| enable_vpa | Enable Vertical Pod Autoscaling | `bool` | `false` | no |

## Outputs

| Name | Description | Usage |
|------|-------------|-------|
| cluster_name | Name of the created cluster | Use with `gcloud` commands |
| cluster_endpoint | Kubernetes API endpoint | For `kubectl` configuration |
| cluster_ca_certificate | Base64 encoded certificate | For `kubectl` configuration |
| cluster_location | Location of the cluster | For `gcloud` commands |

## After Creation

### Get Cluster Credentials

```bash
gcloud container clusters get-credentials <cluster_name> \
  --region <region> \
  --project <project_id>
```

### Verify Access

```bash
kubectl get nodes
kubectl get pods --all-namespaces
```

## Cost Considerations

- **Cluster Management**: Free (managed control plane)
- **Nodes**: ~$0.10/hour per e2-medium node
- **Load Balancers**: ~$0.025/hour (if using LoadBalancer services)
- **Storage**: Pay for persistent volumes if used

**Tip**: Use preemptible nodes for development (`preemptible = true`)

## Troubleshooting

### Cluster Creation Fails

- Check IAM permissions
- Verify APIs are enabled
- Ensure VPC/subnet exists
- Check project quotas

### Cannot Connect to Cluster

- Verify `gcloud` authentication: `gcloud auth list`
- Check cluster endpoint is accessible
- For private clusters, ensure you're on the VPC network or using a bastion

### Nodes Not Joining

- Check node service account permissions
- Verify subnet has private Google access enabled
- Check firewall rules allow necessary traffic

## Related Modules

- `vpc-standard` - Creates the VPC network this cluster uses
- `artifact-registry` - Container registry for images

## Learn More

- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [GKE Best Practices](https://cloud.google.com/kubernetes-engine/docs/best-practices)
- [GKE Pricing](https://cloud.google.com/kubernetes-engine/pricing)

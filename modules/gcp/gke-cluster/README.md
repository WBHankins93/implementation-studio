# GKE Cluster Module

Standard GKE cluster with configurable options for production deployments.

## Purpose

Creates a production-ready GKE cluster with:
- Private node pools
- Configurable node machine types and sizes
- Network configuration
- IAM and RBAC settings
- Optional addons (network policy, etc.)

## Usage

```hcl
module "gke_cluster" {
  source = "../../modules/gcp/gke-cluster"
  
  project_id     = var.project_id
  cluster_name   = "my-cluster"
  region         = "us-central1"
  network        = module.vpc.network_name
  subnetwork     = module.vpc.subnet_name
  
  node_pools = [
    {
      name         = "default-pool"
      machine_type = "e2-medium"
      min_count    = 1
      max_count    = 3
    }
  ]
}
```

## Requirements

- GCP project with billing enabled
- Appropriate IAM permissions
- VPC network and subnet created

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | GCP project ID | `string` | n/a | yes |
| cluster_name | Name of the GKE cluster | `string` | n/a | yes |
| region | GCP region | `string` | n/a | yes |
| network | VPC network name | `string` | n/a | yes |
| subnetwork | Subnet name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| cluster_name | Name of the created cluster |
| cluster_endpoint | Kubernetes API endpoint |
| cluster_ca_certificate | Base64 encoded certificate |

## Status

⏳ Module in development


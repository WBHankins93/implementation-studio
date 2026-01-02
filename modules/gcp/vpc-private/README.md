# VPC Private Module

Creates a fully private VPC network with private-only subnets for GKE clusters and a management subnet for bastion hosts.

## Features

- **Private Subnet**: For GKE nodes with private Google access enabled
- **Management Subnet**: For bastion hosts and management tools
- **No Public Subnets**: Fully private network design
- **Optional NAT**: Can enable NAT for management subnet if needed

## Usage

```hcl
module "vpc_private" {
  source = "../../modules/gcp/vpc-private"
  
  network_name          = "my-private-vpc"
  region                = "us-central1"
  private_subnet_cidr   = "10.0.1.0/24"
  management_subnet_cidr = "10.0.2.0/24"
  enable_management_nat = false  # Set to true if bastion needs internet access
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| network_name | Name of the VPC network | `string` | n/a | yes |
| region | GCP region | `string` | n/a | yes |
| private_subnet_cidr | CIDR block for private subnet (GKE nodes) | `string` | `"10.0.1.0/24"` | no |
| management_subnet_cidr | CIDR block for management subnet (bastion host) | `string` | `"10.0.2.0/24"` | no |
| enable_management_nat | Enable NAT for management subnet | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| network_name | Name of the VPC network |
| network_id | ID of the VPC network |
| private_subnet_name | Name of the private subnet |
| private_subnet_id | ID of the private subnet |
| management_subnet_name | Name of the management subnet |
| management_subnet_id | ID of the management subnet |

## Private Google Access

The private subnet has `private_ip_google_access = true`, which allows GKE nodes to access GCP services (Artifact Registry, Cloud Storage, etc.) without external IPs.

## Use Cases

- Private GKE clusters
- Air-gapped or isolated environments
- Compliance requirements for private-only networks
- Bastion-hosted access patterns


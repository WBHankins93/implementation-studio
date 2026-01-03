# VPC Private Module

Creates a fully private VPC network with private-only subnets for EKS clusters and a management subnet for bastion hosts.

## Features

- **Private Subnet**: For EKS nodes with VPC endpoints for AWS services
- **Management Subnet**: For bastion hosts and management tools
- **No Internet Gateway**: Fully private network design
- **VPC Endpoints**: S3 endpoint for AWS service access without internet
- **Optional NAT**: Can enable NAT for management subnet if needed (simplified version)

## Usage

```hcl
module "vpc_private" {
  source = "../../modules/aws/vpc-private"
  
  network_name          = "my-private-vpc"
  vpc_cidr             = "10.0.0.0/16"
  private_subnet_cidr   = "10.0.1.0/24"
  management_subnet_cidr = "10.0.2.0/24"
  availability_zones    = ["us-west-2a", "us-west-2b"]
  enable_management_nat = false  # Set to true if bastion needs internet access
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| network_name | Name of the VPC network | `string` | n/a | yes |
| vpc_cidr | CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |
| private_subnet_cidr | CIDR block for private subnet (EKS nodes) | `string` | `"10.0.1.0/24"` | no |
| management_subnet_cidr | CIDR block for management subnet (bastion host) | `string` | `"10.0.2.0/24"` | no |
| enable_management_nat | Enable NAT for management subnet | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID of the VPC |
| private_subnet_id | ID of the private subnet |
| management_subnet_id | ID of the management subnet |
| s3_vpc_endpoint_id | ID of the S3 VPC endpoint |

## VPC Endpoints (Private Google Access Equivalent)

The private subnet has VPC endpoints configured for AWS services:
- **S3 Gateway Endpoint**: Allows access to S3 without internet (free, no data transfer charges)

Additional endpoints can be added for:
- ECR (Elastic Container Registry)
- EKS API
- CloudWatch Logs
- Other AWS services

## Use Cases

- Private EKS clusters
- Air-gapped or isolated environments
- Compliance requirements for private-only networks
- Bastion-hosted access patterns

## Note on NAT Gateway

If `enable_management_nat` is true, this module creates a simplified NAT gateway. In production, NAT gateways should be in a separate public subnet. This module places it in the management subnet for simplicity - consider using a dedicated public subnet for production use.

## Related Modules

- `eks-cluster` - Private EKS cluster using this VPC
- `vpc` - Standard VPC with public and private subnets


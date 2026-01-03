# VPC Module

## What is This?

This module creates a Virtual Private Cloud (VPC) network on AWS with both public and private subnets. A VPC is your isolated network in the cloud, similar to a traditional network but hosted on AWS infrastructure.

## When to Use This Module

- Need a network for EKS clusters or other AWS resources
- Want to separate public-facing resources from private workloads
- Require outbound internet access from private resources (via NAT Gateway)
- Building a standard production network architecture

## What It Creates

- **VPC**: Your isolated network in AWS
- **Public Subnet**: For resources that need direct internet access (load balancers, NAT gateway)
- **Private Subnet**: For resources that should not have external IPs (EKS nodes, databases)
- **Internet Gateway**: Provides internet access for public subnet
- **NAT Gateway**: Provides outbound internet access for private subnet resources
- **Route Tables**: Separate routing for public and private subnets

## How It Works

```
Internet
   │
   ▼
┌─────────────────────────────┐
│      VPC Network            │
│                             │
│  ┌───────────────────────┐  │
│  │  Public Subnet       │  │
│  │  (10.0.1.0/24)       │  │
│  │  - Internet Gateway  │  │
│  │  - NAT Gateway       │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │  Private Subnet       │  │
│  │  (10.0.2.0/24)        │  │
│  │  - No External IPs    │  │
│  │  - Access via NAT     │  │
│  └───────────────────────┘  │
└─────────────────────────────┘
```

## Usage

### Basic Example

```hcl
module "vpc" {
  source = "../../modules/aws/vpc"
  
  network_name       = "my-vpc"
  vpc_cidr          = "10.0.0.0/16"
  public_subnet_cidr = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
  availability_zones = ["us-west-2a", "us-west-2b"]
}
```

### With VPC Flow Logs

```hcl
module "vpc" {
  source = "../../modules/aws/vpc"
  
  # ... other variables ...
  
  enable_flow_logs = true
  flow_log_retention_days = 30
}
```

## Inputs

See `variables.tf` for complete list. Key variables:

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| network_name | Name of the VPC network | `string` | n/a | yes |
| vpc_cidr | CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |
| public_subnet_cidr | CIDR block for public subnet | `string` | `"10.0.1.0/24"` | no |
| private_subnet_cidr | CIDR block for private subnet | `string` | `"10.0.2.0/24"` | no |
| availability_zones | List of availability zones | `list(string)` | `["us-west-2a", "us-west-2b"]` | no |
| enable_flow_logs | Enable VPC Flow Logs | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID of the VPC |
| public_subnet_id | ID of the public subnet |
| private_subnet_id | ID of the private subnet |
| private_subnet_ids | List of private subnet IDs (for EKS compatibility) |
| nat_gateway_id | ID of the NAT Gateway |

## Differences from GCP VPC

| Feature | GCP | AWS |
|---------|-----|-----|
| **Subnets** | Regional | Availability Zone specific |
| **NAT** | Cloud NAT (managed) | NAT Gateway (managed but more expensive) |
| **Routing** | Automatic | Explicit route tables |
| **Flow Logs** | Built-in | Optional addon with IAM role |

## Cost Considerations

- **NAT Gateway**: ~$0.045/hour + data processing charges (~$0.045/GB)
- **VPC Flow Logs**: CloudWatch Logs charges (storage + ingestion)
- **Data Transfer**: Standard AWS data transfer pricing

**Tip**: NAT Gateway is one of the more expensive components. Consider using VPC endpoints for AWS services to reduce NAT Gateway traffic.

## Related Modules

- `eks-cluster` - EKS cluster that uses this VPC
- `vpc-private` - Fully private VPC (no internet gateway)

## Learn More

- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)
- [NAT Gateway Pricing](https://aws.amazon.com/vpc/pricing/)


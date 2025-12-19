# VPC Standard Module

## What is This?

This module creates a Virtual Private Cloud (VPC) network on Google Cloud Platform with both public and private subnets. A VPC is your private network in the cloud, similar to a traditional network but hosted on GCP infrastructure.

## When to Use This Module

- Need a network for GKE clusters or other GCP resources
- Want to separate public-facing resources from private workloads
- Require outbound internet access from private resources (via NAT)
- Building a standard production network architecture

## What It Creates

- **VPC Network**: Your isolated network in GCP
- **Public Subnet**: For resources that need direct internet access (load balancers, bastion hosts)
- **Private Subnet**: For resources that should not have external IPs (GKE nodes, databases)
- **Cloud Router**: Routes traffic within and between networks
- **Cloud NAT**: Provides outbound internet access for private subnet resources

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
│  │  - External IPs OK   │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │  Private Subnet       │  │
│  │  (10.0.2.0/24)        │  │
│  │  - No External IPs    │  │
│  │  - Access via NAT     │  │
│  └───────────────────────┘  │
│         │                    │
│         ▼                    │
│  ┌───────────────────────┐  │
│  │  Cloud NAT Gateway    │  │
│  │  (Outbound Internet)  │  │
│  └───────────────────────┘  │
└─────────────────────────────┘
```

## Features

- **Dual Subnet Architecture**: Separate public and private subnets
- **Private Google Access**: Private subnet can access GCP services without internet
- **Cloud NAT**: Private resources can make outbound connections
- **VPC Flow Logs**: Network traffic logging enabled
- **Regional Routing**: REGIONAL routing mode for better performance

## Usage

### Basic Example

```hcl
module "vpc" {
  source = "../../modules/gcp/vpc-standard"
  
  network_name       = "my-vpc"
  region             = "us-central1"
  public_subnet_cidr = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
}
```

### Custom CIDR Ranges

```hcl
module "vpc" {
  source = "../../modules/gcp/vpc-standard"
  
  network_name       = "production-vpc"
  region             = "us-central1"
  public_subnet_cidr = "172.16.1.0/24"   # Custom range
  private_subnet_cidr = "172.16.2.0/24"  # Custom range
}
```

## Understanding Subnets

### Public Subnet

- **Purpose**: Resources that need direct internet access
- **Use Cases**: 
  - Load balancers
  - Bastion hosts (jump servers)
  - NAT gateways
- **IPs**: Can have external IPs

### Private Subnet

- **Purpose**: Resources that should not be directly accessible from internet
- **Use Cases**:
  - GKE nodes
  - Database instances
  - Internal services
- **IPs**: No external IPs (more secure)
- **Internet Access**: Via Cloud NAT (outbound only)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| network_name | Name of the VPC network | `string` | n/a | yes |
| region | GCP region where resources are created | `string` | n/a | yes |
| public_subnet_cidr | CIDR block for public subnet | `string` | `"10.0.1.0/24"` | no |
| private_subnet_cidr | CIDR block for private subnet | `string` | `"10.0.2.0/24"` | no |

**CIDR Range Guidelines:**
- Use private IP ranges (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)
- Ensure ranges don't overlap with other networks
- Leave room for growth (don't use /32)

## Outputs

| Name | Description | Usage |
|------|-------------|-------|
| network_name | VPC network name | Reference in other modules |
| network_id | VPC network ID | For advanced configurations |
| public_subnet_name | Public subnet name | For resources needing public access |
| private_subnet_name | Private subnet name | For GKE clusters and private resources |
| private_subnet_id | Private subnet ID | For advanced configurations |

## After Creation

### Verify Network

```bash
gcloud compute networks describe <network_name>
gcloud compute networks subnets list --filter="network:<network_name>"
```

### Check NAT Gateway

```bash
gcloud compute routers describe <network_name>-nat-router --region=<region>
```

## Cost Considerations

- **VPC Network**: Free
- **Subnets**: Free
- **Cloud Router**: ~$0.05/hour
- **Cloud NAT**: ~$0.045/hour + data processing charges
- **VPC Flow Logs**: Storage costs for logs

**Tip**: NAT gateway is the main cost. Only create if private resources need outbound internet.

## Security Best Practices

1. **Use Private Subnets**: Keep workloads in private subnets when possible
2. **No External IPs**: Don't assign external IPs to private resources
3. **Firewall Rules**: Use GCP firewall rules to restrict traffic
4. **VPC Flow Logs**: Enable for security monitoring

## Troubleshooting

### Cannot Create Subnet

- Check CIDR doesn't overlap with existing subnets
- Verify CIDR is a valid private IP range
- Ensure you have compute.networks.create permission

### Private Resources Can't Access Internet

- Verify Cloud NAT is created and running
- Check NAT gateway is in the same region as resources
- Ensure firewall rules allow outbound traffic

### Cannot Access GCP Services from Private Subnet

- Verify "Private Google Access" is enabled (it is by default in this module)
- Check service account has necessary permissions

## Related Modules

- `gke-cluster` - Uses the private subnet from this module
- `vpc-private` - Alternative module for fully private networks

## Learn More

- [VPC Documentation](https://cloud.google.com/vpc/docs)
- [Cloud NAT Documentation](https://cloud.google.com/nat/docs)
- [VPC Best Practices](https://cloud.google.com/vpc/docs/vpc-best-practices)


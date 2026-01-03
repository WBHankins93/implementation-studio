# Security Groups Module

## What is This?

This module creates AWS security groups for EKS nodes with configurable egress rules. Security groups act as virtual firewalls controlling inbound and outbound traffic for EC2 instances (including EKS nodes).

## When to Use This Module

- Need to control egress traffic from EKS nodes
- Implementing firewall-restricted deployments
- Require strict network security policies
- Working with security teams that mandate egress restrictions

## What It Creates

- **Security Group**: Security group for EKS nodes
- **Egress Rules**: Configurable rules for outbound traffic
- **Ingress Rules**: Rules for node-to-node and cluster-to-node communication

## How It Works

AWS security groups are **allow-only** (whitelist). By default, all egress is allowed. To restrict egress:

1. Set `enable_strict_egress = true` (removes default allow-all egress)
2. Add specific allow rules for DNS, proxy, AWS services, etc.
3. All other egress is implicitly denied

```
┌─────────────────────────────┐
│   EKS Node                  │
│   (Security Group Applied)  │
└─────────────────────────────┘
           │
           │ Egress Rules
           ▼
┌─────────────────────────────┐
│  Security Group Rules       │
│  - Allow DNS (53/UDP)       │
│  - Allow Proxy (3128/TCP)   │
│  - Allow Internal VPC       │
│  - Allow AWS Services       │
│  - Deny All Else            │
└─────────────────────────────┘
```

## Usage

### Basic Example (Allow All Egress)

```hcl
module "security_groups" {
  source = "../../modules/aws/security-groups"
  
  name_prefix              = "my-eks"
  vpc_id                   = module.vpc.vpc_id
  vpc_cidr                 = module.vpc.vpc_cidr
  cluster_security_group_id = module.eks_cluster.cluster_security_group_id
}
```

### With Strict Egress (Firewall-Restricted)

```hcl
module "security_groups" {
  source = "../../modules/aws/security-groups"
  
  name_prefix              = "my-eks"
  vpc_id                   = module.vpc.vpc_id
  vpc_cidr                 = module.vpc.vpc_cidr
  cluster_security_group_id = module.eks_cluster.cluster_security_group_id
  
  enable_strict_egress = true
  proxy_cidr          = "10.0.3.0/24"  # Proxy subnet
  proxy_port          = 3128
}
```

### With External Endpoints Allowlist

```hcl
module "security_groups" {
  source = "../../modules/aws/security-groups"
  
  # ... other variables ...
  
  enable_strict_egress = true
  
  allowed_external_endpoints = {
    "docker-registry" = {
      cidr        = "52.0.0.0/8"
      port        = 443
      protocol    = "tcp"
      description = "Docker Hub registry"
    }
    "api-service" = {
      cidr        = "1.2.3.4/32"
      port        = 443
      protocol    = "tcp"
      description = "External API service"
    }
  }
}
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name_prefix | Prefix for security group names | `string` | n/a (required) |
| vpc_id | ID of the VPC | `string` | n/a (required) |
| cluster_security_group_id | EKS cluster security group ID | `string` | n/a (required) |
| enable_strict_egress | Enable strict egress rules | `bool` | `false` |
| proxy_cidr | CIDR block of proxy server | `string` | `null` |
| proxy_port | Port of the proxy server | `number` | `3128` |

## Outputs

| Name | Description |
|------|-------------|
| nodes_security_group_id | ID of the security group for EKS nodes |

## Differences from GCP Firewall Rules

| Feature | GCP Firewall Rules | AWS Security Groups |
|---------|-------------------|---------------------|
| **Model** | Allow and Deny rules | Allow-only (whitelist) |
| **Targeting** | Tags, service accounts | Security group membership |
| **Direction** | Separate ingress/egress rules | Combined in one resource |
| **Priority** | Explicit priority numbers | Implicit (order of rules) |

## Important Notes

1. **Security groups are stateful**: If you allow traffic out, the response is automatically allowed back in
2. **Multiple security groups**: Nodes can have multiple security groups (rules are combined with OR logic)
3. **No explicit deny**: You cannot explicitly deny traffic - only allow specific traffic
4. **Default behavior**: By default, all egress is allowed unless you set `enable_strict_egress = true`

## Related Modules

- `eks-cluster` - EKS cluster that uses this security group
- `vpc` - VPC network for the security group

## Learn More

- [Security Groups Documentation](https://docs.aws.amazon.com/vpc/latest/userguide/security-groups.html)
- [Security Group Rules](https://docs.aws.amazon.com/vpc/latest/userguide/security-group-rules.html)
- [EKS Security Group Requirements](https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html)


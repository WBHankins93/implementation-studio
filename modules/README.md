# Implementation Studio Modules

This directory contains reusable Terraform and Kubernetes modules designed for both learning labs and real customer engagements.

## Module Organization

### GCP Modules (`gcp/`)

Infrastructure modules for Google Cloud Platform:

- `gke-cluster` - Standard GKE cluster with configurable options
- `vpc-standard` - Public + private subnets, NAT gateway
- `vpc-private` - Fully private, no external IPs
- `artifact-registry` - Container registry
- `airgap-registry` - Registry for disconnected environments
- `firewall-rules` - Common firewall configurations
- `private-service-connect` - Private GCP service access

### AWS Modules (`aws/`)

Infrastructure modules for Amazon Web Services:

- `eks-cluster` - Standard EKS cluster with configurable options
- `vpc` - Public + private subnets, NAT gateway
- `vpc-private` - Fully private, no external IPs, VPC endpoints
- `ecr` - Elastic Container Registry
- `rds` - Relational Database Service (PostgreSQL/MySQL)
- `security-groups` - Security groups for EKS nodes with strict egress control

### Kubernetes Modules (`kubernetes/`)

Kubernetes deployment patterns and configurations (cloud-agnostic):

- `argo-workflows` - Standard Argo Workflows deployment
- `argo-workflows-airgap` - Offline-ready Argo (images list, packaging scripts)
- `ingress-nginx` - Public ingress controller
- `ingress-internal` - Internal-only ingress
- `network-policies` - Isolation patterns (deny-all, namespace isolation)
- `rbac-patterns` - Permission templates (namespace-admin, read-only)
- `resource-quotas` - Multi-tenant resource limits

## Multi-Cloud Support

Implementation Studio supports both **GCP** and **AWS** for cloud deployments. All modules are designed with parity in mind, though some implementation differences exist due to provider-specific features.

### Provider Comparison

For detailed comparisons between GCP and AWS modules, see:
- [Provider Comparison Guide](../docs/provider-comparison.md) - Technical comparison of GCP vs AWS
- [Feature Parity Matrix](../docs/feature-parity-matrix.md) - Detailed feature comparison
- [Migration Guide](../docs/migration-guide.md) - How to migrate between providers

### Module Equivalents

| GCP Module | AWS Equivalent | Notes |
|------------|----------------|-------|
| `gke-cluster` | `eks-cluster` | Both support standard Kubernetes deployments |
| `vpc-standard` | `vpc` | Similar functionality, different subnet design |
| `vpc-private` | `vpc-private` | Both support fully private networks |
| `artifact-registry` | `ecr` | Both support container registries |
| `firewall-rules` | `security-groups` | Different security models, equivalent functionality |
| N/A | `rds` | AWS-specific database module |

## Using Modules

### In Labs

Labs import modules using standard Terraform module syntax with provider selection:

```hcl
# GCP Example
module "gke_cluster" {
  source = "../../modules/gcp/gke-cluster"
  
  project_id     = var.project_id
  cluster_name   = var.cluster_name
  region         = var.region
  network        = module.vpc.network_name
  subnetwork     = module.vpc.private_subnet_name
  # ... other variables
}

# AWS Example
module "eks_cluster" {
  source = "../../modules/aws/eks-cluster"
  
  cluster_name = var.cluster_name
  region       = var.region
  subnet_ids   = module.vpc.private_subnet_ids
  # ... other variables
}
```

### Provider Selection

Most labs support both GCP and AWS via a `cloud_provider` variable:

```hcl
variable "cloud_provider" {
  description = "Cloud provider: gcp or aws"
  type        = string
  default     = "gcp"
  validation {
    condition     = contains(["gcp", "aws"], var.cloud_provider)
    error_message = "Cloud provider must be 'gcp' or 'aws'."
  }
}

# Conditional module usage
module "cluster" {
  source = var.cloud_provider == "gcp" 
    ? "../../modules/gcp/gke-cluster"
    : "../../modules/aws/eks-cluster"
  # ...
}
```

### In Real Projects

These modules are designed to be reusable in actual customer engagements. Each module includes:

- Comprehensive variable documentation
- Output values for integration
- README with usage examples
- Best practices and security considerations
- Provider-specific notes where applicable

## Module Standards

All modules follow these standards:

1. **Documentation**: Each module has a README.md with:
   - Purpose and use cases
   - Input variables (with descriptions)
   - Output values
   - Usage examples
   - Requirements and dependencies
   - Provider-specific considerations

2. **Code Quality**:
   - Terraform formatting (`terraform fmt`)
   - Variable types and descriptions
   - Output documentation
   - Consistent naming conventions

3. **Testing**:
   - Terraform validate passes
   - TFLint checks pass
   - Examples provided for common use cases

4. **Multi-Cloud Considerations**:
   - Document provider differences
   - Provide equivalent examples
   - Note feature gaps where applicable

## Provider-Specific Notes

### GCP Modules

**Advantages:**
- Free control plane (GKE)
- VPC-native networking (simpler)
- Regional subnets
- Built-in private clusters

**Considerations:**
- Requires GCP project
- Google-specific terminology
- Regional resource limits

### AWS Modules

**Advantages:**
- Larger ecosystem
- More global regions
- RDS Proxy (connection pooling)
- Automatic secrets rotation

**Considerations:**
- Control plane cost ($0.10/hour)
- CNI plugin networking (more complex)
- Zonal subnets
- AWS-specific terminology

## Contributing

When adding new modules:

1. Follow the existing module structure
2. Include comprehensive README
3. Add examples in the module directory
4. Update this README with the new module
5. Ensure all validation checks pass
6. Consider multi-cloud parity (if applicable)
7. Document provider differences

## Additional Resources

- [Provider Comparison Guide](../docs/provider-comparison.md)
- [Migration Guide](../docs/migration-guide.md)
- [Feature Parity Matrix](../docs/feature-parity-matrix.md)
- [Multi-Cloud Considerations](../docs/multi-cloud-considerations.md)

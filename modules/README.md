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

### Kubernetes Modules (`kubernetes/`)

Kubernetes deployment patterns and configurations:

- `argo-workflows` - Standard Argo Workflows deployment
- `argo-workflows-airgap` - Offline-ready Argo (images list, packaging scripts)
- `ingress-nginx` - Public ingress controller
- `ingress-internal` - Internal-only ingress
- `network-policies` - Isolation patterns (deny-all, namespace isolation)
- `rbac-patterns` - Permission templates (namespace-admin, read-only)
- `resource-quotas` - Multi-tenant resource limits

## Using Modules

### In Labs

Labs import modules using standard Terraform module syntax:

```hcl
module "gke_cluster" {
  source = "../../modules/gcp/gke-cluster"
  
  project_id     = var.project_id
  cluster_name   = var.cluster_name
  region         = var.region
  # ... other variables
}
```

### In Real Projects

These modules are designed to be reusable in actual customer engagements. Each module includes:

- Comprehensive variable documentation
- Output values for integration
- README with usage examples
- Best practices and security considerations

## Module Standards

All modules follow these standards:

1. **Documentation**: Each module has a README.md with:
   - Purpose and use cases
   - Input variables (with descriptions)
   - Output values
   - Usage examples
   - Requirements and dependencies

2. **Code Quality**:
   - Terraform formatting (`terraform fmt`)
   - Variable types and descriptions
   - Output documentation
   - Consistent naming conventions

3. **Testing**:
   - Terraform validate passes
   - TFLint checks pass
   - Examples provided for common use cases

## Contributing

When adding new modules:

1. Follow the existing module structure
2. Include comprehensive README
3. Add examples in the module directory
4. Update this README with the new module
5. Ensure all validation checks pass


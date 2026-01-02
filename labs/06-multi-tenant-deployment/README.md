# Lab 06: Multi-Tenant Deployment

## Learning Objectives

By completing this lab, you will:

- Implement namespace-based tenant isolation
- Configure RBAC for tenant separation
- Set up resource quotas per tenant
- Implement network policies for tenant isolation
- Manage tenant lifecycle (onboarding, offboarding)
- Understand multi-tenant architecture patterns

## Prerequisites

- `kubectl` installed
- Kind installed (for local deployment) OR
- GCP project with billing enabled (for GCP deployment)
- Basic understanding of Kubernetes namespaces, RBAC, and network policies

## Architecture

This lab demonstrates multi-tenant Kubernetes deployment patterns:

- **Namespace Isolation**: Each tenant gets their own namespace
- **RBAC Separation**: Tenant-specific roles and permissions
- **Resource Quotas**: Per-tenant resource limits
- **Network Policies**: Network-level tenant isolation
- **Shared Services**: Common services accessible to all tenants

See [Architecture Documentation](./docs/architecture.md) for detailed diagrams.

## Quick Start

### Option 1: Local Deployment (Kind - Recommended, Free)

```bash
cd labs/06-multi-tenant-deployment

# Setup Kind cluster
./scripts/setup.sh

# Create shared services
kubectl apply -f manifests/shared-services/

# Create first tenant
./tenant-onboarding/create-tenant.sh tenant-a standard

# Create second tenant
./tenant-onboarding/create-tenant.sh tenant-b limited

# Validate
./scripts/validate.sh
```

### Option 2: GCP Deployment

```bash
cd labs/06-multi-tenant-deployment
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars: set use_gcp = true and project_id

# Deploy infrastructure
terraform init
terraform plan
terraform apply

# Get credentials
terraform output get_credentials_command

# Create shared services and tenants (same as Option 1)
```

## Step-by-Step Guide

See [Step-by-Step Documentation](./docs/step-by-step.md) for detailed instructions.

## About the Manifests Folder

The `manifests/` folder contains **static Kubernetes manifests** that are applied directly:

- **`shared-services/`**: Contains the shared services namespace and network policy that all tenants can access. These are applied once for the entire cluster.
- **`tenant-templates/`**: Contains template workflows that can be customized and deployed per tenant.

**Important:** Tenant-specific resources (namespaces, RBAC, quotas, network policies) are **not** in the manifests folder. Instead, they are created dynamically by the `create-tenant.sh` script using templates from `tenant-onboarding/`. The reusable network policy patterns are in `modules/kubernetes/network-policies/`.

## What Gets Deployed

### Infrastructure

- **Kubernetes Cluster**: Kind (local) or GKE (cloud)
- **Shared Services Namespace**: Common services for all tenants
- **Tenant Namespaces**: Isolated namespaces per tenant

### Per Tenant

- **Namespace**: Isolated namespace with labels
- **Resource Quota**: CPU, memory, and object limits
- **Limit Range**: Default resource requests/limits
- **Network Policy**: Isolation from other tenants
- **RBAC**: Tenant-specific roles and bindings
- **Service Account**: For tenant applications

## Key Concepts

### Namespace Isolation

Each tenant gets their own namespace, providing:
- Logical separation
- Resource boundaries
- RBAC scoping
- Network policy targets

### Resource Quotas

Prevent one tenant from consuming all resources:
- CPU limits per namespace
- Memory limits per namespace
- Object count limits (deployments, services, etc.)

### Network Policies

Enforce network-level isolation:
- No cross-tenant communication
- Access to shared services only
- DNS access for all tenants

### RBAC Patterns

Different permission levels:
- **Namespace Admin**: Full control within namespace
- **Read-Only**: View-only access
- **Deployment-Only**: Can deploy apps, not manage infrastructure

## Tenant Lifecycle

### Onboarding

```bash
./tenant-onboarding/create-tenant.sh <tenant-name> [quota-type] [user-email]
```

This creates:
- Namespace with labels
- Resource quota and limits
- Network policy
- RBAC roles and bindings

### Offboarding

```bash
kubectl delete namespace <tenant-name>
```

**Note:** Ensure tenant data is backed up before deletion!

## Estimated Time

2-3 hours (depending on number of tenants created)

## Estimated Cost

**Local (Kind)**: $0 (fully local)
**GCP**: $0-10 if resources are destroyed within a few hours

## Validation

See [VALIDATION-STATUS.md](./VALIDATION-STATUS.md) for validation details.

## Troubleshooting

See [Troubleshooting Guide](./docs/troubleshooting.md) for common issues and solutions.

## Documentation

- [Architecture](./docs/architecture.md) - Multi-tenant architecture patterns
- [Isolation Strategies](./docs/isolation-strategies.md) - How isolation works
- [Tenant Lifecycle](./docs/tenant-lifecycle.md) - Onboarding and offboarding
- [Resource Management](./docs/resource-management.md) - Quotas and limits
- [Step-by-Step Guide](./docs/step-by-step.md) - Detailed walkthrough
- [Troubleshooting](./docs/troubleshooting.md) - Common issues and solutions

## Cleanup

To destroy all resources:

```bash
./scripts/cleanup.sh
```

**Warning:** This will delete all tenant namespaces and their data!

## Next Steps

After completing this lab:

1. Review the Kubernetes modules in `modules/kubernetes/`
2. Understand different isolation strategies
3. Practice tenant onboarding and offboarding
4. Experiment with different quota levels
5. Proceed to Lab 07: Integration Patterns

## Additional Resources

- [Kubernetes Namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
- [RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Resource Quotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/)
- [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)


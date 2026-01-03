# Lab 06: Multi-Tenant Deployment

## Learning Objectives

By completing this lab, you will:

- Implement namespace-based tenant isolation
- Configure RBAC for tenant separation
- Set up resource quotas per tenant
- Implement network policies for tenant isolation
- Manage tenant lifecycle (onboarding, offboarding)
- Understand multi-tenant architecture patterns
- Experience multi-cloud deployment patterns (Kind, GCP, AWS)

## Prerequisites

### Common Prerequisites
- `kubectl` installed
- Basic understanding of Kubernetes namespaces, RBAC, and network policies

### Kind (Local) Prerequisites
- Kind installed (for local deployment)

### GCP Prerequisites
- GCP project with billing enabled
- `gcloud` CLI configured with appropriate permissions
- Terraform >= 1.5

### AWS Prerequisites
- AWS account with appropriate permissions
- `aws` CLI configured (`aws configure`)
- Terraform >= 1.5

## Cloud Provider Selection

This lab supports **three deployment options**:

1. **Kind (Local)** - Free, local Kubernetes cluster (recommended for learning)
2. **GCP (GKE)** - Google Kubernetes Engine
3. **AWS (EKS)** - Amazon Elastic Kubernetes Service

Choose your provider by setting `cloud_provider` in `terraform.tfvars`:
- `cloud_provider = "kind"` - Local Kind cluster (free, recommended)
- `cloud_provider = "gcp"` - GKE cluster on Google Cloud Platform
- `cloud_provider = "aws"` - EKS cluster on Amazon Web Services

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

# Ensure cloud_provider = "kind" in terraform.tfvars (default)
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
# Edit terraform.tfvars: set cloud_provider = "gcp" and project_id

# Deploy infrastructure
terraform init
terraform plan
terraform apply

# Get credentials
terraform output get_credentials_command
eval $(terraform output -raw get_credentials_command)

# Create shared services and tenants (same as Option 1)
kubectl apply -f manifests/shared-services/
./tenant-onboarding/create-tenant.sh tenant-a standard
```

### Option 3: AWS Deployment

```bash
cd labs/06-multi-tenant-deployment
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars: set cloud_provider = "aws" and region

# Deploy infrastructure
terraform init
terraform plan
terraform apply

# Get credentials
terraform output get_credentials_command
eval $(terraform output -raw get_credentials_command)

# Create shared services and tenants (same as Option 1)
kubectl apply -f manifests/shared-services/
./tenant-onboarding/create-tenant.sh tenant-a standard
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

- **Kubernetes Cluster**: Kind (local), GKE (GCP), or EKS (AWS)
- **Shared Services Namespace**: Common services for all tenants
- **Tenant Namespaces**: Isolated namespaces per tenant

### Per Tenant

- **Namespace**: Isolated namespace with labels
- **Resource Quota**: CPU, memory, and object limits
- **Limit Range**: Default resource requests/limits
- **Network Policy**: Isolation from other tenants
- **RBAC**: Tenant-specific roles and bindings
- **Service Account**: Tenant service account

## Estimated Time

2-3 hours (depending on deployment option and tenant creation)

## Estimated Cost

- **Kind (Local)**: $0 (fully local)
- **GCP**: $0-10 depending on usage and how quickly resources are destroyed
- **AWS**: $0-15 depending on usage and how quickly resources are destroyed

**Cost breakdown (if using cloud):**
- Cluster management: $0.10/hour (AWS only, GCP is free)
- Nodes: ~$0.05-0.10/hour per node
- Other resources: minimal

**Tip**: Use Kind for learning - it's free and perfect for multi-tenant patterns!

## Provider Comparison

| Feature | Kind | GCP GKE | AWS EKS |
|---------|------|---------|---------|
| **Cost** | Free | Free control plane | $0.10/hour control plane |
| **Setup Time** | < 1 minute | 5-10 minutes | 10-15 minutes |
| **Network Policies** | ✅ Supported | ✅ Supported | ✅ Supported (VPC CNI) |
| **RBAC** | ✅ Supported | ✅ Supported | ✅ Supported |
| **Resource Quotas** | ✅ Supported | ✅ Supported | ✅ Supported |
| **Best For** | Learning, testing | Production GCP | Production AWS |

## Validation

See [VALIDATION-STATUS.md](./VALIDATION-STATUS.md) for validation details.

## Troubleshooting

See [Troubleshooting Guide](./docs/troubleshooting.md) for common issues and solutions.

## Cleanup

To destroy all resources:

**Kind:**
```bash
kind delete cluster --name multi-tenant-cluster
```

**GCP/AWS:**
```bash
terraform destroy
```

## Next Steps

After completing this lab:

1. Review the Kubernetes modules in `modules/kubernetes/`
2. Understand how namespace isolation works
3. Experiment with different tenant quota levels
4. Try creating tenants with different isolation levels
5. Proceed to Lab 07: Integration Patterns

## Additional Resources

- [Kubernetes Namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
- [Kubernetes RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [Resource Quotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/)

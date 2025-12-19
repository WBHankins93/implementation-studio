# Lab 01: Standard GKE Deployment

## Learning Objectives

By completing this lab, you will:

- Deploy a production-ready GKE cluster with proper networking
- Install and configure Argo Workflows
- Set up ingress with TLS termination
- Understand the baseline infrastructure that all other labs modify
- Learn how to structure Terraform modules for reuse

## Prerequisites

- GCP project with billing enabled
- `gcloud` CLI configured with appropriate permissions
- Terraform >= 1.5
- `kubectl` installed
- Helm 3.x installed
- Basic understanding of Kubernetes concepts

## Architecture

This lab deploys:

- **GCP VPC** with public and private subnets
- **GKE Cluster** with private nodes and public endpoint
- **Artifact Registry** for container images
- **Argo Workflows** for workflow orchestration
- **Ingress NGINX** for external access

See [Architecture Documentation](./docs/architecture.md) for detailed diagrams.

## Quick Start

### 1. Configure Variables

```bash
cd labs/01-standard-deployment
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your GCP project ID
```

### 2. Run Setup

```bash
./scripts/setup.sh
```

### 3. Deploy Infrastructure

```bash
terraform plan
terraform apply
```

### 4. Deploy Argo Workflows

```bash
./scripts/deploy-argo.sh
```

### 5. Validate Deployment

```bash
./scripts/validate.sh
```

## Step-by-Step Guide

See [Step-by-Step Documentation](./docs/step-by-step.md) for detailed instructions.

## What Gets Deployed

### Infrastructure (Terraform)

- VPC network with public and private subnets
- Cloud NAT for private subnet internet access
- GKE cluster with:
  - Private node pools (no external IPs)
  - Public API endpoint
  - Network policy enabled
  - Workload Identity enabled
- Artifact Registry repository

### Kubernetes Resources

- `argo` namespace
- `ingress-nginx` namespace
- Argo Workflows (via Helm)
- Ingress NGINX Controller (via Helm)
- Sample workflow manifest

## Estimated Time

1-2 hours (depending on GCP resource provisioning time)

## Estimated Cost

$5-10 if resources are destroyed within a few hours

**Cost breakdown:**
- GKE cluster: ~$0.10/hour per node
- Load balancer: ~$0.025/hour
- NAT gateway: ~$0.045/hour
- Storage: minimal

## Validation

See [VALIDATION-STATUS.md](./VALIDATION-STATUS.md) for validation details.

## Troubleshooting

See [Troubleshooting Guide](./docs/troubleshooting.md) for common issues and solutions.

## Cleanup

To destroy all resources:

```bash
./scripts/cleanup.sh
```

Or manually:

```bash
terraform destroy
```

## Next Steps

After completing this lab:

1. Review the Terraform modules in `modules/gcp/` and `modules/kubernetes/`
2. Understand how modules are structured for reuse
3. Proceed to Lab 02: Air-Gapped Deployment (fully local, no cloud costs)

## Additional Resources

- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Argo Workflows Documentation](https://argoproj.github.io/workflows/)
- [Ingress NGINX Documentation](https://kubernetes.github.io/ingress-nginx/)


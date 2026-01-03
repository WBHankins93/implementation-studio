# Lab 01: Standard Deployment

## Learning Objectives

By completing this lab, you will:

- Deploy a production-ready Kubernetes cluster with proper networking (GCP GKE or AWS EKS)
- Install and configure Argo Workflows
- Set up ingress with TLS termination
- Understand the baseline infrastructure that all other labs modify
- Learn how to structure Terraform modules for reuse
- Experience multi-cloud deployment patterns

## Prerequisites

### Common Prerequisites
- Terraform >= 1.5
- `kubectl` installed
- Helm 3.x installed
- Basic understanding of Kubernetes concepts

### GCP-Specific Prerequisites
- GCP project with billing enabled
- `gcloud` CLI configured with appropriate permissions

### AWS-Specific Prerequisites
- AWS account with appropriate permissions
- `aws` CLI configured (`aws configure`)

## Cloud Provider Selection

This lab supports **both GCP and AWS**. Choose your provider by setting `cloud_provider` in `terraform.tfvars`:

- `cloud_provider = "gcp"` - Deploys GKE cluster on Google Cloud Platform
- `cloud_provider = "aws"` - Deploys EKS cluster on Amazon Web Services

Both providers deploy equivalent infrastructure:
- VPC network with public and private subnets
- Managed Kubernetes cluster
- Container registry (Artifact Registry or ECR)
- Same Kubernetes workloads (Argo Workflows, Ingress NGINX)

## Architecture

This lab deploys:

### GCP Architecture
- **GCP VPC** with public and private subnets
- **GKE Cluster** with private nodes and public endpoint
- **Artifact Registry** for container images
- **Argo Workflows** for workflow orchestration
- **Ingress NGINX** for external access

### AWS Architecture
- **AWS VPC** with public and private subnets
- **EKS Cluster** with private nodes and public endpoint
- **ECR Repository** for container images
- **Argo Workflows** for workflow orchestration
- **Ingress NGINX** for external access

See [Architecture Documentation](./docs/architecture.md) for detailed diagrams.

## Quick Start

### 1. Configure Variables

```bash
cd labs/01-standard-deployment
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars:
#   - Set cloud_provider = "gcp" or "aws"
#   - Set provider-specific variables (project_id for GCP, region for AWS, etc.)
```

### 2. Run Setup

```bash
./scripts/setup.sh
```

This script will:
- Check prerequisites for your selected provider
- Initialize Terraform
- Verify configuration

### 3. Deploy Infrastructure

```bash
terraform plan
terraform apply
```

### 4. Deploy Argo Workflows

```bash
./scripts/deploy-argo.sh
```

This script automatically:
- Gets cluster credentials (GCP or AWS)
- Installs Argo Workflows via Helm
- Installs Ingress NGINX via Helm
- Applies sample workflow

### 5. Validate Deployment

```bash
./scripts/validate.sh
```

## Step-by-Step Guide

See [Step-by-Step Documentation](./docs/step-by-step.md) for detailed instructions.

## What Gets Deployed

### Infrastructure (Terraform)

**GCP:**
- VPC network with public and private subnets
- Cloud NAT for private subnet internet access
- GKE cluster with:
  - Private node pools (no external IPs)
  - Public API endpoint
  - Network policy enabled
  - Workload Identity enabled
- Artifact Registry repository

**AWS:**
- VPC network with public and private subnets
- NAT Gateway for private subnet internet access
- EKS cluster with:
  - Private node groups (no external IPs)
  - Public API endpoint
  - Network policy support (VPC CNI)
  - IRSA ready (IAM Roles for Service Accounts)
- ECR repository

### Kubernetes Resources (Same for Both Providers)

- `argo` namespace
- `ingress-nginx` namespace
- Argo Workflows (via Helm)
- Ingress NGINX Controller (via Helm)
- Sample workflow manifest

## Provider-Specific Configuration

### GCP Configuration

```hcl
cloud_provider = "gcp"
project_id     = "your-gcp-project-id"
region         = "us-central1"
machine_type   = "e2-medium"
```

### AWS Configuration

```hcl
cloud_provider     = "aws"
region             = "us-west-2"
vpc_cidr          = "10.0.0.0/16"
availability_zones = ["us-west-2a", "us-west-2b"]
instance_type     = "t3.medium"
```

See `terraform.tfvars.example` for complete configuration options.

## Estimated Time

1-2 hours (depending on cloud provider and resource provisioning time)

## Estimated Cost

**GCP:** $5-10 if resources are destroyed within a few hours
- GKE cluster: ~$0.10/hour per node
- Load balancer: ~$0.025/hour
- NAT gateway: ~$0.045/hour

**AWS:** $8-15 if resources are destroyed within a few hours
- EKS cluster: $0.10/hour (control plane)
- Nodes: ~$0.05/hour per t3.medium node
- NAT Gateway: ~$0.045/hour + data transfer
- Load balancer: ~$0.0225/hour (if using ALB)

## Key Differences: GCP vs AWS

| Feature | GCP GKE | AWS EKS |
|---------|---------|---------|
| **Control Plane Cost** | Free | $0.10/hour |
| **Networking** | VPC-native (automatic) | VPC CNI (automatic) |
| **IAM Integration** | Workload Identity | IRSA |
| **Container Registry** | Artifact Registry | ECR |
| **Node Management** | Node pools | Node groups |
| **Getting Credentials** | `gcloud container clusters get-credentials` | `aws eks update-kubeconfig` |

## Validation

See [VALIDATION-STATUS.md](./VALIDATION-STATUS.md) for validation details.

## Troubleshooting

### Provider-Specific Issues

**GCP:**
- Verify `gcloud` authentication: `gcloud auth list`
- Check project billing is enabled
- Ensure required APIs are enabled

**AWS:**
- Verify AWS credentials: `aws sts get-caller-identity`
- Check IAM permissions for EKS
- Ensure service-linked role exists: `aws iam get-role --role-name AWSServiceRoleForAmazonEKS`

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

1. Review the Terraform modules in `modules/gcp/` and `modules/aws/`
2. Understand how modules are structured for reuse
3. Compare GCP and AWS implementations
4. Proceed to Lab 02: Air-Gapped Deployment (fully local, no cloud costs)

## Additional Resources

### GCP
- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Artifact Registry Documentation](https://cloud.google.com/artifact-registry/docs)

### AWS
- [EKS Documentation](https://docs.aws.amazon.com/eks/)
- [ECR Documentation](https://docs.aws.amazon.com/ecr/)

### Common
- [Argo Workflows Documentation](https://argoproj.github.io/workflows/)
- [Ingress NGINX Documentation](https://kubernetes.github.io/ingress-nginx/)

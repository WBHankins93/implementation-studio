# Lab 03: Private Network Deployment

## Learning Objectives

By completing this lab, you will:

- Deploy a fully private Kubernetes cluster with private API endpoint
- Configure private access for cloud services (Private Google Access for GCP, VPC endpoints for AWS)
- Set up and use a bastion host for cluster access
- Implement internal-only load balancers
- Understand VPN/Interconnect patterns (conceptual)
- Learn how to work with private clusters in production environments
- Experience multi-cloud private cluster patterns (GCP and AWS)

## Cloud Provider Selection

This lab supports **two deployment options**:

1. **GCP (GKE)** - Google Kubernetes Engine with private cluster
2. **AWS (EKS)** - Amazon Elastic Kubernetes Service with private endpoint

Choose your provider by setting `cloud_provider` in `terraform.tfvars`:
- `cloud_provider = "gcp"` - Private GKE cluster on Google Cloud Platform
- `cloud_provider = "aws"` - Private EKS cluster on Amazon Web Services

## Prerequisites

### Common Prerequisites
- Terraform >= 1.5
- `kubectl` installed
- Helm 3.x installed
- Basic understanding of Kubernetes concepts
- Completion of Lab 01 recommended (to understand baseline)

### GCP Prerequisites
- GCP project with billing enabled
- `gcloud` CLI configured with appropriate permissions

### AWS Prerequisites
- AWS account with appropriate permissions
- `aws` CLI configured (`aws configure`)

## Architecture

This lab deploys:

- **Private VPC Network** with private-only subnets (no public subnets)
- **Private Kubernetes Cluster** with private nodes and private API endpoint
- **Bastion Host** for secure cluster access
- **Container Registry** (Artifact Registry for GCP, ECR for AWS)
- **Argo Workflows** for workflow orchestration
- **Internal Ingress NGINX** for internal-only access

See [Architecture Documentation](./docs/architecture.md) for detailed diagrams.

## Quick Start

### 1. Configure Variables

```bash
cd labs/03-private-network-deployment
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars:
#   - Set cloud_provider = "gcp" or "aws"
#   - Set project_id (GCP) or region (AWS)
# IMPORTANT: Restrict bastion_authorized_networks to your IP!
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

### 4. Access Bastion Host

```bash
./scripts/bastion-access.sh
```

### 5. From Bastion, Deploy Argo Workflows

Once connected to the bastion:

**For GCP:**
```bash
# Get cluster credentials (using internal IP)
gcloud container clusters get-credentials <cluster-name> --region <region> --project <project-id> --internal-ip

# Deploy Argo Workflows
./scripts/deploy-argo.sh
```

**For AWS:**
```bash
# Get cluster credentials
aws eks update-kubeconfig --region <region> --name <cluster-name>

# Deploy Argo Workflows
./scripts/deploy-argo.sh
```

### 6. Validate Deployment

From the bastion host:

```bash
./scripts/validate.sh
```

## Step-by-Step Guide

See [Step-by-Step Documentation](./docs/step-by-step.md) for detailed instructions.

## What Gets Deployed

### Infrastructure (Terraform)

**GCP:**
- **Private VPC Network** with:
  - Private subnet for GKE nodes (10.0.1.0/24)
  - Management subnet for bastion host (10.0.2.0/24)
  - Private Google Access enabled
  - No NAT gateway (fully private)
  
- **Private GKE Cluster** with:
  - Private node pools (no external IPs)
  - Private API endpoint (only accessible from VPC)
  - Master authorized networks (bastion subnet)
  - Network policy enabled
  - Workload Identity enabled
  
- **Bastion Host** with:
  - External IP for SSH access
  - Service account with GKE access permissions
  - Pre-installed kubectl and gcloud tools
  
- **Artifact Registry** repository

**AWS:**
- **Private VPC Network** with:
  - Private subnets for EKS nodes (10.0.1.0/24)
  - Management subnet for bastion host (10.0.2.0/24)
  - VPC endpoints for S3 (for private access)
  - No Internet Gateway (fully private)
  
- **Private EKS Cluster** with:
  - Private node groups (no public IPs)
  - Private API endpoint (only accessible from VPC)
  - Security groups restricting access
  - VPC CNI for networking
  
- **Bastion Host** with:
  - Public IP for SSH access (or use Systems Manager Session Manager)
  - IAM role with EKS access permissions
  - Pre-installed kubectl and AWS CLI
  
- **ECR Repository** for container images

### Kubernetes Resources

- `argo` namespace
- `ingress-nginx` namespace
- Argo Workflows (via Helm)
- Internal Ingress NGINX Controller (via Helm)
- Sample workflow manifest
- Internal-only Ingress resource

## Key Differences from Lab 01

| Feature | Lab 01 (Standard) | Lab 03 (Private) |
|---------|------------------|-------------------|
| VPC | Public + Private subnets | Private-only subnets |
| Cluster Endpoint | Public | Private (VPC-only) |
| Access Method | Direct kubectl | Via bastion host |
| Load Balancer | External | Internal-only |
| NAT Gateway | Yes (for private subnet) | No (fully private) |

## Provider Comparison

| Feature | GCP GKE | AWS EKS |
|---------|---------|---------|
| **Private Endpoint** | ✅ Supported | ✅ Supported |
| **Bastion Access** | gcloud compute ssh | SSH or Systems Manager |
| **Private Services** | Private Google Access | VPC Endpoints |
| **Internal LB** | Annotation-based | Automatic (private subnets) |
| **Setup Time** | 5-10 minutes | 10-15 minutes |
| **Cost** | ~$0.10/hour per node | $0.10/hour control plane + nodes |

## Estimated Time

2-3 hours (depending on cloud provider and resource provisioning time)

## Estimated Cost

**GCP:** $8-15 if resources are destroyed within a few hours
- GKE cluster: ~$0.10/hour per node
- Bastion host: ~$0.01/hour (e2-micro)
- Internal load balancer: ~$0.025/hour

**AWS:** $10-18 if resources are destroyed within a few hours
- EKS control plane: $0.10/hour
- Node instances: ~$0.05-0.10/hour per node
- Bastion host: ~$0.01/hour (t3.micro)
- Internal load balancer: ~$0.025/hour

## Accessing the Cluster

### Via Bastion Host

The cluster is only accessible from within the VPC. Use the bastion host:

**GCP:**
```bash
# SSH to bastion
./scripts/bastion-access.sh

# From bastion, get credentials
gcloud container clusters get-credentials <cluster-name> \
  --region <region> \
  --project <project-id> \
  --internal-ip

# Use kubectl normally
kubectl get nodes
```

**AWS:**
```bash
# SSH to bastion (or use Systems Manager Session Manager)
./scripts/bastion-access.sh

# From bastion, get credentials
aws eks update-kubeconfig --region <region> --name <cluster-name>

# Use kubectl normally
kubectl get nodes
```

See [Bastion Access Guide](./docs/bastion-access.md) for detailed instructions.

## Private Service Access

**GCP - Private Google Access:**
The private subnet has Private Google Access enabled, allowing GKE nodes to access:
- Artifact Registry
- Cloud Storage
- Cloud Logging
- Cloud Monitoring
- Other GCP services

Without requiring external IPs or NAT.

**AWS - VPC Endpoints:**
The VPC includes VPC endpoints for private access to:
- S3 (for image pulls)
- ECR (for container registry)
- Other AWS services

Without requiring Internet Gateway or NAT Gateway.

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

1. Review the private VPC modules (`modules/gcp/vpc-private/` or `modules/aws/vpc-private/`)
2. Understand bastion host patterns and security considerations
3. Learn about VPN/Interconnect for connecting to private clusters
4. Proceed to Lab 04: Firewall-Restricted Deployment

## Additional Resources

**GCP:**
- [GKE Private Clusters](https://cloud.google.com/kubernetes-engine/docs/how-to/private-clusters)
- [Private Google Access](https://cloud.google.com/vpc/docs/private-google-access)
- [Bastion Hosts Best Practices](https://cloud.google.com/solutions/connecting-securely)
- [Internal Load Balancers](https://cloud.google.com/kubernetes-engine/docs/how-to/internal-load-balancing)

**AWS:**
- [EKS Private Clusters](https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html)
- [VPC Endpoints](https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints.html)
- [Systems Manager Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html)
- [Internal Load Balancers](https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer)

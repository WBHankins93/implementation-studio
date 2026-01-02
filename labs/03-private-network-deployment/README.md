# Lab 03: Private Network Deployment

## Learning Objectives

By completing this lab, you will:

- Deploy a fully private GKE cluster with private API endpoint
- Configure private Google Access for GCP services
- Set up and use a bastion host for cluster access
- Implement internal-only load balancers
- Understand VPN/Interconnect patterns (conceptual)
- Learn how to work with private clusters in production environments

## Prerequisites

- GCP project with billing enabled
- `gcloud` CLI configured with appropriate permissions
- Terraform >= 1.5
- `kubectl` installed
- Helm 3.x installed
- Basic understanding of Kubernetes concepts
- Completion of Lab 01 recommended (to understand baseline)

## Architecture

This lab deploys:

- **Private GCP VPC** with private-only subnets (no public subnets)
- **Private GKE Cluster** with private nodes and private API endpoint
- **Bastion Host** for secure cluster access
- **Artifact Registry** for container images
- **Argo Workflows** for workflow orchestration
- **Internal Ingress NGINX** for internal-only access

See [Architecture Documentation](./docs/architecture.md) for detailed diagrams.

## Quick Start

### 1. Configure Variables

```bash
cd labs/03-private-network-deployment
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your GCP project ID
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

```bash
# Get cluster credentials (using internal IP)
gcloud container clusters get-credentials <cluster-name> --region <region> --project <project-id> --internal-ip

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
| GKE Endpoint | Public | Private (VPC-only) |
| Access Method | Direct kubectl | Via bastion host |
| Load Balancer | External | Internal-only |
| NAT Gateway | Yes (for private subnet) | No (fully private) |

## Estimated Time

2-3 hours (depending on GCP resource provisioning time)

## Estimated Cost

$8-15 if resources are destroyed within a few hours

**Cost breakdown:**
- GKE cluster: ~$0.10/hour per node
- Bastion host: ~$0.01/hour (e2-micro)
- Internal load balancer: ~$0.025/hour
- Storage: minimal

## Accessing the Cluster

### Via Bastion Host

The cluster is only accessible from within the VPC. Use the bastion host:

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

See [Bastion Access Guide](./docs/bastion-access.md) for detailed instructions.

## Private Google Access

The private subnet has Private Google Access enabled, allowing GKE nodes to access:
- Artifact Registry
- Cloud Storage
- Cloud Logging
- Cloud Monitoring
- Other GCP services

Without requiring external IPs or NAT.

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

1. Review the private VPC module in `modules/gcp/vpc-private/`
2. Understand bastion host patterns and security considerations
3. Learn about VPN/Interconnect for connecting to private clusters
4. Proceed to Lab 04: Firewall-Restricted Deployment

## Additional Resources

- [GKE Private Clusters](https://cloud.google.com/kubernetes-engine/docs/how-to/private-clusters)
- [Private Google Access](https://cloud.google.com/vpc/docs/private-google-access)
- [Bastion Hosts Best Practices](https://cloud.google.com/solutions/connecting-securely)
- [Internal Load Balancers](https://cloud.google.com/kubernetes-engine/docs/how-to/internal-load-balancing)


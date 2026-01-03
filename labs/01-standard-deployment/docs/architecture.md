# Lab 01 Architecture

## Overview

Lab 01 deploys a standard Kubernetes cluster with Argo Workflows on either GCP (GKE) or AWS (EKS), representing a typical production deployment pattern.

## Provider Selection

This lab supports two cloud providers:

- **GCP (GKE)**: Google Kubernetes Engine
- **AWS (EKS)**: Amazon Elastic Kubernetes Service

Both providers deploy equivalent infrastructure, with provider-specific implementations of the same concepts.

## Network Architecture

### GCP Network Architecture

```
Internet
   │
   ▼
┌─────────────────────────────────────────┐
│         GCP VPC Network                 │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │   Public Subnet (10.0.1.0/24)    │  │
│  │   - Load Balancers               │  │
│  └──────────────────────────────────┘  │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │  Private Subnet (10.0.2.0/24)     │  │
│  │  - GKE Nodes (no external IPs)    │  │
│  │  - Cloud NAT Gateway              │  │
│  └──────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

### AWS Network Architecture

```
Internet
   │
   ▼
┌─────────────────────────────────────────┐
│         AWS VPC Network                 │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │   Public Subnet (10.0.1.0/24)    │  │
│  │   - Internet Gateway             │  │
│  │   - NAT Gateway                  │  │
│  └──────────────────────────────────┘  │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │  Private Subnet (10.0.2.0/24)     │  │
│  │  - EKS Nodes (no external IPs)    │  │
│  │  - Route to NAT Gateway           │  │
│  └──────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## Cluster Architecture

### GKE Cluster Architecture

```
┌─────────────────────────────────────────┐
│         GKE Cluster                     │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │   Control Plane (Public Endpoint) │  │
│  │   - Managed by Google             │  │
│  └──────────────────────────────────┘  │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │   Node Pool                      │  │
│  │   - Private IPs only             │  │
│  │   - Auto-scaling enabled         │  │
│  │   - VPC-native networking        │  │
│  └──────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

### EKS Cluster Architecture

```
┌─────────────────────────────────────────┐
│         EKS Cluster                     │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │   Control Plane (Public Endpoint) │  │
│  │   - Managed by AWS ($0.10/hour)  │  │
│  └──────────────────────────────────┘  │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │   Node Group                     │  │
│  │   - Private IPs only             │  │
│  │   - Auto-scaling enabled         │  │
│  │   - VPC CNI networking           │  │
│  └──────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## Application Architecture

The Kubernetes application layer is identical for both providers:

```
Internet
   │
   ▼
┌─────────────────────────────────────────┐
│   Ingress NGINX Controller              │
│   (LoadBalancer Service)                │
│   - GCP: GCP Load Balancer             │
│   - AWS: AWS Load Balancer             │
└─────────────────────────────────────────┘
   │
   ▼
┌─────────────────────────────────────────┐
│   Argo Workflows Server                 │
│   - UI (port 2746)                      │
│   - API (port 2746)                     │
└─────────────────────────────────────────┘
   │
   ▼
┌─────────────────────────────────────────┐
│   Argo Workflow Controller             │
│   - Executes workflows                 │
│   - Manages workflow state             │
└─────────────────────────────────────────┘
```

## Resource Flow

### GCP Resource Flow

1. **Terraform** creates:
   - VPC and subnets (via `vpc-standard` module)
   - GKE cluster (via `gke-cluster` module)
   - Artifact Registry (via `artifact-registry` module)

2. **Helm** installs:
   - Ingress NGINX Controller
   - Argo Workflows

3. **Kubectl** applies:
   - Namespaces
   - Sample workflows

### AWS Resource Flow

1. **Terraform** creates:
   - VPC and subnets (via `vpc` module)
   - EKS cluster (via `eks-cluster` module)
   - ECR repository (via `ecr` module)

2. **Helm** installs:
   - Ingress NGINX Controller
   - Argo Workflows

3. **Kubectl** applies:
   - Namespaces
   - Sample workflows

## Security Features

### GCP Security Features

- Private node pools (no external IPs)
- Network policies enabled
- Workload Identity for secure service account access
- Private Google Access for GCP services
- Binary authorization enabled

### AWS Security Features

- Private node groups (no external IPs)
- Network policies support (via VPC CNI)
- IRSA (IAM Roles for Service Accounts) for secure AWS access
- Encryption at rest for cluster secrets (KMS)
- VPC endpoints for AWS services

## Container Registry

### GCP: Artifact Registry

- Regional Docker registry
- Integrated with GCP IAM
- Vulnerability scanning
- Lifecycle policies

### AWS: Elastic Container Registry (ECR)

- Regional Docker registry
- Integrated with AWS IAM
- Vulnerability scanning
- Lifecycle policies

## High Availability

Both providers support:

- Multi-zone/AZ node distribution
- Ingress NGINX with 2+ replicas
- Pod disruption budgets configured
- Auto-scaling for nodes and workloads

### GCP Specific

- GKE automatically distributes nodes across zones
- Regional persistent disks

### AWS Specific

- Node groups span multiple availability zones
- EBS volumes for persistent storage

## Provider Comparison

| Feature | GCP GKE | AWS EKS |
|---------|---------|---------|
| **Control Plane** | Free | $0.10/hour |
| **Networking** | VPC-native | VPC CNI |
| **IAM Integration** | Workload Identity | IRSA |
| **Container Registry** | Artifact Registry | ECR |
| **Node Management** | Node Pools | Node Groups |
| **Private Access** | Private Google Access | VPC Endpoints |

## Architecture Decision

Both architectures provide:

- ✅ Production-ready Kubernetes clusters
- ✅ Private nodes (no external IPs)
- ✅ Managed container registries
- ✅ Network isolation
- ✅ Scalable infrastructure
- ✅ Cost-effective defaults

The choice between GCP and AWS depends on:

- Existing cloud provider preference
- Cost considerations (GKE control plane is free)
- Integration requirements with other services
- Compliance and security requirements
- Team expertise

# Lab 03 Architecture

## Overview

Lab 03 deploys a fully private GKE cluster with no public endpoints, accessible only through a bastion host within the VPC.

## Network Architecture

```
Internet
   │
   ▼
┌─────────────────────────────────────────┐
│      GCP VPC Network (Private Only)     │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │  Management Subnet (10.0.2.0/24) │  │
│  │  - Bastion Host (external IP)     │  │
│  └──────────────────────────────────┘  │
│              │                          │
│              │ (VPC internal)           │
│              ▼                          │
│  ┌──────────────────────────────────┐  │
│  │  Private Subnet (10.0.1.0/24)     │  │
│  │  - GKE Nodes (no external IPs)    │  │
│  │  - Private Google Access enabled   │  │
│  └──────────────────────────────────┘  │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │  GKE Master (172.16.0.0/28)       │  │
│  │  - Private endpoint only           │  │
│  └──────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## GKE Cluster Architecture

```
┌─────────────────────────────────────────┐
│      Private GKE Cluster                 │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │   Control Plane (Private Endpoint) │  │
│  │   - Only accessible from VPC       │  │
│  │   - Master authorized networks     │  │
│  └──────────────────────────────────┘  │
│              ▲                          │
│              │ (VPC internal)           │
│              │                          │
│  ┌──────────────────────────────────┐  │
│  │   Node Pool                        │  │
│  │   - Private IPs only              │  │
│  │   - No external IPs                │  │
│  │   - Private Google Access          │  │
│  └──────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## Access Flow

```
Developer
   │
   │ SSH (port 22)
   ▼
┌─────────────────┐
│  Bastion Host    │
│  (External IP)   │
└─────────────────┘
   │
   │ kubectl (port 443)
   │ (VPC internal)
   ▼
┌─────────────────┐
│  GKE Master     │
│  (Private IP)    │
└─────────────────┘
   │
   │ API calls
   ▼
┌─────────────────┐
│  GKE Nodes       │
│  (Private IPs)   │
└─────────────────┘
```

## Application Architecture

```
VPC Internal Network
   │
   ▼
┌─────────────────────────────────────────┐
│      Internal Load Balancer              │
│      (Internal IP only)                  │
└─────────────────────────────────────────┘
   │
   ▼
┌─────────────────────────────────────────┐
│      Ingress NGINX Controller            │
│      (Internal Service)                    │
└─────────────────────────────────────────┘
   │
   ▼
┌─────────────────────────────────────────┐
│      Argo Workflows Server               │
│      - UI accessible internally          │
│      - Workflows execute on nodes         │
└─────────────────────────────────────────┘
```

## Security Architecture

### Network Isolation

- **No Public Subnets**: All resources are in private subnets
- **Private Endpoints**: GKE master only accessible from VPC
- **Firewall Rules**: Restrict access to authorized networks only
- **No NAT**: Nodes use Private Google Access instead

### Access Control

- **Bastion Host**: Single point of entry with external IP
- **SSH Restrictions**: Firewall rules limit SSH to authorized IPs
- **Service Account**: Bastion has minimal required permissions
- **Master Authorized Networks**: Only bastion subnet can access master

### Private Google Access

GKE nodes can access GCP services without external IPs:

- Artifact Registry (pull images)
- Cloud Storage (read/write)
- Cloud Logging (send logs)
- Cloud Monitoring (send metrics)
- Cloud SQL (via private IP)

## Component Details

### VPC Network

- **Type**: Private-only (no public subnets)
- **Subnets**: 
  - Private subnet: GKE nodes
  - Management subnet: Bastion host
- **Routing**: Regional routing mode
- **Private Google Access**: Enabled on private subnet

### GKE Cluster

- **Endpoint**: Private (VPC-only)
- **Nodes**: Private IPs only, no external IPs
- **Master CIDR**: 172.16.0.0/28 (separate from subnets)
- **Authorized Networks**: Management subnet only
- **Network Policy**: Enabled
- **Workload Identity**: Enabled

### Bastion Host

- **Type**: e2-micro (minimal cost)
- **Network**: Management subnet
- **External IP**: Yes (for SSH access)
- **Tools**: Pre-installed kubectl, gcloud, gke-gcloud-auth-plugin
- **Permissions**: container.developer role

### Load Balancer

- **Type**: Internal (GCP Internal Load Balancer)
- **Access**: VPC-only, no external IP
- **Use Case**: Internal services, not internet-facing

## Comparison with Lab 01

| Component | Lab 01 | Lab 03 |
|-----------|--------|--------|
| VPC | Public + Private | Private only |
| GKE Endpoint | Public | Private |
| Node IPs | Private (NAT) | Private (PGA) |
| Access | Direct kubectl | Via bastion |
| Load Balancer | External | Internal |
| NAT Gateway | Yes | No |

## Use Cases

This architecture is suitable for:

- **Compliance Requirements**: Organizations requiring no public endpoints
- **Security Policies**: Strict network isolation requirements
- **Enterprise Environments**: Private-only network designs
- **Regulated Industries**: Financial, healthcare, government
- **Hybrid Cloud**: Connecting to on-premises via VPN/Interconnect


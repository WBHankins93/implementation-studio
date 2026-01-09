# Lab 03 Architecture

## Overview

Lab 03 deploys a fully private GKE cluster with no public endpoints, accessible only through a bastion host within the VPC.

## Network Architecture

```mermaid
graph TB
    Internet[Internet]
    VPC[GCP VPC Network<br/>Private Only]
    MgmtSubnet[Management Subnet<br/>10.0.2.0/24]
    PrivateSubnet[Private Subnet<br/>10.0.1.0/24]
    GKEMaster[GKE Master<br/>172.16.0.0/28<br/>Private Endpoint]
    Bastion[Bastion Host<br/>External IP]
    GKENodes[GKE Nodes<br/>No External IPs<br/>Private Google Access]
    
    Internet -->|SSH Port 22| Bastion
    Bastion -->|VPC Internal| VPC
    VPC --> MgmtSubnet
    VPC --> PrivateSubnet
    VPC --> GKEMaster
    MgmtSubnet --> Bastion
    PrivateSubnet --> GKENodes
    Bastion -->|kubectl Port 443| GKEMaster
    GKEMaster -->|API Calls| GKENodes
    
    style VPC fill:#e1f5ff
    style MgmtSubnet fill:#fff4e1
    style PrivateSubnet fill:#e8f5e9
    style GKEMaster fill:#f3e5f5
    style Bastion fill:#ffebee
    style GKENodes fill:#e0f2f1
```

## GKE Cluster Architecture

```mermaid
graph TB
    VPC[VPC Internal Network]
    ControlPlane[Control Plane<br/>Private Endpoint<br/>172.16.0.0/28]
    NodePool[Node Pool<br/>Private IPs Only<br/>No External IPs<br/>Private Google Access]
    Bastion[Bastion Host]
    
    Bastion -->|VPC Internal<br/>Port 443| ControlPlane
    ControlPlane -->|API Calls| NodePool
    VPC --> ControlPlane
    VPC --> NodePool
    
    style ControlPlane fill:#f3e5f5
    style NodePool fill:#e0f2f1
    style Bastion fill:#ffebee
    style VPC fill:#e1f5ff
```

## Access Flow

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant Bastion as Bastion Host<br/>(External IP)
    participant Master as GKE Master<br/>(Private IP)
    participant Nodes as GKE Nodes<br/>(Private IPs)
    
    Dev->>Bastion: SSH (Port 22)
    Note over Dev,Bastion: Internet connection
    Dev->>Bastion: kubectl commands
    Bastion->>Master: kubectl API (Port 443)
    Note over Bastion,Master: VPC internal
    Master->>Nodes: API calls
    Note over Master,Nodes: VPC internal
    Nodes-->>Master: Response
    Master-->>Bastion: kubectl response
    Bastion-->>Dev: Command output
```

## Application Architecture

```mermaid
graph TB
    VPC[VPC Internal Network]
    ILB[Internal Load Balancer<br/>Internal IP Only]
    Ingress[Ingress NGINX Controller<br/>Internal Service]
    ArgoServer[Argo Workflows Server<br/>UI: Internal Access<br/>API: Internal Access]
    ArgoController[Argo Workflow Controller<br/>Executes Workflows]
    Nodes[GKE Nodes<br/>Workflow Execution]
    
    VPC --> ILB
    ILB --> Ingress
    Ingress --> ArgoServer
    ArgoServer --> ArgoController
    ArgoController --> Nodes
    
    style ILB fill:#e1f5ff
    style Ingress fill:#fff4e1
    style ArgoServer fill:#e8f5e9
    style ArgoController fill:#f3e5f5
    style Nodes fill:#e0f2f1
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


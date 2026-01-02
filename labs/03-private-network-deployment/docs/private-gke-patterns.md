# Private GKE Patterns

## Overview

This document explains the patterns and concepts used in Lab 03 for deploying and managing private GKE clusters.

## Private Cluster Concepts

### What Makes a Cluster "Private"?

A private GKE cluster has three key characteristics:

1. **Private Nodes**: Node VMs have no external IP addresses
2. **Private Endpoint**: The Kubernetes API server is only accessible from within the VPC
3. **Authorized Networks**: Only specific IP ranges can access the master endpoint

### Why Use Private Clusters?

**Security Benefits:**
- Reduced attack surface (no public endpoints)
- Network isolation
- Compliance with security policies
- Defense-in-depth strategy

**Use Cases:**
- Regulated industries (finance, healthcare, government)
- Organizations with strict security policies
- Multi-tenant environments requiring isolation
- Compliance requirements (HIPAA, PCI-DSS, etc.)

## Private Google Access

### What is Private Google Access?

Private Google Access allows VMs without external IPs to access Google Cloud services using private IPs.

### How It Works

```
GKE Node (no external IP)
   │
   │ Private IP
   ▼
┌─────────────────┐
│  VPC Router      │
└─────────────────┘
   │
   │ Private Google Access
   ▼
┌─────────────────┐
│  GCP Services    │
│  - Artifact Reg  │
│  - Cloud Storage │
│  - Cloud Logging │
└─────────────────┘
```

### Enabled Services

With Private Google Access, nodes can access:
- **Artifact Registry**: Pull container images
- **Cloud Storage**: Read/write buckets
- **Cloud Logging**: Send application logs
- **Cloud Monitoring**: Send metrics
- **Cloud SQL**: Connect to databases (via private IP)
- **Pub/Sub**: Publish/subscribe to topics

### Configuration

In Terraform:

```hcl
resource "google_compute_subnetwork" "private" {
  name          = "private-subnet"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.vpc.id
  
  # Enable Private Google Access
  private_ip_google_access = true
}
```

## Master Authorized Networks

### Purpose

Master Authorized Networks restrict which IP ranges can access the GKE master endpoint.

### Configuration

```hcl
resource "google_container_cluster" "private" {
  # ... other config ...
  
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "10.0.2.0/24"  # Bastion subnet
      display_name = "Bastion Subnet"
    }
  }
}
```

### Best Practices

1. **Minimize Authorized Networks**: Only include necessary subnets
2. **Use Specific CIDRs**: Avoid 0.0.0.0/0 (allows all)
3. **Document Each Network**: Use descriptive display names
4. **Review Regularly**: Remove unused networks

## Bastion Host Patterns

### Single Bastion

**Pattern**: One bastion host for all access

**Pros:**
- Simple to manage
- Low cost
- Easy to secure

**Cons:**
- Single point of failure
- Potential bottleneck
- Limited scalability

### Multiple Bastions

**Pattern**: Multiple bastion hosts in different zones

**Pros:**
- High availability
- Load distribution
- Zone redundancy

**Cons:**
- Higher cost
- More complex management
- More firewall rules

### Managed Instance Group

**Pattern**: Auto-scaling bastion hosts

**Pros:**
- Auto-scaling
- Health checks
- Auto-recovery

**Cons:**
- More complex setup
- Higher cost
- Overkill for small clusters

## Internal Load Balancers

### When to Use

Internal load balancers are appropriate when:
- Services should only be accessible within VPC
- No external internet access needed
- Compliance requires private-only access
- Services communicate internally

### Configuration

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
  annotations:
    cloud.google.com/load-balancer-type: "Internal"
spec:
  type: LoadBalancer
  # ... rest of spec
```

### Access Patterns

**From Within VPC:**
- Direct access via internal IP
- No external IP assigned
- Accessible from all VPC resources

**From Outside VPC:**
- Not accessible directly
- Must use VPN/Interconnect
- Or access via bastion port forwarding

## Network Architecture Patterns

### Pattern 1: Fully Private

```
Internet
   │
   ▼
┌─────────────────┐
│  VPC (Private)   │
│  - No public IPs│
│  - Private only  │
└─────────────────┘
```

**Use Case**: Maximum security, compliance requirements

### Pattern 2: Private with Bastion

```
Internet
   │
   ▼
┌─────────────────┐
│  VPC (Private)   │
│  - Bastion (ext) │
│  - Rest private  │
└─────────────────┘
```

**Use Case**: This lab's pattern - secure access with single entry point

### Pattern 3: Hybrid

```
Internet
   │
   ▼
┌─────────────────┐
│  VPC (Hybrid)     │
│  - Public subnet │
│  - Private subnet│
│  - Bastion       │
└─────────────────┘
```

**Use Case**: Mixed workloads, some public-facing

## VPN/Interconnect Patterns

### Cloud VPN

**Pattern**: Site-to-site VPN connection

```
On-Premises
   │
   │ VPN Tunnel
   ▼
┌─────────────────┐
│  VPC (Private)   │
│  - GKE Cluster    │
└─────────────────┘
```

**Use Case**: Connect on-premises to private cluster

### Cloud Interconnect

**Pattern**: Dedicated connection

```
On-Premises
   │
   │ Dedicated Link
   ▼
┌─────────────────┐
│  VPC (Private)   │
│  - GKE Cluster    │
└─────────────────┘
```

**Use Case**: High-bandwidth, low-latency requirements

### Private Service Connect

**Pattern**: Connect GCP services privately

```
GCP Service
   │
   │ Private Connect
   ▼
┌─────────────────┐
│  VPC (Private)   │
│  - GKE Cluster    │
└─────────────────┘
```

**Use Case**: Connect to Cloud SQL, Cloud Storage, etc.

## Security Considerations

### Network Security

1. **Firewall Rules**: Restrict access to minimum necessary
2. **Network Policies**: Kubernetes-level network isolation
3. **Private Endpoints**: No public exposure
4. **VPC Peering**: Secure inter-VPC communication

### Access Security

1. **Bastion Hardening**: Minimal tools, regular updates
2. **SSH Keys**: Use OS Login, rotate regularly
3. **IAM Roles**: Least privilege principle
4. **Audit Logging**: Monitor all access

### Data Security

1. **Encryption**: Encrypt data in transit and at rest
2. **Secrets Management**: Use Secret Manager or similar
3. **Network Isolation**: Separate workloads by namespace
4. **Compliance**: Follow industry-specific requirements

## Cost Optimization

### Right-Sizing

- Use appropriate machine types
- Enable auto-scaling
- Use preemptible nodes for non-critical workloads

### Network Costs

- Internal load balancers are cheaper than external
- No NAT gateway needed (saves ~$0.045/hour)
- Private Google Access is free

### Bastion Costs

- Use e2-micro for minimal cost (~$0.01/hour)
- Consider scheduled instances for non-production
- Use Cloud Shell for occasional access

## Troubleshooting Patterns

### Cannot Access Cluster

1. Check bastion connectivity
2. Verify authorized networks
3. Check firewall rules
4. Verify internal IP flag

### Nodes Cannot Pull Images

1. Verify Private Google Access enabled
2. Check Artifact Registry permissions
3. Verify service account roles
4. Check network connectivity

### Services Not Accessible

1. Verify internal load balancer annotation
2. Check firewall rules
3. Verify service type
4. Check network policies

## Migration Patterns

### From Public to Private

1. Enable private endpoint
2. Configure authorized networks
3. Update access methods
4. Test connectivity
5. Remove public endpoint

### Adding Bastion to Existing Cluster

1. Create bastion host
2. Add bastion subnet to authorized networks
3. Update firewall rules
4. Test access from bastion
5. Document new access method

## Additional Resources

- [GKE Private Clusters](https://cloud.google.com/kubernetes-engine/docs/how-to/private-clusters)
- [Private Google Access](https://cloud.google.com/vpc/docs/private-google-access)
- [Internal Load Balancing](https://cloud.google.com/kubernetes-engine/docs/how-to/internal-load-balancing)
- [VPN Best Practices](https://cloud.google.com/network-connectivity/docs/vpn/concepts/overview)


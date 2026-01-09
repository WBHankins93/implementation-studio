# Lab 04 Architecture

## Overview

Lab 04 deploys a GKE cluster with strict egress firewall rules, using a proxy server for controlled external access.

## Network Architecture

```mermaid
graph TB
    Internet[Internet]
    VPC[GCP VPC Network]
    PublicSubnet[Public Subnet<br/>10.0.1.0/24<br/>Load Balancers]
    PrivateSubnet[Private Subnet<br/>10.0.2.0/24<br/>GKE Nodes<br/>No External IPs<br/>Strict Egress Rules]
    ProxySubnet[Proxy Subnet<br/>10.0.3.0/24<br/>Squid Proxy Server<br/>External IP]
    
    Internet -->|Ingress| PublicSubnet
    VPC --> PublicSubnet
    VPC --> PrivateSubnet
    VPC --> ProxySubnet
    PrivateSubnet -->|Proxy Traffic<br/>HTTP/HTTPS| ProxySubnet
    ProxySubnet -->|Outbound<br/>External IP| Internet
    
    style VPC fill:#e1f5ff
    style PublicSubnet fill:#fff4e1
    style PrivateSubnet fill:#e8f5e9
    style ProxySubnet fill:#ffebee
```

## Egress Flow

```mermaid
sequenceDiagram
    participant Node as GKE Node<br/>(No External IP)
    participant Firewall as Firewall Rules<br/>(Strict Egress)
    participant Proxy as Squid Proxy<br/>10.0.3.x
    participant Internet as Internet
    
    Node->>Firewall: HTTP/HTTPS Request
    Note over Node,Firewall: Direct egress blocked
    Firewall-->>Node: Blocked
    Node->>Proxy: HTTP/HTTPS via Proxy<br/>(10.0.3.x:3128)
    Note over Node,Proxy: Allowed by firewall
    Proxy->>Internet: Request (External IP)
    Internet-->>Proxy: Response
    Proxy-->>Node: Response
```

## Firewall Rules Architecture

### Rule Priority

1. **Internal Traffic** (priority 100) - Always allowed
2. **DNS** (priority 1000) - Allow to Google DNS
3. **Proxy Access** (priority 1000) - Allow to proxy subnet
4. **External Endpoints** (priority 1000) - Allowlist specific endpoints
5. **Deny All Egress** (priority 65534) - Default deny

### Firewall Rule Flow

```mermaid
flowchart TD
    Start[Egress Request] --> Check1{Priority 100<br/>Internal Traffic?}
    Check1 -->|Yes| Allow1[✅ Allow]
    Check1 -->|No| Check2{Priority 1000<br/>DNS/Proxy/<br/>Allowlist?}
    Check2 -->|Match| Allow2[✅ Allow]
    Check2 -->|No Match| Deny[Priority 65534<br/>❌ Deny All]
    
    style Allow1 fill:#c8e6c9
    style Allow2 fill:#c8e6c9
    style Deny fill:#ffcdd2
    style Check1 fill:#fff9c4
    style Check2 fill:#fff9c4
```

## Component Architecture

```mermaid
graph TB
    subgraph "GKE Cluster"
        Nodes[GKE Nodes<br/>Private IPs Only<br/>No External IPs]
        NetworkPolicy[Network Policies<br/>Kubernetes-Level Enforcement]
    end
    
    subgraph "Proxy Subnet"
        Proxy[Squid Proxy Server<br/>HTTP/HTTPS Proxy<br/>External IP]
    end
    
    subgraph "Firewall Rules"
        InternalRule[Priority 100<br/>Internal Traffic]
        AllowlistRule[Priority 1000<br/>DNS/Proxy/Allowlist]
        DenyRule[Priority 65534<br/>Deny All Egress]
    end
    
    Nodes --> NetworkPolicy
    NetworkPolicy -->|Egress Blocked| DenyRule
    Nodes -->|Proxy Traffic| Proxy
    Proxy -->|Allowed| AllowlistRule
    Nodes -->|Internal| InternalRule
    
    style Nodes fill:#e0f2f1
    style NetworkPolicy fill:#f3e5f5
    style Proxy fill:#ffebee
    style DenyRule fill:#ffcdd2
    style AllowlistRule fill:#c8e6c9
    style InternalRule fill:#c8e6c9
```

### GKE Cluster

- **Nodes**: Private IPs only, no external IPs
- **Network Policy**: Enabled for Kubernetes-level enforcement
- **Egress**: Blocked by default, must use proxy

### Proxy Server

- **Type**: Squid HTTP/HTTPS proxy
- **Location**: Dedicated VM in proxy subnet
- **Access**: External IP for outbound internet
- **Configuration**: Allows all traffic (controlled by firewall)

### Network Policies

- **Deny All Egress**: Default policy blocks all egress
- **Allow DNS**: Permits DNS queries
- **Allow Proxy**: Permits traffic to proxy
- **Allow Internal**: Permits cluster-internal traffic

## Application Configuration

### Proxy Environment Variables

All pods are configured with:

```yaml
env:
  - name: HTTP_PROXY
    value: "http://<proxy-ip>:3128"
  - name: HTTPS_PROXY
    value: "http://<proxy-ip>:3128"
  - name: NO_PROXY
    value: "localhost,127.0.0.1,.svc,.svc.cluster.local"
```

### Argo Workflows Configuration

- **Server**: Configured with proxy env vars
- **Controller**: Configured with proxy env vars
- **Workflow Pods**: Inherit proxy via podSpecPatch

## Security Architecture

### Defense in Depth

1. **GCP Firewall Rules**: Network-level enforcement
2. **Kubernetes Network Policies**: Pod-level enforcement
3. **Proxy Server**: Application-level control
4. **Audit Logging**: Monitor all egress traffic

### Access Control

- **Strict Egress**: Deny-all by default
- **Proxy Gateway**: Single point of control
- **Allowlist**: Only approved endpoints
- **Monitoring**: VPC Flow Logs enabled

## Comparison with Other Labs

| Feature | Lab 01 | Lab 03 | Lab 04 |
|---------|--------|--------|--------|
| Egress Control | NAT Gateway | Private Google Access | Strict Firewall + Proxy |
| External Access | Direct | None | Via Proxy |
| Firewall Rules | Standard | None | Strict Deny-All |
| Network Policies | Optional | Optional | Required |
| Proxy | No | No | Yes (Squid) |

## Use Cases

This architecture is suitable for:

- **Compliance Requirements**: Organizations requiring strict egress control
- **Security Policies**: Environments with strict security requirements
- **Audit Requirements**: Need to monitor all external access
- **Customer Environments**: Working with security-conscious customers
- **Regulated Industries**: Financial, healthcare, government

## Monitoring

### VPC Flow Logs

Enable VPC Flow Logs to monitor:
- All egress attempts
- Successful proxy connections
- Blocked direct egress attempts
- Traffic patterns

### Proxy Logs

Squid proxy logs provide:
- All proxied requests
- Source IP addresses
- Destination URLs
- Response codes

## Additional Resources

- [GCP Firewall Rules](https://cloud.google.com/vpc/docs/firewalls)
- [Kubernetes Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [Squid Proxy](http://www.squid-cache.org/)


# Lab 04: Firewall-Restricted Deployment

## Learning Objectives

By completing this lab, you will:

- Work within strict egress firewall rules
- Identify and document required external endpoints
- Configure applications to work through HTTP/HTTPS proxies
- Communicate requirements to customer security teams
- Implement allowlist-based network policies
- Understand the proxy pattern for controlled external access

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

- **GKE Cluster** with standard networking
- **Strict Egress Firewall Rules** (deny-all by default)
- **Squid Proxy Server** for controlled external access
- **Network Policies** enforcing egress restrictions
- **Argo Workflows** configured to use proxy
- **Artifact Registry** for container images

See [Architecture Documentation](./docs/architecture.md) for detailed diagrams.

## Quick Start

### 1. Configure Variables

```bash
cd labs/04-firewall-restricted-deployment
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

### 4. Get Proxy IP and Update Config

```bash
# Get proxy internal IP
terraform output proxy_internal_ip

# Update the proxy ConfigMap (or it will be done automatically by deploy script)
# Edit manifests/proxy-configmap.yaml and replace PROXY_INTERNAL_IP
```

### 5. Deploy Argo Workflows

```bash
./scripts/deploy-argo.sh
```

### 6. Test Egress Restrictions

```bash
./scripts/test-egress.sh
```

### 7. Validate Deployment

```bash
./scripts/validate.sh
```

## Step-by-Step Guide

See [Step-by-Step Documentation](./docs/step-by-step.md) for detailed instructions.

## What Gets Deployed

### Infrastructure (Terraform)

- **VPC Network** with public, private, and proxy subnets
- **GKE Cluster** with standard configuration
- **Squid Proxy Server** on dedicated VM
- **Strict Egress Firewall Rules**:
  - Deny all egress by default
  - Allow DNS (Google DNS)
  - Allow egress to proxy
  - Allow internal VPC traffic
  - Optional: Allow specific external endpoints
- **Artifact Registry** repository

### Kubernetes Resources

- `argo` namespace
- `ingress-nginx` namespace
- **Proxy ConfigMap** with HTTP_PROXY/HTTPS_PROXY settings
- **Network Policies** enforcing egress restrictions
- **Argo Workflows** configured with proxy environment variables
- **Ingress NGINX Controller** for external access
- Sample workflow manifest

## About Squid Proxy

This lab uses **Squid**, an open-source HTTP/HTTPS proxy server, to provide controlled external access for applications running in firewall-restricted environments.

### What is Squid?

Squid is a caching proxy server that acts as an intermediary between clients (your GKE pods) and the internet. In this lab, we use it primarily as a **forwarding proxy** to enable applications to access external services despite strict firewall rules.

### How It Works

```
GKE Pod (no external IP)
   │
   │ HTTP_PROXY=http://proxy:3128
   ▼
Squid Proxy Server
   │
   │ (has external IP)
   ▼
Internet
```

**Key Benefits:**
- **Single Point of Control**: All external traffic flows through one controlled server
- **Centralized Logging**: All egress requests are logged for security audits
- **Simplified Firewall Rules**: Allow traffic to proxy, deny everything else
- **Security Monitoring**: Easy to monitor and filter external access

### In This Lab

- **Location**: Dedicated VM in proxy subnet (10.0.3.0/24)
- **Port**: 3128 (standard Squid port)
- **Configuration**: Minimal setup focused on forwarding (not caching)
- **Access**: Only from VPC internal network (GKE nodes)

### Learn More

- [Squid Official Documentation](http://www.squid-cache.org/Doc/)
- [Squid Configuration Guide](http://www.squid-cache.org/Doc/config/)
- [Squid on Wikipedia](https://en.wikipedia.org/wiki/Squid_(software))

## Key Concepts

### Strict Egress Control

- **Deny-All Default**: All egress traffic is blocked by default
- **Allowlist Approach**: Only explicitly allowed endpoints are accessible
- **Proxy Pattern**: All external traffic goes through a controlled proxy
- **Network Policies**: Kubernetes-level enforcement complements firewall rules

### Proxy Configuration

Applications are configured with:
- `HTTP_PROXY=http://<proxy-ip>:3128`
- `HTTPS_PROXY=http://<proxy-ip>:3128`
- `NO_PROXY=localhost,127.0.0.1,.svc,.svc.cluster.local`

### Working with Security Teams

This lab includes documentation on:
- How to identify required endpoints
- How to document requirements
- How to communicate with security teams
- Common security team concerns and responses

See [Security Team Guide](./docs/security-team-guide.md) for details.

## Estimated Time

2-3 hours (depending on GCP resource provisioning time)

## Estimated Cost

$5-10 if resources are destroyed within a few hours

**Cost breakdown:**
- GKE cluster: ~$0.10/hour per node
- Proxy server: ~$0.01/hour (e2-micro)
- Load balancer: ~$0.025/hour
- Storage: minimal

## Testing Egress Restrictions

The lab includes a test script to verify firewall restrictions:

```bash
./scripts/test-egress.sh
```

This will test:
1. Direct egress (should fail with strict firewall)
2. Egress through proxy (should succeed)
3. Internal connectivity (should work without proxy)
4. DNS resolution (should work)

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

## Documentation

- [Architecture](./docs/architecture.md) - Network and component architecture
- [Egress Requirements](./docs/egress-requirements.md) - Documenting required endpoints
- [Security Team Guide](./docs/security-team-guide.md) - Working with security teams
- [Step-by-Step Guide](./docs/step-by-step.md) - Detailed walkthrough
- [Troubleshooting](./docs/troubleshooting.md) - Common issues and solutions

## Next Steps

After completing this lab:

1. Review the firewall-rules module in `modules/gcp/firewall-rules/`
2. Understand proxy patterns and when to use them
3. Practice documenting egress requirements
4. Learn about working with customer security teams
5. Proceed to Lab 05: The POC Sprint

## Additional Resources

- [GCP Firewall Rules](https://cloud.google.com/vpc/docs/firewalls)
- [Kubernetes Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [Squid Proxy Documentation](http://www.squid-cache.org/)
- [Working with Proxies in Kubernetes](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/)


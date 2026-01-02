# Bastion Host Access Guide

## Overview

The bastion host is the only way to access the private GKE cluster. This guide explains how to use it effectively.

## What is a Bastion Host?

A bastion host (also called a jump host) is a server that acts as a secure gateway to access private resources. In this lab:

- The bastion has an external IP for SSH access
- The bastion is in the same VPC as the GKE cluster
- The bastion can access the private GKE master endpoint
- You SSH to the bastion, then use kubectl from there

## Quick Access

### Automated Method

```bash
cd labs/03-private-network-deployment
./scripts/bastion-access.sh
```

This script will:
1. Get bastion details from Terraform output
2. Provide the SSH command
3. Optionally SSH to the bastion automatically

### Manual Method

```bash
# Get bastion details
cd labs/03-private-network-deployment
terraform output

# SSH to bastion
gcloud compute ssh <bastion-name> \
  --zone <bastion-zone> \
  --project <project-id>
```

## First-Time Setup

### 1. Get Cluster Credentials

Once connected to the bastion:

```bash
# Get cluster credentials using internal IP
gcloud container clusters get-credentials <cluster-name> \
  --region <region> \
  --project <project-id> \
  --internal-ip
```

The `--internal-ip` flag is crucial - it uses the private endpoint instead of the public one.

### 2. Verify Access

```bash
# Test kubectl access
kubectl get nodes
kubectl get namespaces
```

### 3. Deploy Applications

```bash
# Deploy Argo Workflows
./scripts/deploy-argo.sh

# Or manually
helm repo add argo https://argoproj.github.io/argo-helm
helm install argo-workflows argo/argo-workflows \
  --namespace argo \
  --create-namespace
```

## Common Workflows

### Port Forwarding

Access services from your local machine via the bastion:

```bash
# From your local machine, create SSH tunnel
gcloud compute ssh <bastion-name> \
  --zone <bastion-zone> \
  --project <project-id> \
  --ssh-flag="-L 8080:localhost:8080"

# In another terminal, from bastion
kubectl port-forward -n argo svc/argo-workflows-server 8080:2746

# Access from local browser: http://localhost:8080
```

### Copying Files

```bash
# Copy file to bastion
gcloud compute scp local-file.txt <bastion-name>:~/ \
  --zone <bastion-zone> \
  --project <project-id>

# Copy file from bastion
gcloud compute scp <bastion-name>:~/remote-file.txt ./ \
  --zone <bastion-zone> \
  --project <project-id>
```

### Running Commands Remotely

```bash
# Run command on bastion without SSH session
gcloud compute ssh <bastion-name> \
  --zone <bastion-zone> \
  --project <project-id> \
  --command "kubectl get pods -n argo"
```

## Security Best Practices

### 1. Restrict SSH Access

**IMPORTANT**: Update `bastion_authorized_networks` in `terraform.tfvars`:

```hcl
# Restrict to your IP or company network
bastion_authorized_networks = ["YOUR.IP.ADDRESS/32"]
```

### 2. Use OS Login

The bastion has OS Login enabled, which provides:
- Centralized SSH key management
- Audit logging
- IAM-based access control

### 3. Rotate Keys Regularly

```bash
# Generate new SSH key
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"

# Add to GCP project
gcloud compute os-login ssh-keys add \
  --key-file ~/.ssh/id_rsa.pub \
  --project <project-id>
```

### 4. Use IAM for Access Control

Grant bastion access only to authorized users:

```bash
# Grant access to specific user
gcloud projects add-iam-policy-binding <project-id> \
  --member="user:user@example.com" \
  --role="roles/compute.instanceAdmin"
```

### 5. Monitor Access

```bash
# View SSH access logs
gcloud logging read "resource.type=gce_instance AND resource.labels.instance_id=<instance-id>" \
  --limit 50 \
  --format json
```

## Troubleshooting

### Cannot SSH to Bastion

**Problem**: Connection timeout or refused

**Solutions**:
1. Check firewall rules: `gcloud compute firewall-rules list`
2. Verify your IP is in authorized networks
3. Check bastion is running: `gcloud compute instances list`
4. Verify external IP: `gcloud compute instances describe <bastion-name>`

### Cannot Access Cluster from Bastion

**Problem**: `kubectl` commands fail with connection errors

**Solutions**:
1. Verify you used `--internal-ip` flag
2. Check cluster endpoint: `gcloud container clusters describe <cluster-name>`
3. Verify bastion is in authorized network
4. Check firewall rules allow bastion to master

### kubectl Not Found on Bastion

**Problem**: `kubectl: command not found`

**Solutions**:
1. The bastion should have kubectl pre-installed via startup script
2. If missing, install manually:
   ```bash
   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
   chmod +x kubectl
   sudo mv kubectl /usr/local/bin/
   ```

### Permission Denied

**Problem**: `kubectl` returns permission errors

**Solutions**:
1. Verify service account permissions
2. Check IAM bindings: `gcloud projects get-iam-policy <project-id>`
3. Ensure bastion service account has `container.developer` role

## Alternative Access Methods

### VPN/Interconnect

For production, consider:
- **Cloud VPN**: Connect on-premises to VPC
- **Cloud Interconnect**: Dedicated connection
- **Private Service Connect**: Connect other GCP services

### Cloud Shell

You can also use Cloud Shell with private cluster access:

```bash
# Enable private cluster access in Cloud Shell
gcloud container clusters get-credentials <cluster-name> \
  --region <region> \
  --project <project-id> \
  --internal-ip
```

Note: This requires Cloud Shell to be in the same VPC or connected via VPN.

## Production Considerations

### High Availability

- Deploy multiple bastion hosts in different zones
- Use a managed instance group for auto-scaling
- Implement health checks and auto-recovery

### Monitoring

- Monitor bastion CPU, memory, disk
- Alert on failed SSH attempts
- Track kubectl usage and commands

### Backup

- Regularly backup bastion configuration
- Document all installed tools and versions
- Keep bastion OS and tools updated

## Additional Resources

- [GKE Private Clusters](https://cloud.google.com/kubernetes-engine/docs/how-to/private-clusters)
- [Bastion Host Best Practices](https://cloud.google.com/solutions/connecting-securely)
- [OS Login Documentation](https://cloud.google.com/compute/docs/oslogin)


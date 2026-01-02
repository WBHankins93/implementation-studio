# Lab 03: Step-by-Step Guide

## Prerequisites Check

Before starting, ensure you have:

```bash
# Check tools
terraform version    # Should be >= 1.5
gcloud version
kubectl version --client
helm version

# Check GCP authentication
gcloud auth list
gcloud config get-value project
```

## Step 1: Configure GCP Project

```bash
# Set your project
export PROJECT_ID="your-project-id"
gcloud config set project $PROJECT_ID

# Enable required APIs
gcloud services enable \
  container.googleapis.com \
  compute.googleapis.com \
  artifactregistry.googleapis.com \
  servicenetworking.googleapis.com \
  logging.googleapis.com \
  monitoring.googleapis.com
```

## Step 2: Configure Terraform Variables

```bash
cd labs/03-private-network-deployment
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
project_id = "your-project-id"
cluster_name = "implementation-studio-private"
region = "us-central1"

# IMPORTANT: Restrict bastion access to your IP!
# Get your IP: curl ifconfig.me
bastion_authorized_networks = ["YOUR.IP.ADDRESS/32"]
```

**Security Note:** Restricting `bastion_authorized_networks` to your IP is critical for security. Use `curl ifconfig.me` to get your public IP.

## Step 3: Initialize Terraform

```bash
./scripts/setup.sh
```

Or manually:

```bash
terraform init
```

This downloads the required providers and modules.

## Step 4: Review Terraform Plan

```bash
terraform plan
```

Review the resources that will be created:
- Private VPC network with private and management subnets
- Private GKE cluster (private endpoint)
- Bastion host
- Artifact Registry
- Firewall rules

**Key things to verify:**
- Master IP CIDR doesn't overlap with subnets
- Bastion authorized networks are restricted
- Private subnet has Private Google Access enabled

## Step 5: Apply Infrastructure

```bash
terraform apply
```

This will take 10-15 minutes. The cluster creation is the longest step.

**What's being created:**
1. Private VPC network (~2 minutes)
2. Private GKE cluster (~8-10 minutes)
3. Bastion host (~2 minutes)
4. Firewall rules (~1 minute)

## Step 6: Get Bastion Details

After Terraform completes, get bastion information:

```bash
# Get bastion SSH command
terraform output bastion_ssh_command

# Get bastion external IP
terraform output bastion_external_ip

# Get cluster name
terraform output cluster_name
```

## Step 7: Access Bastion Host

```bash
# Use the automated script
./scripts/bastion-access.sh
```

Or manually:

```bash
# Get bastion details from Terraform
BASTION_NAME=$(terraform output -raw bastion_name)
BASTION_ZONE=$(terraform output -raw bastion_zone)

# SSH to bastion
gcloud compute ssh $BASTION_NAME \
  --zone $BASTION_ZONE \
  --project $PROJECT_ID
```

**First-time SSH:** You may be prompted to create SSH keys. Follow the prompts.

## Step 8: Get Cluster Credentials (From Bastion)

Once connected to the bastion:

```bash
# Get cluster credentials using INTERNAL IP
# This is critical - don't forget --internal-ip!
gcloud container clusters get-credentials <cluster-name> \
  --region <region> \
  --project $PROJECT_ID \
  --internal-ip
```

Replace `<cluster-name>`, `<region>`, and `$PROJECT_ID` with your values. You can also use:

```bash
# Get from Terraform output (run from local machine first)
terraform output get_credentials_command
```

**Important:** The `--internal-ip` flag is required for private clusters. Without it, kubectl will try to use the public endpoint (which doesn't exist).

## Step 9: Verify Cluster Access

From the bastion, verify you can access the cluster:

```bash
# Check cluster info
kubectl cluster-info

# List nodes
kubectl get nodes

# List namespaces
kubectl get namespaces
```

If these commands work, you've successfully connected to the private cluster!

## Step 10: Deploy Argo Workflows

From the bastion, deploy Argo Workflows:

```bash
# Use the deployment script
./scripts/deploy-argo.sh
```

Or manually:

```bash
# Add Helm repos
helm repo add argo https://argoproj.github.io/argo-helm
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Create namespaces
kubectl create namespace argo
kubectl create namespace ingress-nginx

# Install Internal Ingress NGINX
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --set controller.service.type=LoadBalancer \
  --set controller.service.annotations."cloud\.google\.com/load-balancer-type"="Internal" \
  --set controller.admissionWebhooks.enabled=false \
  --wait

# Install Argo Workflows
helm install argo-workflows argo/argo-workflows \
  --namespace argo \
  --values ../../modules/kubernetes/argo-workflows/helm-values.yaml \
  --wait
```

## Step 11: Create Internal Ingress

From the bastion, create an internal ingress for Argo Workflows UI:

```bash
# Apply the internal ingress manifest
kubectl apply -f manifests/internal-ingress.yaml

# Check ingress status
kubectl get ingress -n argo

# Get internal load balancer IP
kubectl get service ingress-nginx-controller -n ingress-nginx
```

The internal IP will be in the VPC range (e.g., 10.0.x.x).

## Step 12: Submit Sample Workflow

From the bastion, submit a test workflow:

```bash
# Apply sample workflow
kubectl apply -f manifests/sample-workflow.yaml

# Watch workflow
kubectl get workflows -n argo -w

# Check workflow status
kubectl get workflow -n argo
```

## Step 13: Access Argo UI (Optional)

Since the load balancer is internal, you have a few options:

### Option 1: Port Forwarding from Bastion

```bash
# From bastion
kubectl port-forward -n argo svc/argo-workflows-server 8080:2746
```

Then from your local machine, create an SSH tunnel:

```bash
# In another terminal (from local machine)
gcloud compute ssh <bastion-name> \
  --zone <zone> \
  --ssh-flag="-L 8080:localhost:8080"
```

Access UI at: http://localhost:8080

### Option 2: SSH Tunnel Directly

```bash
# From local machine
gcloud compute ssh <bastion-name> \
  --zone <zone> \
  --ssh-flag="-L 8080:<internal-lb-ip>:80"
```

### Option 3: Access from Another VM in VPC

If you have another VM in the VPC, you can access the internal IP directly.

## Step 14: Validate Deployment

From the bastion, run validation:

```bash
./scripts/validate.sh
```

Or manually check:

```bash
# Check namespaces
kubectl get namespaces

# Check Argo Workflows
kubectl get pods -n argo
kubectl get deployment argo-workflows-server -n argo

# Check Ingress NGINX
kubectl get pods -n ingress-nginx
kubectl get service ingress-nginx-controller -n ingress-nginx

# Check workflows
kubectl get workflows -n argo
```

## Step 15: Cleanup (When Done)

When you're finished with the lab:

```bash
# From local machine (not bastion)
cd labs/03-private-network-deployment
./scripts/cleanup.sh
```

Or manually:

```bash
terraform destroy
```

**Note:** Make sure to exit the bastion SSH session before destroying, or the destroy may hang.

## Common Issues

### Cannot SSH to Bastion

- Check firewall rules: `gcloud compute firewall-rules list`
- Verify your IP is in `bastion_authorized_networks`
- Check bastion is running: `gcloud compute instances list`

### Cannot Access Cluster from Bastion

- Verify you used `--internal-ip` flag
- Check master authorized networks include bastion subnet
- Verify firewall rules allow bastion to master

### Image Pull Errors

- Verify Private Google Access is enabled
- Check Artifact Registry permissions
- Ensure service account has correct roles

See [Troubleshooting Guide](./troubleshooting.md) for more details.

## Next Steps

After completing this lab:

1. Review the private VPC module: `modules/gcp/vpc-private/`
2. Understand bastion host patterns and security
3. Learn about VPN/Interconnect for production
4. Proceed to Lab 04: Firewall-Restricted Deployment

## Additional Resources

- [GKE Private Clusters](https://cloud.google.com/kubernetes-engine/docs/how-to/private-clusters)
- [Bastion Host Best Practices](https://cloud.google.com/solutions/connecting-securely)
- [Private Google Access](https://cloud.google.com/vpc/docs/private-google-access)


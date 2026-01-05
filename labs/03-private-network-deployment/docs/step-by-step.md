# Lab 03: Step-by-Step Guide

## Prerequisites Check

Before starting, ensure you have:

```bash
# Common tools (required for all providers)
terraform version    # Should be >= 1.5
kubectl version --client
helm version
```

### GCP-Specific Prerequisites

```bash
gcloud version
gcloud auth list
gcloud config get-value project
```

### AWS-Specific Prerequisites

```bash
aws --version
aws sts get-caller-identity  # Verify AWS credentials
```

## Step 1: Choose Cloud Provider

This lab supports **GCP** and **AWS**. Choose one:

- **GCP:** Private GKE cluster with Private Google Access
- **AWS:** Private EKS cluster with VPC endpoints

## Step 2: Configure Cloud Provider

### Option A: GCP Configuration

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

### Option B: AWS Configuration

```bash
# Verify AWS credentials
aws sts get-caller-identity

# Set default region (optional)
export AWS_DEFAULT_REGION="us-west-2"
aws configure set region $AWS_DEFAULT_REGION
```

## Step 3: Configure Terraform Variables

```bash
cd labs/03-private-network-deployment
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

**For GCP:**
```hcl
cloud_provider = "gcp"
project_id = "your-project-id"
cluster_name = "implementation-studio-private"
region = "us-central1"

# IMPORTANT: Restrict bastion access to your IP!
# Get your IP: curl ifconfig.me
bastion_authorized_networks = ["YOUR.IP.ADDRESS/32"]
```

**For AWS:**
```hcl
cloud_provider = "aws"
cluster_name = "implementation-studio-private"
region = "us-west-2"
vpc_cidr = "10.0.0.0/16"
availability_zones = ["us-west-2a", "us-west-2b"]

# IMPORTANT: Restrict bastion access to your IP!
# Get your IP: curl ifconfig.me
bastion_authorized_networks = ["YOUR.IP.ADDRESS/32"]
```

**Security Note:** Restricting `bastion_authorized_networks` to your IP is critical for security. Use `curl ifconfig.me` to get your public IP.

## Step 4: Initialize Terraform

```bash
./scripts/setup.sh
```

Or manually:

```bash
terraform init
```

This downloads the required providers and modules.

## Step 5: Review Terraform Plan

```bash
terraform plan
```

Review the resources that will be created:

**GCP:**
- Private VPC network with private and management subnets
- Private GKE cluster (private endpoint)
- Bastion host
- Artifact Registry
- Firewall rules

**AWS:**
- Private VPC network with private and management subnets
- Private EKS cluster (private endpoint)
- Bastion host (EC2 instance)
- ECR repository
- Security groups

**Key things to verify:**
- **GCP:** Master IP CIDR doesn't overlap with subnets
- **Both:** Bastion authorized networks are restricted
- **GCP:** Private subnet has Private Google Access enabled
- **AWS:** VPC CIDR doesn't conflict with existing networks

## Step 6: Apply Infrastructure

```bash
terraform apply
```

This will take:
- **GCP:** 10-15 minutes (GKE cluster creation is longest)
- **AWS:** 15-20 minutes (EKS cluster creation is longest)

**What's being created:**
1. Private VPC network (~2-3 minutes)
2. Private Kubernetes cluster (~8-12 minutes)
3. Bastion host (~2-3 minutes)
4. Security/firewall rules (~1 minute)
5. Container registry (~1 minute)

## Step 7: Get Bastion Details

After Terraform completes, get bastion information:

**GCP:**
```bash
# Get bastion SSH command
terraform output bastion_ssh_command

# Get bastion external IP
terraform output gcp_bastion_external_ip

# Get cluster name
terraform output cluster_name
```

**AWS:**
```bash
# Get bastion public IP
terraform output aws_bastion_public_ip

# Get cluster name
terraform output cluster_name

# Get credentials command
terraform output get_credentials_command
```

## Step 8: Access Bastion Host

```bash
# Use the automated script (works for both providers)
./scripts/bastion-access.sh
```

**GCP - Manual Access:**
```bash
# Get bastion details from Terraform
BASTION_NAME=$(terraform output -raw gcp_bastion_name)
BASTION_ZONE=$(terraform output -raw gcp_bastion_zone)

# SSH to bastion
gcloud compute ssh $BASTION_NAME \
  --zone $BASTION_ZONE \
  --project $PROJECT_ID
```

**AWS - Manual Access:**
```bash
# Get bastion IP
BASTION_IP=$(terraform output -raw aws_bastion_public_ip)

# SSH to bastion (requires SSH key)
ssh -i ~/.ssh/id_rsa ec2-user@$BASTION_IP

# Or use Systems Manager Session Manager (recommended)
# First, get instance ID
INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=*bastion" \
  --query 'Reservations[0].Instances[0].InstanceId' \
  --output text)

# Then connect
aws ssm start-session --target $INSTANCE_ID
```

**First-time SSH:** 
- **GCP:** You may be prompted to create SSH keys. Follow the prompts.
- **AWS:** Ensure your SSH key is added to the bastion instance or use Systems Manager.

## Step 9: Get Cluster Credentials (From Bastion)

Once connected to the bastion:

**GCP:**
```bash
# Get cluster credentials using INTERNAL IP
# This is critical - don't forget --internal-ip!
gcloud container clusters get-credentials <cluster-name> \
  --region <region> \
  --project $PROJECT_ID \
  --internal-ip
```

**AWS:**
```bash
# Get cluster credentials
aws eks update-kubeconfig \
  --region <region> \
  --name <cluster-name>
```

**Tip:** You can get the exact command from Terraform output:
```bash
# From local machine (before SSH)
terraform output get_credentials_command
```

**Important:** 
- **GCP:** The `--internal-ip` flag is required for private clusters. Without it, kubectl will try to use the public endpoint (which doesn't exist).
- **AWS:** The EKS cluster endpoint is automatically private when configured with `private_endpoint = true`.

## Step 10: Verify Cluster Access

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

## Step 11: Deploy Argo Workflows

From the bastion, deploy Argo Workflows:

```bash
# Use the deployment script (automatically detects provider)
./scripts/deploy-argo.sh
```

The script will:
- Detect the cloud provider (GCP or AWS)
- Install Ingress NGINX with provider-specific annotations
- Install Argo Workflows
- Configure internal load balancer

**Manual Deployment:**

```bash
# Add Helm repos
helm repo add argo https://argoproj.github.io/argo-helm
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Create namespaces
kubectl create namespace argo
kubectl create namespace ingress-nginx

# Install Internal Ingress NGINX (provider-specific)
# GCP:
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --set controller.service.type=LoadBalancer \
  --set controller.service.annotations."cloud\.google\.com/load-balancer-type"="Internal" \
  --set controller.admissionWebhooks.enabled=false \
  --wait

# AWS:
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --set controller.service.type=LoadBalancer \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-scheme"="internal" \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-type"="nlb" \
  --set controller.admissionWebhooks.enabled=false \
  --wait

# Install Argo Workflows (same for both providers)
helm install argo-workflows argo/argo-workflows \
  --namespace argo \
  --values ../../modules/kubernetes/argo-workflows/helm-values.yaml \
  --wait
```

## Step 12: Create Internal Ingress

From the bastion, create an internal ingress for Argo Workflows UI:

```bash
# Apply the internal ingress manifest
kubectl apply -f manifests/internal-ingress.yaml

# Check ingress status
kubectl get ingress -n argo

# Get internal load balancer IP
kubectl get service ingress-nginx-controller -n ingress-nginx
```

The internal IP will be in the VPC range (e.g., 10.0.x.x for both providers).

## Step 13: Submit Sample Workflow

From the bastion, submit a test workflow:

```bash
# Apply sample workflow
kubectl apply -f manifests/sample-workflow.yaml

# Watch workflow
kubectl get workflows -n argo -w

# Check workflow status
kubectl get workflow -n argo
```

## Step 14: Access Argo UI (Optional)

Since the load balancer is internal, you have a few options:

### Option 1: Port Forwarding from Bastion

```bash
# From bastion
kubectl port-forward -n argo svc/argo-workflows-server 8080:2746
```

Then from your local machine, create an SSH tunnel:

**GCP:**
```bash
# In another terminal (from local machine)
gcloud compute ssh <bastion-name> \
  --zone <zone> \
  --ssh-flag="-L 8080:localhost:8080"
```

**AWS:**
```bash
# In another terminal (from local machine)
ssh -i ~/.ssh/id_rsa -L 8080:localhost:8080 ec2-user@<bastion-ip>
```

Access UI at: http://localhost:8080

### Option 2: SSH Tunnel Directly

**GCP:**
```bash
# From local machine
gcloud compute ssh <bastion-name> \
  --zone <zone> \
  --ssh-flag="-L 8080:<internal-lb-ip>:80"
```

**AWS:**
```bash
# From local machine
ssh -i ~/.ssh/id_rsa -L 8080:<internal-lb-ip>:80 ec2-user@<bastion-ip>
```

### Option 3: Access from Another VM in VPC

If you have another VM in the VPC, you can access the internal IP directly.

## Step 15: Validate Deployment

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

## Step 16: Cleanup (When Done)

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

## Provider-Specific Notes

### GCP
- Private Google Access enables access to GCP services without external IPs
- Master authorized networks restrict API access to bastion subnet
- Internal load balancer requires annotation: `cloud.google.com/load-balancer-type=Internal`

### AWS
- VPC endpoints enable access to AWS services (S3, ECR) without Internet Gateway
- Security groups control access to EKS API endpoint
- Internal load balancer is automatic when using private subnets (or use annotation)

## Common Issues

### Cannot SSH to Bastion

**GCP:**
- Check firewall rules: `gcloud compute firewall-rules list`
- Verify your IP is in `bastion_authorized_networks`
- Check bastion is running: `gcloud compute instances list`

**AWS:**
- Check security groups: `aws ec2 describe-security-groups`
- Verify your IP is in security group rules
- Check bastion is running: `aws ec2 describe-instances --filters "Name=tag:Name,Values=*bastion"`

### Cannot Access Cluster from Bastion

**GCP:**
- Verify you used `--internal-ip` flag
- Check master authorized networks include bastion subnet
- Verify firewall rules allow bastion to master

**AWS:**
- Verify security groups allow bastion to EKS endpoint (port 443)
- Check IAM role has EKS access permissions
- Verify cluster endpoint is accessible from bastion subnet

### Image Pull Errors

**GCP:**
- Verify Private Google Access is enabled
- Check Artifact Registry permissions
- Ensure service account has correct roles

**AWS:**
- Verify VPC endpoints are configured (S3, ECR)
- Check IAM role has ECR pull permissions
- Ensure nodes can reach ECR endpoint

See [Troubleshooting Guide](./troubleshooting.md) for more details.

## Next Steps

After completing this lab:

1. Review the private VPC modules:
   - `modules/gcp/vpc-private/` (GCP)
   - `modules/aws/vpc-private/` (AWS)
2. Understand bastion host patterns and security
3. Learn about VPN/Interconnect for production
4. Proceed to Lab 04: Firewall-Restricted Deployment

## Additional Resources

**GCP:**
- [GKE Private Clusters](https://cloud.google.com/kubernetes-engine/docs/how-to/private-clusters)
- [Bastion Host Best Practices](https://cloud.google.com/solutions/connecting-securely)
- [Private Google Access](https://cloud.google.com/vpc/docs/private-google-access)

**AWS:**
- [EKS Private Clusters](https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html)
- [Systems Manager Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html)
- [VPC Endpoints](https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints.html)


# Lab 01: Step-by-Step Guide

## Prerequisites Check

Before starting, ensure you have:

```bash
# Check common tools (required for both providers)
terraform version    # Should be >= 1.5
kubectl version --client
helm version
```

### GCP-Specific Prerequisites

```bash
# Check GCP tools
gcloud version

# Check GCP authentication
gcloud auth list
gcloud config get-value project
```

### AWS-Specific Prerequisites

```bash
# Check AWS tools
aws --version

# Check AWS authentication
aws sts get-caller-identity
aws configure list
```

## Step 1: Choose Your Provider

Edit `terraform.tfvars` and set:

```hcl
cloud_provider = "gcp"  # or "aws"
```

## Step 2: Configure Provider-Specific Settings

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
  logging.googleapis.com \
  monitoring.googleapis.com
```

Edit `terraform.tfvars`:

```hcl
cloud_provider = "gcp"
project_id     = "your-project-id"
cluster_name   = "implementation-studio"
region         = "us-central1"
machine_type   = "e2-medium"
```

### Option B: AWS Configuration

```bash
# Verify AWS credentials
aws sts get-caller-identity

# Verify you have required permissions for EKS
aws iam get-role --role-name AWSServiceRoleForAmazonEKS || echo "Service-linked role will be created automatically"
```

Edit `terraform.tfvars`:

```hcl
cloud_provider     = "aws"
cluster_name       = "implementation-studio"
region             = "us-west-2"
vpc_cidr          = "10.0.0.0/16"
availability_zones = ["us-west-2a", "us-west-2b"]
instance_type     = "t3.medium"
```

## Step 3: Configure Terraform Variables

```bash
cd labs/01-standard-deployment
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your provider-specific values (see Step 2).

## Step 4: Initialize Terraform

```bash
terraform init
```

This downloads the required providers (Google and/or AWS) and modules.

## Step 5: Review Terraform Plan

```bash
terraform plan
```

Review the resources that will be created:

**GCP:**
- VPC network and subnets
- GKE cluster
- Artifact Registry

**AWS:**
- VPC network and subnets
- EKS cluster
- ECR repository

## Step 6: Apply Infrastructure

```bash
terraform apply
```

This will take 10-15 minutes. The cluster creation is the longest step.

**GCP:** GKE cluster creation typically takes 5-10 minutes
**AWS:** EKS cluster creation typically takes 10-15 minutes

## Step 7: Get Cluster Credentials

After Terraform completes, get cluster credentials.

### GCP

```bash
CLUSTER_NAME=$(terraform output -raw cluster_name)
REGION=$(terraform output -raw cluster_location)
PROJECT_ID=$(terraform output -raw project_id || grep project_id terraform.tfvars | cut -d'"' -f2)

gcloud container clusters get-credentials $CLUSTER_NAME \
  --region $REGION \
  --project $PROJECT_ID
```

### AWS

```bash
CLUSTER_NAME=$(terraform output -raw cluster_name)
REGION=$(grep -E '^region\s*=' terraform.tfvars | sed 's/.*=\s*"\(.*\)".*/\1/' | tr -d ' ')

aws eks update-kubeconfig \
  --region $REGION \
  --name $CLUSTER_NAME
```

### Or Use the Helper Script

```bash
# The deploy-argo.sh script handles credentials automatically
./scripts/deploy-argo.sh
```

Verify access:

```bash
kubectl get nodes
```

## Step 8: Deploy Argo Workflows

```bash
./scripts/deploy-argo.sh
```

This script:
1. Detects your provider (GCP or AWS)
2. Gets cluster credentials automatically
3. Adds Helm repositories
4. Creates namespaces
5. Installs Ingress NGINX
6. Installs Argo Workflows

## Step 9: Verify Deployment

```bash
./scripts/validate.sh
```

Check that all pods are running:

```bash
kubectl get pods -n argo
kubectl get pods -n ingress-nginx
```

## Step 10: Get Ingress IP

```bash
kubectl get service ingress-nginx-controller -n ingress-nginx
```

Note the EXTERNAL-IP address (or HOSTNAME for AWS).

**GCP:** Shows an IP address
**AWS:** Shows a hostname (e.g., `a1b2c3d4e5f6g7h8.elb.us-west-2.amazonaws.com`)

## Step 11: Submit a Sample Workflow

```bash
kubectl apply -f manifests/sample-workflow.yaml
```

Check workflow status:

```bash
kubectl get workflows -n argo
kubectl describe workflow hello-world -n argo
```

View workflow logs:

```bash
kubectl logs workflow/hello-world -n argo
```

## Step 12: Access Argo Workflows UI (Optional)

### Option 1: Port Forward (Works for Both Providers)

```bash
kubectl port-forward -n argo svc/argo-workflows-server 2746:2746
```

Then access: `https://localhost:2746`

### Option 2: Create Ingress (Provider-Specific)

**GCP Example:**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argo-workflows-ui
  namespace: argo
spec:
  ingressClassName: nginx
  rules:
  - host: argo.example.com  # Replace with your domain or use IP
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argo-workflows-server
            port:
              number: 2746
```

**AWS Example:**

Same YAML works, but you'll get an AWS ELB hostname. You can also configure a custom domain.

## Cleanup

When finished:

```bash
./scripts/cleanup.sh
```

Or manually:

```bash
terraform destroy
```

**Important:** Destroying may take 10-15 minutes. Be patient, especially when removing load balancers and clusters.

## Troubleshooting

### Provider-Specific Steps

See [Troubleshooting Guide](./troubleshooting.md) for provider-specific troubleshooting steps.

### Quick Checks

```bash
# Check cluster status (GCP)
gcloud container clusters describe $CLUSTER_NAME --region $REGION --project $PROJECT_ID

# Check cluster status (AWS)
aws eks describe-cluster --name $CLUSTER_NAME --region $REGION

# Check nodes
kubectl get nodes -o wide

# Check all resources
kubectl get all -n argo
kubectl get all -n ingress-nginx
```

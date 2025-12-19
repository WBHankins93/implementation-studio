# Lab 01: Step-by-Step Guide

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
  logging.googleapis.com \
  monitoring.googleapis.com
```

## Step 2: Configure Terraform Variables

```bash
cd labs/01-standard-deployment
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
project_id = "your-project-id"
cluster_name = "implementation-studio"
region = "us-central1"
```

## Step 3: Initialize Terraform

```bash
terraform init
```

This downloads the required providers and modules.

## Step 4: Review Terraform Plan

```bash
terraform plan
```

Review the resources that will be created:
- VPC network and subnets
- GKE cluster
- Artifact Registry

## Step 5: Apply Infrastructure

```bash
terraform apply
```

This will take 5-10 minutes. The cluster creation is the longest step.

## Step 6: Get Cluster Credentials

After Terraform completes, get cluster credentials:

```bash
gcloud container clusters get-credentials implementation-studio \
  --region us-central1 \
  --project $PROJECT_ID
```

Verify access:

```bash
kubectl get nodes
```

## Step 7: Deploy Argo Workflows

```bash
./scripts/deploy-argo.sh
```

This script:
1. Adds Helm repositories
2. Creates namespaces
3. Installs Ingress NGINX
4. Installs Argo Workflows

## Step 8: Verify Deployment

```bash
./scripts/validate.sh
```

Check that all pods are running:

```bash
kubectl get pods -n argo
kubectl get pods -n ingress-nginx
```

## Step 9: Get Ingress IP

```bash
kubectl get service ingress-nginx-controller -n ingress-nginx
```

Note the EXTERNAL-IP address.

## Step 10: Submit a Sample Workflow

```bash
kubectl apply -f manifests/sample-workflow.yaml
```

Check workflow status:

```bash
kubectl get workflows -n argo
kubectl describe workflow hello-world -n argo
```

## Step 11: Access Argo Workflows UI (Optional)

To access the UI, create an Ingress resource:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argo-workflows-ui
  namespace: argo
spec:
  ingressClassName: nginx
  rules:
  - host: argo.your-domain.com  # Replace with your domain or use IP
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

## Cleanup

When finished:

```bash
./scripts/cleanup.sh
```

Or manually:

```bash
terraform destroy
```

## Troubleshooting

See [Troubleshooting Guide](./troubleshooting.md) for common issues.


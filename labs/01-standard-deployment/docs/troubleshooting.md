# Lab 01 Troubleshooting

## Common Issues and Solutions

## Provider Selection

### Error: "Invalid cloud provider value"

**Problem:** `cloud_provider` variable is not set correctly.

**Solution:**
```hcl
# In terraform.tfvars, use exactly:
cloud_provider = "gcp"  # or "aws"
```

---

## Terraform Issues

### GCP: Error "API not enabled"

**Problem:** Required GCP APIs are not enabled.

**Solution:**
```bash
gcloud services enable \
  container.googleapis.com \
  compute.googleapis.com \
  artifactregistry.googleapis.com \
  logging.googleapis.com \
  monitoring.googleapis.com
```

### AWS: Error "Service-linked role not found"

**Problem:** EKS service-linked role doesn't exist.

**Solution:**
```bash
# Create the service-linked role (one-time per account)
aws iam create-service-linked-role \
  --aws-service-name eks.amazonaws.com
```

This is usually created automatically, but sometimes needs to be done manually.

### GCP: Error "Insufficient permissions"

**Problem:** Service account lacks required permissions.

**Solution:** Ensure your account has:
- Compute Admin
- Kubernetes Engine Admin
- Service Account User

```bash
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="user:$(gcloud config get-value account)" \
  --role="roles/container.admin"
```

### AWS: Error "AccessDenied: User is not authorized"

**Problem:** IAM user/role lacks required permissions for EKS.

**Solution:** Ensure your IAM user/role has:
- `eks:CreateCluster`, `eks:DescribeCluster`, `eks:DeleteCluster`
- `eks:CreateNodegroup`, `eks:DescribeNodegroup`, `eks:DeleteNodegroup`
- `iam:CreateRole`, `iam:AttachRolePolicy`
- `ec2:CreateSecurityGroup`, `ec2:CreateTags`

Attach the `AmazonEKSClusterPolicy` managed policy or equivalent permissions.

### Error "Quota exceeded" (GCP) or "Service Quota" (AWS)

**Problem:** Account has quota limits.

**GCP Solution:**
```bash
# Check quotas
gcloud compute project-info describe --project=$PROJECT_ID

# Request quota increase in GCP Console:
# https://console.cloud.google.com/iam-admin/quotas
```

**AWS Solution:**
```bash
# Check service quotas
aws service-quotas get-service-quota \
  --service-code eks \
  --quota-code L-1194A341

# Request quota increase in AWS Console:
# https://console.aws.amazon.com/servicequotas/
```

---

## Kubernetes Access Issues

### kubectl: "Unable to connect to the server"

**Problem:** Cluster credentials not configured.

**GCP Solution:**
```bash
CLUSTER_NAME=$(terraform output -raw cluster_name)
REGION=$(terraform output -raw cluster_location || grep region terraform.tfvars | cut -d'"' -f2)
PROJECT_ID=$(grep project_id terraform.tfvars | cut -d'"' -f2)

gcloud container clusters get-credentials $CLUSTER_NAME \
  --region $REGION \
  --project $PROJECT_ID
```

**AWS Solution:**
```bash
CLUSTER_NAME=$(terraform output -raw cluster_name)
REGION=$(grep -E '^region\s*=' terraform.tfvars | sed 's/.*=\s*"\(.*\)".*/\1/' | tr -d ' ')

aws eks update-kubeconfig \
  --region $REGION \
  --name $CLUSTER_NAME
```

**Quick Fix:** Use the helper script:
```bash
./scripts/deploy-argo.sh  # This handles credentials automatically
```

### kubectl: "The connection to the server was refused"

**Problem:** Cluster may not be fully ready or endpoint is incorrect.

**Solution:**
- Wait a few more minutes after cluster creation
- Verify cluster status (see provider-specific commands below)
- Check firewall rules (GCP) or security groups (AWS) allow access

---

## Node Issues

### Pods stuck in "Pending"

**Problem:** Insufficient resources or node issues.

**Solution:**
```bash
# Check node status
kubectl get nodes
kubectl describe node <node-name>

# Check pod events
kubectl describe pod <pod-name> -n <namespace>

# Check for taints
kubectl describe nodes | grep -i taint
```

### Nodes not joining cluster

**GCP:** Check GKE node pool status:
```bash
gcloud container node-pools describe <pool-name> \
  --cluster $CLUSTER_NAME \
  --region $REGION \
  --project $PROJECT_ID
```

**AWS:** Check EKS node group status:
```bash
aws eks describe-nodegroup \
  --cluster-name $CLUSTER_NAME \
  --nodegroup-name <nodegroup-name> \
  --region $REGION
```

Common causes:
- IAM role permissions (check node IAM role)
- Security group rules (AWS) or firewall rules (GCP)
- Subnet configuration
- Insufficient capacity in availability zone

---

## Image Pull Issues

### Image pull errors

**Problem:** Cannot pull container images.

**Solution:**
- Check internet connectivity from nodes
- Verify image names are correct
- Check if using private registry (requires authentication)

**GCP Specific:**
```bash
# Verify Artifact Registry access
gcloud auth configure-docker <region>-docker.pkg.dev
```

**AWS Specific:**
```bash
# Verify ECR access
aws ecr get-login-password --region $REGION | \
  docker login --username AWS --password-stdin \
  <account-id>.dkr.ecr.$REGION.amazonaws.com
```

---

## Argo Workflows Issues

### Workflow stuck in "Pending"

**Problem:** Workflow controller not running or resource constraints.

**Solution:**
```bash
# Check controller status
kubectl get pods -n argo

# Check workflow events
kubectl describe workflow <workflow-name> -n argo

# Check resource quotas
kubectl get resourcequota -n argo
```

### Cannot access Argo UI

**Problem:** Ingress not configured or service not exposed.

**Solution:**
```bash
# Check service
kubectl get svc argo-workflows-server -n argo

# Check ingress
kubectl get ingress -n argo

# Port forward as workaround (works for both providers)
kubectl port-forward svc/argo-workflows-server 2746:2746 -n argo
# Then access https://localhost:2746
```

---

## Ingress Issues

### Ingress IP not assigned

**Problem:** Load balancer provisioning takes time.

**Solution:**
```bash
# Wait 2-5 minutes and watch
kubectl get service ingress-nginx-controller -n ingress-nginx -w

# Check events
kubectl describe service ingress-nginx-controller -n ingress-nginx
```

**GCP:** Check in Cloud Console → Network Services → Load Balancing
**AWS:** Check in AWS Console → EC2 → Load Balancers

### 502 Bad Gateway

**Problem:** Backend service not ready or misconfigured.

**Solution:**
```bash
# Check backend pods
kubectl get pods -n argo

# Check ingress configuration
kubectl describe ingress <ingress-name> -n argo

# Check nginx logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller
```

---

## Provider-Specific Debugging

### GCP Debugging Commands

```bash
# Check cluster status
gcloud container clusters describe $CLUSTER_NAME \
  --region $REGION \
  --project $PROJECT_ID

# Check node pools
gcloud container node-pools list \
  --cluster $CLUSTER_NAME \
  --region $REGION \
  --project $PROJECT_ID

# Check firewall rules
gcloud compute firewall-rules list --filter="network:default"

# Check logs
gcloud logging read "resource.type=gke_cluster" --limit 50
```

### AWS Debugging Commands

```bash
# Check cluster status
aws eks describe-cluster \
  --name $CLUSTER_NAME \
  --region $REGION

# Check node groups
aws eks list-nodegroups \
  --cluster-name $CLUSTER_NAME \
  --region $REGION

# Check security groups
aws ec2 describe-security-groups \
  --filters "Name=tag:Name,Values=*$CLUSTER_NAME*" \
  --region $REGION

# Check CloudWatch logs
aws logs tail /aws/eks/$CLUSTER_NAME/cluster --follow
```

---

## Common Debugging Commands (Both Providers)

### Check cluster status
```bash
kubectl cluster-info
kubectl get nodes -o wide
kubectl describe nodes
```

### Check all resources
```bash
kubectl get all -n argo
kubectl get all -n ingress-nginx
kubectl get all --all-namespaces
```

### View logs
```bash
# Argo Workflows
kubectl logs -n argo -l app=argo-workflows-server
kubectl logs -n argo -l app=workflow-controller

# Ingress NGINX
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller
```

### Check events
```bash
kubectl get events -n argo --sort-by='.lastTimestamp'
kubectl get events -n ingress-nginx --sort-by='.lastTimestamp'
kubectl get events --all-namespaces --sort-by='.lastTimestamp'
```

---

## Getting Help

1. Check the [VALIDATION-STATUS.md](../VALIDATION-STATUS.md)
2. Review provider logs:
   - **GCP:** Cloud Console → Logging
   - **AWS:** CloudWatch Logs
3. Check Kubernetes events: `kubectl get events --all-namespaces`
4. Open an issue on GitHub with:
   - Error messages
   - Relevant logs
   - Cloud provider and region
   - Terraform and Kubernetes versions
   - Provider-specific details (project ID for GCP, account ID for AWS)

---

## Provider Migration Tips

If you need to switch providers:

1. **Export existing data** (if any):
   ```bash
   kubectl get all --all-namespaces -o yaml > backup.yaml
   ```

2. **Destroy current provider resources:**
   ```bash
   # In terraform.tfvars, change cloud_provider
   terraform destroy
   ```

3. **Deploy with new provider:**
   ```bash
   # Update terraform.tfvars with new provider
   terraform init  # Re-download providers if needed
   terraform plan
   terraform apply
   ```

4. **Re-deploy workloads:**
   ```bash
   ./scripts/deploy-argo.sh
   kubectl apply -f manifests/
   ```

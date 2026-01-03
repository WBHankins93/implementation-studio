# Lab 06: Step-by-Step Guide

## Prerequisites Check

Before starting, ensure you have:

```bash
# Check common tools (required for all providers)
kubectl version --client
terraform version  # If using cloud provider
```

### Kind-Specific Prerequisites

```bash
kind version  # If using Kind
```

### GCP-Specific Prerequisites

```bash
gcloud version  # If using GCP
```

### AWS-Specific Prerequisites

```bash
aws --version  # If using AWS
aws sts get-caller-identity  # Verify AWS credentials
```

## Phase 1: Cluster Setup (10-15 minutes)

### Step 1: Choose Deployment Option

This lab supports three deployment options:

**Option A: Local (Kind) - Recommended for Learning**
- Free and fast
- No cloud account needed
- Perfect for learning multi-tenant patterns

**Option B: GCP (GKE)**
- Requires GCP account
- More realistic environment
- Free control plane

**Option C: AWS (EKS)**
- Requires AWS account
- Production-ready environment
- Control plane costs $0.10/hour

### Step 2: Configure Provider

Edit `terraform.tfvars`:

```hcl
# For Kind (local)
cloud_provider = "kind"
cluster_name = "multi-tenant-cluster"

# For GCP
cloud_provider = "gcp"
project_id = "your-project-id"
region = "us-central1"

# For AWS
cloud_provider = "aws"
region = "us-west-2"
vpc_cidr = "10.0.0.0/16"
availability_zones = ["us-west-2a", "us-west-2b"]
```

### Step 3: Setup Cluster

**If Using Kind:**

```bash
cd labs/06-multi-tenant-deployment
./scripts/setup.sh
```

This will create a Kind cluster automatically.

**If Using GCP:**

```bash
cd labs/06-multi-tenant-deployment
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars: set cloud_provider = "gcp" and project_id

terraform init
terraform plan
terraform apply

# Get credentials
terraform output get_credentials_command
eval $(terraform output -raw get_credentials_command)
```

**If Using AWS:**

```bash
cd labs/06-multi-tenant-deployment
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars: set cloud_provider = "aws" and region

terraform init
terraform plan
terraform apply

# Get credentials
terraform output get_credentials_command
eval $(terraform output -raw get_credentials_command)
```

### Step 4: Verify Cluster

```bash
# Verify cluster access
kubectl cluster-info
kubectl get nodes

# Verify network policy support (for GCP and AWS)
# GCP
kubectl get nodes -o jsonpath='{.items[0].metadata.labels}' | grep network-policy

# AWS (network policies work with VPC CNI)
kubectl get nodes
```

## Phase 2: Shared Services (5 minutes)

### Step 5: Create Shared Services Namespace

```bash
# Create shared services namespace
kubectl apply -f manifests/shared-services/namespace.yaml

# Verify
kubectl get namespace shared-services
```

### Step 6: Apply Shared Services Network Policy

```bash
# Apply network policy
kubectl apply -f manifests/shared-services/network-policy.yaml

# Verify
kubectl get networkpolicy -n shared-services
```

## Phase 3: Create Tenants (15-20 minutes)

### Step 7: Create First Tenant

```bash
# Create tenant with standard quota
./tenant-onboarding/create-tenant.sh tenant-a standard

# Verify tenant was created
kubectl get namespace tenant-a
kubectl get resourcequota -n tenant-a
kubectl get networkpolicy -n tenant-a
kubectl get role -n tenant-a
```

### Step 8: Create Second Tenant

```bash
# Create tenant with limited quota
./tenant-onboarding/create-tenant.sh tenant-b limited

# Verify
kubectl get namespace tenant-b
```

### Step 9: Create Third Tenant (Optional)

```bash
# Create another tenant
./tenant-onboarding/create-tenant.sh tenant-c standard
```

## Phase 4: Deploy Applications (10-15 minutes)

### Step 10: Deploy to Tenant A

```bash
# Deploy sample application
kubectl run nginx-a --image=nginx -n tenant-a

# Deploy Argo Workflow (if desired)
sed "s/{{TENANT_NAME}}/tenant-a/g" manifests/tenant-templates/argo-workflows.yaml | \
  kubectl apply -f -
```

### Step 11: Deploy to Tenant B

```bash
# Deploy sample application
kubectl run nginx-b --image=nginx -n tenant-b

# Verify deployment
kubectl get pods -n tenant-b
```

## Phase 5: Validate Isolation (15-20 minutes)

### Step 12: Test RBAC Isolation

```bash
# As tenant-a admin, try to access tenant-b
kubectl get pods -n tenant-b
# Should fail if RBAC is working (unless you're cluster admin)

# Check what you can access in tenant-a
kubectl get pods -n tenant-a
# Should work
```

### Step 13: Test Network Isolation

```bash
# Get pod IPs
TENANT_A_POD=$(kubectl get pod -n tenant-a -l run=nginx-a -o jsonpath='{.items[0].status.podIP}')
TENANT_B_POD=$(kubectl get pod -n tenant-b -l run=nginx-b -o jsonpath='{.items[0].status.podIP}')

# Try to reach tenant-b from tenant-a (should fail)
kubectl run test --image=busybox -n tenant-a --rm -it --restart=Never -- \
  wget -O- --timeout=5 http://$TENANT_B_POD || echo "✅ Network isolation working (connection failed as expected)"
```

### Step 14: Test Resource Quota

```bash
# Check current quota usage
kubectl describe resourcequota -n tenant-a

# Try to exceed quota (should fail)
kubectl run test-large --image=nginx -n tenant-a \
  --requests=cpu=10,memory=20Gi \
  --limits=cpu=10,memory=20Gi
# Should fail with quota exceeded error
```

### Step 15: Test Shared Services Access

```bash
# Deploy a service in shared-services
kubectl run shared-service --image=nginx -n shared-services
kubectl expose pod shared-service -n shared-services --port=80

# Try to access from tenant-a (should work)
kubectl run test --image=busybox -n tenant-a --rm -it --restart=Never -- \
  wget -O- http://shared-service.shared-services.svc.cluster.local
# Should succeed
```

## Phase 6: Validate Deployment (5 minutes)

### Step 16: Run Validation Script

```bash
./scripts/validate.sh
```

This will check:
- Shared services namespace
- Tenant namespaces
- Resource quotas
- Network policies
- RBAC configurations

### Step 17: Manual Verification

```bash
# List all tenants
kubectl get namespaces -l tenant

# Check quota usage across tenants
for ns in $(kubectl get namespaces -l tenant -o name | cut -d/ -f2); do
  echo "=== $ns ==="
  kubectl describe resourcequota -n $ns | grep -A 5 "Resource Quotas"
done
```

## Phase 7: Experiment (Optional, 20-30 minutes)

### Step 18: Test Different Scenarios

**Test Quota Adjustment:**
```bash
# Edit quota
kubectl edit resourcequota tenant-quota -n tenant-a
# Increase limits, save

# Verify new limits
kubectl describe resourcequota -n tenant-a
```

**Test RBAC Permissions:**
```bash
# Create read-only user
sed "s/{{NAMESPACE}}/tenant-a/g; s/{{USER}}/readonly@example.com/g" \
  ../../modules/kubernetes/rbac-patterns/read-only.yaml | \
  kubectl apply -f - -n tenant-a

# Test permissions (as that user)
kubectl auth can-i get pods -n tenant-a --as=readonly@example.com
kubectl auth can-i create pods -n tenant-a --as=readonly@example.com
```

**Test Network Policy Changes:**
```bash
# View current network policy
kubectl get networkpolicy -n tenant-a -o yaml

# Modify if needed
kubectl edit networkpolicy tenant-isolation -n tenant-a
```

## Phase 8: Cleanup (5 minutes)

### Step 19: Clean Up Resources

**Kind:**
```bash
kind delete cluster --name multi-tenant-cluster
```

**GCP/AWS:**
```bash
# Delete tenant namespaces
kubectl delete namespace tenant-a tenant-b tenant-c

# Delete shared services
kubectl delete namespace shared-services

# Destroy infrastructure
terraform destroy
```

## Provider-Specific Notes

### Kind (Local)

- **Setup Time:** < 1 minute
- **Cost:** Free
- **Network Policies:** Fully supported
- **Best For:** Learning, testing, development

### GCP (GKE)

- **Setup Time:** 5-10 minutes
- **Cost:** Free control plane, ~$0.10/hour per node
- **Network Policies:** Requires `network_policy_enabled = true`
- **Best For:** Production GCP deployments

### AWS (EKS)

- **Setup Time:** 10-15 minutes
- **Cost:** $0.10/hour control plane + ~$0.05/hour per node
- **Network Policies:** Works with VPC CNI (automatic)
- **Best For:** Production AWS deployments

## Tips for Success

### Do's

✅ **Start with Kind** - Faster, free, good for learning
✅ **Create Multiple Tenants** - Test isolation properly
✅ **Test Each Layer** - RBAC, quotas, network policies
✅ **Monitor Resource Usage** - Understand quota impact
✅ **Document Your Setup** - Keep notes on what you created

### Don'ts

❌ **Don't Skip Network Policies** - Critical for isolation
❌ **Don't Forget Limit Ranges** - Ensures all pods have resources
❌ **Don't Use ClusterRole** - Breaks namespace isolation
❌ **Don't Skip Validation** - Verify isolation works
❌ **Don't Forget Cleanup** - Free up resources

## Common Issues

See [Troubleshooting Guide](./troubleshooting.md) for detailed solutions to common issues.

## Next Steps

After completing this lab:

1. Review the Kubernetes modules in `modules/kubernetes/`
2. Understand different isolation strategies
3. Practice tenant lifecycle management
4. Experiment with different quota levels
5. Proceed to Lab 07: Integration Patterns

## Additional Resources

- [Isolation Strategies](./isolation-strategies.md)
- [Tenant Lifecycle](./tenant-lifecycle.md)
- [Resource Management](./resource-management.md)
- [Troubleshooting](./troubleshooting.md)

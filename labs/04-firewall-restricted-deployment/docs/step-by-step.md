# Lab 04: Step-by-Step Guide

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

- **GCP:** GKE cluster with firewall rules
- **AWS:** EKS cluster with security groups

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
cd labs/04-firewall-restricted-deployment
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

**For GCP:**
```hcl
cloud_provider = "gcp"
project_id = "your-project-id"
cluster_name = "implementation-studio-firewall"
region = "us-central1"

# Network configuration
public_subnet_cidr  = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"
proxy_subnet_cidr   = "10.0.3.0/24"

# Firewall configuration
enable_strict_egress = true
```

**For AWS:**
```hcl
cloud_provider = "aws"
cluster_name = "implementation-studio-firewall"
region = "us-west-2"
vpc_cidr = "10.0.0.0/16"
availability_zones = ["us-west-2a", "us-west-2b"]

# Network configuration
public_subnet_cidr  = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"
proxy_subnet_cidr   = "10.0.3.0/24"

# Security group configuration
enable_strict_egress = true
```

## Step 4: Initialize Terraform

```bash
./scripts/setup.sh
```

Or manually:

```bash
terraform init
```

## Step 5: Review Terraform Plan

```bash
terraform plan
```

Review the resources that will be created:

**GCP:**
- VPC network with three subnets
- GKE cluster
- Proxy server VM
- Firewall rules (strict egress)
- Artifact Registry

**AWS:**
- VPC network with three subnets
- EKS cluster
- Proxy server EC2 instance
- Security groups (strict egress)
- ECR repository

**Key things to verify:**
- Proxy subnet CIDR doesn't overlap with other subnets
- **GCP:** Firewall rules have correct priorities
- **GCP:** Node tags match firewall rule targets
- **AWS:** Security group rules allow proxy access

## Step 6: Apply Infrastructure

```bash
terraform apply
```

This will take:
- **GCP:** 10-15 minutes (GKE cluster creation is longest)
- **AWS:** 15-20 minutes (EKS cluster creation is longest)

**What's being created:**
1. VPC network and subnets (~2-3 minutes)
2. Kubernetes cluster (~8-12 minutes)
3. Proxy server (~2-3 minutes)
4. Firewall rules/security groups (~1 minute)
5. Container registry (~1 minute)

## Step 7: Get Proxy IP

After Terraform completes:

```bash
# Get proxy internal IP
terraform output proxy_internal_ip

# Get proxy external IP (for verification)
terraform output proxy_external_ip

# Get proxy URL for environment variables
terraform output proxy_url
```

**Note the proxy internal IP** - you'll need it for the next steps.

## Step 8: Get Cluster Credentials

**GCP:**
```bash
# Get cluster credentials
gcloud container clusters get-credentials <cluster-name> \
  --region <region> \
  --project $PROJECT_ID

# Verify access
kubectl get nodes
```

**AWS:**
```bash
# Get cluster credentials
aws eks update-kubeconfig \
  --region <region> \
  --name <cluster-name>

# Verify access
kubectl get nodes
```

**Tip:** You can get the exact command from Terraform output:
```bash
terraform output get_credentials_command
```

## Step 9: Verify Proxy is Running

**GCP:**
```bash
# Get proxy details
PROXY_NAME=$(terraform output -raw gcp_proxy_name)
PROXY_ZONE=$(terraform output -raw gcp_proxy_zone)

# SSH to proxy and check Squid
gcloud compute ssh $PROXY_NAME --zone $PROXY_ZONE --project $PROJECT_ID

# On proxy, check Squid status
sudo systemctl status squid

# Test proxy locally
curl -v --proxy http://localhost:3128 https://www.google.com

# Exit proxy
exit
```

**AWS:**
```bash
# Get proxy details
PROXY_IP=$(terraform output -raw aws_proxy_public_ip)

# SSH to proxy (requires SSH key)
ssh -i ~/.ssh/id_rsa ec2-user@$PROXY_IP

# On proxy, check Squid status
sudo systemctl status squid

# Test proxy locally
curl -v --proxy http://localhost:3128 https://www.google.com

# Exit proxy
exit
```

## Step 10: Deploy Argo Workflows with Proxy

```bash
# Deploy Argo Workflows (script will update proxy ConfigMap)
./scripts/deploy-argo.sh
```

The script will:
1. Update the proxy ConfigMap with the actual proxy IP
2. Apply network policies
3. Install Ingress NGINX
4. Install Argo Workflows with proxy configuration

## Step 11: Verify Proxy Configuration

```bash
# Check proxy ConfigMap
kubectl get configmap proxy-config -n argo -o yaml

# Verify Argo server has proxy env vars
kubectl get deployment argo-workflows-server -n argo -o yaml | grep -i proxy

# Check network policies
kubectl get networkpolicy -n argo
```

## Step 12: Test Egress Restrictions

```bash
# Run the test script
./scripts/test-egress.sh
```

This will test:
1. Direct egress (should fail)
2. Egress through proxy (should succeed)
3. Internal connectivity (should work)
4. DNS resolution (should work)

## Step 13: Submit Test Workflow

```bash
# Submit a test workflow
kubectl apply -f manifests/sample-workflow.yaml

# Watch the workflow
kubectl get workflows -n argo -w

# Check workflow logs
kubectl logs -n argo -l workflows.argoproj.io/workflow -f
```

The workflow should:
- Start successfully
- Use proxy for external connections
- Complete without errors

## Step 14: Verify Firewall Rules/Security Groups

**GCP:**
```bash
# List firewall rules
gcloud compute firewall-rules list --filter="network=<vpc-name>"

# Check egress rules specifically
gcloud compute firewall-rules list --filter="direction=EGRESS"

# Verify deny-all rule exists
gcloud compute firewall-rules describe <vpc-name>-deny-all-egress

# Verify proxy allow rule exists
gcloud compute firewall-rules describe <vpc-name>-allow-proxy"
```

**AWS:**
```bash
# Get security group IDs
SECURITY_GROUPS=$(terraform output -raw security_groups)

# Describe security groups
for sg in $(echo $SECURITY_GROUPS | tr ',' ' '); do
  aws ec2 describe-security-groups --group-ids $sg --region <region>
done

# Check egress rules
aws ec2 describe-security-group-rules \
  --filters "Name=group-id,Values=<security-group-id>" \
  --region <region> \
  --query 'SecurityGroupRules[?IsEgress==`true`]'
```

## Step 15: Validate Deployment

```bash
./scripts/validate.sh
```

This will check:
- Namespaces exist
- Proxy ConfigMap is configured
- Network policies are applied
- Argo Workflows is running
- Ingress NGINX is running
- Firewall rules/security groups are created

## Step 16: Test Real-World Scenario

Create a workflow that actually needs external access:

```bash
cat > test-external-access.yaml <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: test-external-
  namespace: argo
spec:
  entrypoint: test
  templates:
    - name: test
      container:
        image: curlimages/curl:latest
        command: [sh, -c]
        args:
          - |
            echo "Testing external access through proxy..."
            echo "HTTP_PROXY: \$HTTP_PROXY"
            curl -v https://httpbin.org/get
EOF

kubectl apply -f test-external-access.yaml
kubectl get workflows -n argo
kubectl logs -n argo -l workflows.argoproj.io/workflow -f
```

## Step 17: Monitor Proxy Logs

**GCP:**
```bash
# SSH to proxy
PROXY_NAME=$(terraform output -raw gcp_proxy_name)
PROXY_ZONE=$(terraform output -raw gcp_proxy_zone)

gcloud compute ssh $PROXY_NAME --zone $PROXY_ZONE --project $PROJECT_ID

# Watch proxy access log
sudo tail -f /var/log/squid/access.log

# You should see requests from GKE nodes
# Exit when done
exit
```

**AWS:**
```bash
# SSH to proxy
PROXY_IP=$(terraform output -raw aws_proxy_public_ip)

ssh -i ~/.ssh/id_rsa ec2-user@$PROXY_IP

# Watch proxy access log
sudo tail -f /var/log/squid/access.log

# You should see requests from EKS nodes
# Exit when done
exit
```

## Step 18: Document Egress Requirements

Practice documenting what endpoints your application needs:

1. Review [Egress Requirements Guide](./egress-requirements.md)
2. Identify all external endpoints used
3. Document each endpoint with:
   - Purpose
   - Protocol and ports
   - Destination
   - Frequency
   - Security controls

## Step 19: Cleanup (When Done)

When you're finished with the lab:

```bash
./scripts/cleanup.sh
```

Or manually:

```bash
terraform destroy
```

**Note:** Make sure to exit any SSH sessions to the proxy before destroying.

## Provider-Specific Notes

### GCP Firewall Rules
- Firewall rules are network-level and apply to all instances with matching tags
- Can explicitly deny traffic (deny-all rule)
- Rules have priorities (lower number = higher priority)
- Private Google Access can be enabled for GCP services

### AWS Security Groups
- Security groups are allow-only (implicit deny)
- Rules apply at the instance/ENI level
- Each instance can have multiple security groups
- VPC prefix lists can be used for AWS services

## Common Issues

### Proxy not accessible from nodes

**GCP:**
- Check firewall rule allows nodes to proxy
- Verify proxy subnet CIDR in firewall rule
- Check proxy is running: `systemctl status squid`

**AWS:**
- Check security group allows nodes to proxy (port 3128)
- Verify security group is attached to nodes
- Check proxy is running: `systemctl status squid`

### Direct egress still works

**GCP:**
- Verify firewall rules are applied to nodes
- Check node tags match firewall rule targets
- Verify deny-all rule has correct priority

**AWS:**
- Verify security group only allows proxy egress
- Check no default allow-all egress rule exists
- Verify security group is attached to node group

### Workflows fail with connection errors

- Verify proxy ConfigMap has correct IP
- Check Argo Workflows has proxy env vars
- Test proxy connectivity manually
- Verify proxy is accessible from node subnet

See [Troubleshooting Guide](./troubleshooting.md) for more details.

## Next Steps

After completing this lab:

1. Review the firewall/security group modules:
   - `modules/gcp/firewall-rules/` (GCP)
   - `modules/aws/security-groups/` (AWS)
2. Practice documenting egress requirements
3. Review the security team guide
4. Understand proxy patterns
5. Proceed to Lab 05: The POC Sprint

## Additional Resources

**GCP:**
- [GCP Firewall Rules](https://cloud.google.com/vpc/docs/firewalls)
- [Private Google Access](https://cloud.google.com/vpc/docs/private-google-access)

**AWS:**
- [AWS Security Groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html)
- [VPC Prefix Lists](https://docs.aws.amazon.com/vpc/latest/userguide/managed-prefix-lists.html)

**Kubernetes:**
- [Kubernetes Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)

**Squid:**
- [Squid Proxy Documentation](http://www.squid-cache.org/)

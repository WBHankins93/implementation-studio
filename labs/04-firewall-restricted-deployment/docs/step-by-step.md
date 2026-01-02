# Lab 04: Step-by-Step Guide

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
cd labs/04-firewall-restricted-deployment
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
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

## Step 3: Initialize Terraform

```bash
./scripts/setup.sh
```

Or manually:

```bash
terraform init
```

## Step 4: Review Terraform Plan

```bash
terraform plan
```

Review the resources that will be created:
- VPC network with three subnets
- GKE cluster
- Proxy server VM
- Firewall rules (strict egress)
- Artifact Registry

**Key things to verify:**
- Proxy subnet CIDR doesn't overlap with other subnets
- Firewall rules have correct priorities
- Node tags match firewall rule targets

## Step 5: Apply Infrastructure

```bash
terraform apply
```

This will take 10-15 minutes. The cluster creation is the longest step.

**What's being created:**
1. VPC network and subnets (~2 minutes)
2. GKE cluster (~8-10 minutes)
3. Proxy server (~2 minutes)
4. Firewall rules (~1 minute)

## Step 6: Get Proxy IP

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

## Step 7: Get Cluster Credentials

```bash
# Get cluster credentials
gcloud container clusters get-credentials <cluster-name> \
  --region <region> \
  --project $PROJECT_ID

# Verify access
kubectl get nodes
```

## Step 8: Verify Proxy is Running

```bash
# Get proxy details
PROXY_NAME=$(terraform output -raw proxy_name)
PROXY_ZONE=$(terraform output -raw proxy_zone)

# SSH to proxy and check Squid
gcloud compute ssh $PROXY_NAME --zone $PROXY_ZONE --project $PROJECT_ID

# On proxy, check Squid status
sudo systemctl status squid

# Test proxy locally
curl -v --proxy http://localhost:3128 https://www.google.com

# Exit proxy
exit
```

## Step 9: Deploy Argo Workflows with Proxy

```bash
# Deploy Argo Workflows (script will update proxy ConfigMap)
./scripts/deploy-argo.sh
```

The script will:
1. Update the proxy ConfigMap with the actual proxy IP
2. Apply network policies
3. Install Ingress NGINX
4. Install Argo Workflows with proxy configuration

## Step 10: Verify Proxy Configuration

```bash
# Check proxy ConfigMap
kubectl get configmap proxy-config -n argo -o yaml

# Verify Argo server has proxy env vars
kubectl get deployment argo-workflows-server -n argo -o yaml | grep -i proxy

# Check network policies
kubectl get networkpolicy -n argo
```

## Step 11: Test Egress Restrictions

```bash
# Run the test script
./scripts/test-egress.sh
```

This will test:
1. Direct egress (should fail)
2. Egress through proxy (should succeed)
3. Internal connectivity (should work)
4. DNS resolution (should work)

## Step 12: Submit Test Workflow

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

## Step 13: Verify Firewall Rules

```bash
# List firewall rules
gcloud compute firewall-rules list --filter="network=<vpc-name>"

# Check egress rules specifically
gcloud compute firewall-rules list --filter="direction=EGRESS"

# Verify deny-all rule exists
gcloud compute firewall-rules describe <vpc-name>-deny-all-egress

# Verify proxy allow rule exists
gcloud compute firewall-rules describe <vpc-name>-allow-proxy
```

## Step 14: Validate Deployment

```bash
./scripts/validate.sh
```

This will check:
- Namespaces exist
- Proxy ConfigMap is configured
- Network policies are applied
- Argo Workflows is running
- Ingress NGINX is running
- Firewall rules are created

## Step 15: Test Real-World Scenario

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

## Step 16: Monitor Proxy Logs

```bash
# SSH to proxy
PROXY_NAME=$(terraform output -raw proxy_name)
PROXY_ZONE=$(terraform output -raw proxy_zone)

gcloud compute ssh $PROXY_NAME --zone $PROXY_ZONE --project $PROJECT_ID

# Watch proxy access log
sudo tail -f /var/log/squid/access.log

# You should see requests from GKE nodes
# Exit when done
exit
```

## Step 17: Document Egress Requirements

Practice documenting what endpoints your application needs:

1. Review [Egress Requirements Guide](./egress-requirements.md)
2. Identify all external endpoints used
3. Document each endpoint with:
   - Purpose
   - Protocol and ports
   - Destination
   - Frequency
   - Security controls

## Step 18: Cleanup (When Done)

When you're finished with the lab:

```bash
./scripts/cleanup.sh
```

Or manually:

```bash
terraform destroy
```

**Note:** Make sure to exit any SSH sessions to the proxy before destroying.

## Common Issues

### Proxy not accessible from nodes

- Check firewall rule allows nodes to proxy
- Verify proxy subnet CIDR in firewall rule
- Check proxy is running: `systemctl status squid`

### Direct egress still works

- Verify firewall rules are applied to nodes
- Check node tags match firewall rule targets
- Verify deny-all rule has correct priority

### Workflows fail with connection errors

- Verify proxy ConfigMap has correct IP
- Check Argo Workflows has proxy env vars
- Test proxy connectivity manually

See [Troubleshooting Guide](./troubleshooting.md) for more details.

## Next Steps

After completing this lab:

1. Review the firewall-rules module
2. Practice documenting egress requirements
3. Review the security team guide
4. Understand proxy patterns
5. Proceed to Lab 05: The POC Sprint

## Additional Resources

- [GCP Firewall Rules](https://cloud.google.com/vpc/docs/firewalls)
- [Kubernetes Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [Squid Proxy Documentation](http://www.squid-cache.org/)


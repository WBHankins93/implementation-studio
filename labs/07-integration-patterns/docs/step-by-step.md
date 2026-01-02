# Step-by-Step Guide: Integration Patterns

This guide walks through deploying and testing integration patterns in Lab 07.

## Prerequisites

- GCP project with billing enabled
- `gcloud` CLI configured
- `kubectl` installed
- `terraform` >= 1.5
- `helm` 3.x

## Step 1: Infrastructure Setup

### 1.1 Configure Terraform

```bash
cd labs/07-integration-patterns
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
project_id = "your-gcp-project-id"
cluster_name = "integration-patterns"
region = "us-central1"

# Optional: Set to true to create Cloud SQL for database examples
create_cloud_sql = false
```

### 1.2 Initialize and Deploy

```bash
# Initialize Terraform
terraform init

# Review plan
terraform plan

# Deploy infrastructure
terraform apply
```

### 1.3 Get Cluster Credentials

```bash
# Get credentials command from output
terraform output get_credentials_command

# Run the command (example)
gcloud container clusters get-credentials integration-patterns \
  --region us-central1 \
  --project your-gcp-project-id

# Verify connection
kubectl get nodes
```

## Step 2: Deploy Base Application

### 2.1 Create Namespace

```bash
kubectl apply -f manifests/namespace.yaml
```

### 2.2 Deploy Argo Workflows (Optional)

If you want to test integrations with Argo Workflows:

```bash
# Add Argo Helm repo
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Install Argo Workflows
helm install argo-workflows argo/argo-workflows \
  --namespace argo \
  --create-namespace
```

## Step 3: Authentication Integration

### 3.1 OAuth2 Proxy

#### 3.1.1 Register OAuth Application

**For Google:**
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. APIs & Services → Credentials
3. Create OAuth 2.0 Client ID
4. Add authorized redirect URI: `https://your-domain.com/oauth2/callback`
5. Note Client ID and Client Secret

**For GitHub:**
1. Go to GitHub Settings → Developer settings → OAuth Apps
2. Create new OAuth App
3. Set Authorization callback URL: `https://your-domain.com/oauth2/callback`
4. Note Client ID and Client Secret

#### 3.1.2 Generate Cookie Secret

```bash
openssl rand -base64 32 | head -c 32 | base64
```

#### 3.1.3 Update Configuration

Edit `auth-integration/oauth-proxy/oauth2-proxy.yaml`:
- Replace `YOUR_CLIENT_ID` with your OAuth client ID
- Replace `YOUR_CLIENT_SECRET` with your OAuth client secret
- Replace `GENERATE_WITH_OPENSSL` with generated cookie secret
- Update `redirect_url` and `cookie_domains` with your domain
- Update `upstreams` to point to your application

#### 3.1.4 Deploy

```bash
kubectl apply -f auth-integration/oauth-proxy/oauth2-proxy.yaml
```

#### 3.1.5 Verify

```bash
# Check deployment
kubectl get pods -n oauth-proxy

# Check service
kubectl get svc -n oauth-proxy

# Check ingress
kubectl get ingress -n oauth-proxy
```

### 3.2 SAML Integration

See `auth-integration/saml-example/README.md` for SAML setup instructions.

**Note:** SAML requires an identity provider (Okta, Azure AD, etc.) and is typically configured per customer.

### 3.3 LDAP/AD Integration

See `auth-integration/ldap-example/README.md` for LDAP setup instructions.

**Note:** LDAP requires access to an LDAP/AD server and is typically configured per customer.

## Step 4: Database Integration

### 4.1 Cloud SQL Proxy

#### 4.1.1 Create Cloud SQL Instance (Optional)

If you set `create_cloud_sql = true` in `terraform.tfvars`, Terraform will create the instance. Otherwise:

```bash
gcloud sql instances create my-instance \
  --database-version=POSTGRES_14 \
  --tier=db-f1-micro \
  --region=us-central1 \
  --network=projects/PROJECT_ID/global/networks/VPC_NAME
```

#### 4.1.2 Create Service Account

```bash
# Create service account
gcloud iam service-accounts create cloud-sql-proxy \
  --display-name="Cloud SQL Proxy"

# Grant Cloud SQL Client role
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:cloud-sql-proxy@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/cloudsql.client"
```

#### 4.1.3 Enable Workload Identity

```bash
# Get GKE service account
GKE_SA=$(gcloud container clusters describe CLUSTER_NAME \
  --region=REGION \
  --format="get(workloadIdentityConfig.workloadPool)")

# Bind service accounts
gcloud iam service-accounts add-iam-policy-binding \
  cloud-sql-proxy@PROJECT_ID.iam.gserviceaccount.com \
  --role roles/iam.workloadIdentityUser \
  --member "serviceAccount:${GKE_SA}.svc.id.goog[database/cloud-sql-proxy]"
```

#### 4.1.4 Update Configuration

Edit `database-connectivity/cloud-sql-proxy/cloud-sql-proxy.yaml`:
- Replace `PROJECT_ID` with your GCP project ID
- Replace `REGION` with your Cloud SQL region
- Replace `INSTANCE_NAME` with your Cloud SQL instance name
- Update service account annotation

#### 4.1.5 Deploy

```bash
kubectl apply -f database-connectivity/cloud-sql-proxy/cloud-sql-proxy.yaml
```

#### 4.1.6 Verify

```bash
# Check deployment
kubectl get pods -n database

# Check service
kubectl get svc -n database

# Test connection (from app pod)
kubectl exec -it -n database deployment/app-with-db -- psql -h cloud-sql-proxy -U appuser -d appdb
```

### 4.2 External Database

See `database-connectivity/external-database/README.md` for external database setup.

**Note:** External database connectivity requires VPN or network configuration specific to the customer environment.

### 4.3 Connection Pooling

See `database-connectivity/connection-pooling/README.md` for connection pooling setup.

## Step 5: API Gateway

### 5.1 Kong

#### 5.1.1 Deploy Kong

```bash
kubectl apply -f api-gateway/kong-example/kong-deployment.yaml
```

#### 5.1.2 Verify

```bash
# Check deployment
kubectl get pods -n kong

# Get service IP
kubectl get svc kong-proxy -n kong

# Test Kong admin API
kubectl port-forward -n kong svc/kong-admin 8001:8001
curl http://localhost:8001/
```

#### 5.1.3 Access via Gateway

```bash
# Get proxy service IP
KONG_IP=$(kubectl get svc kong-proxy -n kong -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Access Argo Workflows via Kong
curl http://${KONG_IP}/argo
```

### 5.2 GCP API Gateway

See `api-gateway/gcp-api-gateway/README.md` for GCP API Gateway setup.

**Note:** GCP API Gateway is a managed service and requires API configuration.

## Step 6: Service Mesh (Optional)

### 6.1 Install Istio

```bash
# Download Istio
curl -L https://istio.io/downloadIstio | sh -
cd istio-*

# Install with demo profile
istioctl install --set profile=demo

# Enable sidecar injection
kubectl label namespace default istio-injection=enabled
```

### 6.2 Verify

```bash
kubectl get pods -n istio-system
```

See `service-mesh/istio-basics/README.md` for Istio configuration examples.

## Step 7: Validation

### 7.1 Run Validation Script

```bash
./scripts/validate.sh
```

### 7.2 Manual Verification

**Authentication:**
- Access application via OAuth2 Proxy
- Verify authentication flow
- Check session management

**Database:**
- Test database connection
- Verify query execution
- Check connection pooling

**API Gateway:**
- Test routing through gateway
- Verify rate limiting
- Check authentication

## Step 8: Testing Integration Patterns

### 8.1 Test OAuth2 Proxy

1. Access application URL
2. Should redirect to OAuth provider
3. Authenticate
4. Should redirect back to application
5. Access should be granted

### 8.2 Test Cloud SQL Proxy

1. Connect to database via proxy
2. Execute test query
3. Verify connection pooling
4. Check metrics

### 8.3 Test Kong

1. Access application via Kong
2. Verify routing
3. Test rate limiting
4. Check logs

## Troubleshooting

See [Troubleshooting Guide](./troubleshooting.md) for common issues and solutions.

## Cleanup

To destroy all resources:

```bash
./scripts/cleanup.sh
```

**Warning:** This will delete the GKE cluster, VPC, and all integration deployments!


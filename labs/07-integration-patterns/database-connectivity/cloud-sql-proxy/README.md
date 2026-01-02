# Cloud SQL Proxy Integration

Cloud SQL Proxy provides secure connectivity to Cloud SQL instances from GKE without exposing public IPs.

## What is Cloud SQL Proxy?

Cloud SQL Proxy is a secure proxy that allows applications to connect to Cloud SQL instances using IAM authentication, without needing to whitelist IP addresses or manage SSL certificates.

## Architecture

```
Application Pod
   │
   │ (via service)
   ▼
Cloud SQL Proxy Pod
   │
   │ (IAM-authenticated)
   ▼
Cloud SQL Instance
```

## Setup

### 1. Create Cloud SQL Instance

```bash
# Via Terraform (included in lab)
# Or manually:
gcloud sql instances create my-instance \
  --database-version=POSTGRES_14 \
  --tier=db-f1-micro \
  --region=us-central1 \
  --network=projects/PROJECT_ID/global/networks/VPC_NAME
```

### 2. Create Service Account

```bash
# Create service account
gcloud iam service-accounts create cloud-sql-proxy \
  --display-name="Cloud SQL Proxy"

# Grant Cloud SQL Client role
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:cloud-sql-proxy@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/cloudsql.client"
```

### 3. Enable Workload Identity

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

### 4. Update Configuration

Edit `cloud-sql-proxy.yaml`:
- Replace `PROJECT_ID` with your GCP project ID
- Replace `REGION` with your Cloud SQL region
- Replace `INSTANCE_NAME` with your Cloud SQL instance name
- Update service account annotation

### 5. Deploy

```bash
kubectl apply -f cloud-sql-proxy.yaml
```

## Connection String Format

```
PROJECT_ID:REGION:INSTANCE_NAME
```

Example:
```
my-project:us-central1:my-instance
```

## Benefits

✅ **No Public IPs**: Cloud SQL doesn't need public IP
✅ **IAM Authentication**: Uses service account, no passwords
✅ **Automatic SSL**: Proxy handles SSL/TLS
✅ **Connection Pooling**: Proxy manages connections
✅ **High Availability**: Proxy can be replicated

## Alternatives

### Direct Private IP

If Cloud SQL has private IP:
- Connect directly via private IP
- Still requires VPC peering
- No proxy needed

### Public IP with Authorized Networks

- Cloud SQL with public IP
- Whitelist GKE node IPs
- Less secure, simpler setup

## Troubleshooting

### Connection Refused

**Check:**
- Cloud SQL instance is running
- Connection name is correct
- Service account has permissions
- Workload Identity is configured

### Authentication Failed

**Check:**
- Service account has `cloudsql.client` role
- Workload Identity binding is correct
- Service account annotation matches

## Additional Resources

- [Cloud SQL Proxy Documentation](https://cloud.google.com/sql/docs/postgres/sql-proxy)
- [Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity)


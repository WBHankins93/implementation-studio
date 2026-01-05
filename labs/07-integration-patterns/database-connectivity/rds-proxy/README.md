# RDS Proxy Integration

RDS Proxy provides secure, connection-pooled connectivity to RDS instances from EKS without exposing public IPs.

## What is RDS Proxy?

RDS Proxy is a fully managed database proxy service that:
- **Connection Pooling**: Reuses database connections efficiently
- **Failover**: Automatic failover to standby instances
- **IAM Authentication**: Optional IAM-based authentication
- **Secrets Manager**: Automatic credential rotation
- **Security**: No need to whitelist IP addresses

## Architecture

```
Application Pod
   │
   │ (via service)
   ▼
RDS Proxy Endpoint
   │
   │ (connection pooling)
   ▼
RDS Instance
```

## Setup

### 1. Create RDS Instance with Proxy

```bash
# Via Terraform (included in lab)
# Set create_database = true and create_rds_proxy = true in terraform.tfvars
terraform apply

# Get RDS Proxy endpoint
terraform output aws_rds_proxy_endpoint
```

### 2. Update Configuration

Edit `rds-proxy.yaml`:
- Replace `RDS_PROXY_ENDPOINT_PLACEHOLDER` with your RDS Proxy endpoint from Terraform output
- Update `DATABASE_NAME` if different from default
- Update credentials in Secret (or use Secrets Manager)

### 3. Deploy

```bash
kubectl apply -f rds-proxy.yaml
```

## Connection String Format

For RDS Proxy, use the proxy endpoint directly:

```
<rds-proxy-endpoint>:5432
```

Example:
```
my-app-db-proxy.proxy-abc123.us-west-2.rds.amazonaws.com:5432
```

## Benefits

✅ **Connection Pooling**: Efficient connection reuse
✅ **No Public IPs**: RDS doesn't need public IP
✅ **Automatic Failover**: Proxy handles failover transparently
✅ **Secrets Manager**: Automatic credential rotation
✅ **IAM Authentication**: Optional IAM-based auth (no passwords)
✅ **High Availability**: Proxy is highly available

## IAM Authentication (Optional)

For IAM authentication, configure:

1. **Enable IAM authentication on RDS:**
   ```bash
   aws rds modify-db-instance \
     --db-instance-identifier my-app-db \
     --enable-iam-database-authentication
   ```

2. **Create IAM policy:**
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [{
       "Effect": "Allow",
       "Action": ["rds-db:connect"],
       "Resource": "arn:aws:rds-db:region:account-id:dbuser:db-instance-id/username"
     }]
   }
   ```

3. **Use IAM role in pod:**
   - Annotate service account with IAM role (IRSA)
   - Use IAM authentication token instead of password

## Direct RDS Connection (Without Proxy)

If not using RDS Proxy, connect directly to RDS:

```yaml
env:
- name: DB_HOST
  value: "<rds-endpoint>"
- name: DB_PORT
  value: "5432"
```

**Note:** Direct connection requires:
- RDS in private subnet
- Security group allows EKS nodes
- No connection pooling benefits

## Troubleshooting

### Connection Refused

**Check:**
- RDS Proxy endpoint is correct
- Security group allows EKS nodes
- RDS instance is running
- RDS Proxy is active

### Authentication Failed

**Check:**
- Database credentials are correct
- Secrets Manager secret exists (if using)
- IAM permissions (if using IAM auth)

### Connection Pool Exhausted

**Solutions:**
- Increase RDS Proxy connection limit
- Use connection pooling in application
- Scale RDS Proxy if needed

## Comparison: RDS Proxy vs Cloud SQL Proxy

| Feature | RDS Proxy | Cloud SQL Proxy |
|---------|-----------|-----------------|
| **Connection Pooling** | ✅ Built-in | ❌ No |
| **Failover** | ✅ Automatic | ❌ Manual |
| **IAM Auth** | ✅ Supported | ✅ Supported |
| **Secrets Rotation** | ✅ Automatic | ❌ Manual |
| **Deployment** | Managed service | Kubernetes pod |
| **Cost** | ~$15/month | Included |

## Additional Resources

- [RDS Proxy Documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-proxy.html)
- [RDS Proxy Best Practices](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-proxy.html#rds-proxy.best-practices)
- [IAM Database Authentication](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.html)


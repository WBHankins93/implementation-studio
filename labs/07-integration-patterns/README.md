# Lab 07: Integration Patterns

## Learning Objectives

By completing this lab, you will:

- Integrate with external authentication systems (OAuth, SAML, LDAP)
- Connect to external databases securely (Cloud SQL/RDS, external databases)
- Configure API gateway patterns (Kong, GCP API Gateway)
- Understand service mesh basics for external traffic (Istio)
- Learn discovery questions for integration requirements
- Experience multi-cloud database integration patterns (GCP and AWS)

## Cloud Provider Selection

This lab supports **two deployment options**:

1. **GCP (GKE)** - Google Kubernetes Engine with Cloud SQL
2. **AWS (EKS)** - Amazon Elastic Kubernetes Service with RDS

Choose your provider by setting `cloud_provider` in `terraform.tfvars`:
- `cloud_provider = "gcp"` - GKE cluster with Cloud SQL
- `cloud_provider = "aws"` - EKS cluster with RDS

## Prerequisites

### Common Prerequisites
- Terraform >= 1.5
- `kubectl` installed
- `helm` 3.x
- Understanding of Kubernetes basics
- Completion of Lab 01 (recommended)

### GCP Prerequisites
- GCP project with billing enabled
- `gcloud` CLI configured

### AWS Prerequisites
- AWS account with appropriate permissions
- `aws` CLI configured

## Architecture

This lab demonstrates integration patterns commonly required in customer environments:

- **Authentication Integration**: OAuth2 Proxy, SAML, LDAP/AD
- **Database Connectivity**: Cloud SQL Proxy (GCP), RDS Proxy (AWS), external databases, connection pooling
- **API Gateway**: Kong, GCP API Gateway
- **Service Mesh**: Istio basics for traffic management

See [Architecture Documentation](./docs/architecture.md) for detailed diagrams.

## Quick Start

### 1. Setup Infrastructure

```bash
cd labs/07-integration-patterns

# Copy and configure terraform.tfvars
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars:
#   - Set cloud_provider = "gcp" or "aws"
#   - Set project_id (GCP) or region (AWS)

# Setup
./scripts/setup.sh

# Deploy infrastructure
terraform plan
terraform apply

# Get cluster credentials
terraform output get_credentials_command
# Run the output command
```

### 2. Deploy Integration Patterns

This lab includes multiple integration patterns. Deploy the ones you want to learn about:

#### Authentication: OAuth2 Proxy

```bash
# Update oauth2-proxy.yaml with your OAuth provider details
kubectl apply -f auth-integration/oauth-proxy/oauth2-proxy.yaml
```

#### Database: Cloud SQL Proxy (GCP)

```bash
# First, create Cloud SQL instance (set create_database = true in terraform.tfvars)
# Update cloud-sql-proxy.yaml with your instance details
kubectl apply -f database-connectivity/cloud-sql-proxy/cloud-sql-proxy.yaml
```

#### Database: RDS Proxy (AWS)

```bash
# First, create RDS instance with proxy (set create_database = true and create_rds_proxy = true)
# Get RDS Proxy endpoint: terraform output aws_rds_proxy_endpoint
# Update rds-proxy.yaml with your proxy endpoint
kubectl apply -f database-connectivity/rds-proxy/rds-proxy.yaml
```

#### API Gateway: Kong

```bash
kubectl apply -f api-gateway/kong-example/kong-deployment.yaml
```

### 3. Validate

```bash
./scripts/validate.sh
```

## What Gets Deployed

### Infrastructure

**GCP:**
- **GKE Cluster**: Standard cluster for integration testing
- **VPC Network**: Public and private subnets
- **Artifact Registry**: Container image storage
- **Cloud SQL** (optional): PostgreSQL instance for database examples

**AWS:**
- **EKS Cluster**: Standard cluster for integration testing
- **VPC Network**: Public and private subnets
- **ECR Repository**: Container image storage
- **RDS** (optional): PostgreSQL instance for database examples
- **RDS Proxy** (optional): Managed database proxy for connection pooling

### Integration Patterns

Each pattern is documented in its respective directory:

- **`auth-integration/`**: OAuth, SAML, LDAP examples (cloud-agnostic)
- **`database-connectivity/`**: Cloud SQL Proxy (GCP), RDS Proxy (AWS), external DB, connection pooling
- **`api-gateway/`**: Kong (cloud-agnostic), GCP API Gateway
- **`service-mesh/`**: Istio basics (cloud-agnostic)

## Key Concepts

### Authentication Integration

**OAuth2 Proxy**: Reverse proxy that adds OAuth authentication to applications without built-in OAuth support.

**SAML**: Enterprise SSO protocol for authentication with identity providers like Okta, Azure AD.

**LDAP/AD**: Directory service authentication, commonly used with Microsoft Active Directory.

### Database Connectivity

**GCP - Cloud SQL Proxy**: Secure proxy for connecting to Cloud SQL without public IPs, using IAM authentication. Deployed as a Kubernetes pod.

**AWS - RDS Proxy**: Fully managed database proxy service providing connection pooling, failover, and automatic credential rotation. No Kubernetes deployment needed.

**External Databases**: Connecting to databases outside the cluster (customer-managed, other clouds).

**Connection Pooling**: Managing database connections efficiently with poolers like PgBouncer or RDS Proxy.

### API Gateway

**Kong**: Open-source API gateway with plugin ecosystem (cloud-agnostic).

**GCP API Gateway**: Fully managed API gateway service.

### Service Mesh

**Istio**: Service mesh providing traffic management, security, and observability (cloud-agnostic).

## Provider Comparison: Database Connectivity

| Feature | GCP Cloud SQL Proxy | AWS RDS Proxy |
|---------|---------------------|---------------|
| **Deployment** | Kubernetes pod | Managed service |
| **Connection Pooling** | ❌ No | ✅ Built-in |
| **Failover** | ❌ Manual | ✅ Automatic |
| **IAM Authentication** | ✅ Supported | ✅ Supported |
| **Secrets Rotation** | ❌ Manual | ✅ Automatic |
| **Cost** | Included | ~$15/month |
| **Setup Complexity** | Medium | Low |

### When to Use Each

**Cloud SQL Proxy (GCP):**
- Need IAM-based authentication
- Want to avoid public IPs
- Prefer Kubernetes-native deployment
- Cost-conscious (no additional service fee)

**RDS Proxy (AWS):**
- Need connection pooling
- Want automatic failover
- Prefer managed service
- Need automatic credential rotation

## Discovery Questions

When working with customers on integrations, ask:

### Authentication

1. What authentication system do you use? (OAuth, SAML, LDAP, etc.)
2. Who is your identity provider? (Okta, Azure AD, Google Workspace, etc.)
3. What user attributes are available? (Email, groups, roles, etc.)
4. Do you require SSO? (Single Sign-On)

### Database

1. Where is your database located? (GCP, AWS, on-premises, etc.)
2. What database type? (PostgreSQL, MySQL, Oracle, etc.)
3. How is it accessed? (Public IP, VPN, private network)
4. What are connection requirements? (SSL, authentication method, etc.)
5. Do you need connection pooling? (Affects proxy choice)

### API Gateway

1. Do you need API gateway functionality? (Routing, rate limiting, auth)
2. What are your requirements? (Managed vs self-hosted, features needed)
3. What is your traffic volume? (Affects cost and architecture)

See [Discovery Questions Guide](./docs/discovery-questions.md) for comprehensive questions.

## Estimated Time

3-4 hours (depending on which patterns you explore)

## Estimated Cost

**GCP Infrastructure**: $10-20 if resources are destroyed within a few hours
- GKE cluster: ~$0.10/hour per node
- Cloud SQL (optional): ~$0.02/hour (db-f1-micro)
- Load balancer: ~$0.025/hour

**AWS Infrastructure**: $12-25 if resources are destroyed within a few hours
- EKS control plane: $0.10/hour
- Node instances: ~$0.05-0.10/hour per node
- RDS (optional): ~$0.02/hour (db.t3.micro)
- RDS Proxy (optional): ~$0.02/hour + connection charges
- Load balancer: ~$0.025/hour

**Note**: Databases add cost. Set `create_database = false` in `terraform.tfvars` to avoid database costs.

## Validation

See [VALIDATION-STATUS.md](./VALIDATION-STATUS.md) for validation details.

## Documentation

- [Architecture](./docs/architecture.md) - Integration architecture patterns
- [Authentication Patterns](./docs/auth-patterns.md) - OAuth, SAML, LDAP details
- [Data Connectivity](./docs/data-connectivity.md) - Database integration patterns
- [Discovery Questions](./docs/discovery-questions.md) - Questions to ask customers
- [Step-by-Step Guide](./docs/step-by-step.md) - Detailed walkthrough
- [Troubleshooting](./docs/troubleshooting.md) - Common issues and solutions

## Integration Pattern Guides

Each pattern has its own README:

### Authentication
- [OAuth2 Proxy](./auth-integration/oauth-proxy/README.md)
- [SAML Integration](./auth-integration/saml-example/README.md)
- [LDAP/AD Integration](./auth-integration/ldap-example/README.md)

### Database
- [Cloud SQL Proxy](./database-connectivity/cloud-sql-proxy/README.md) (GCP)
- [RDS Proxy](./database-connectivity/rds-proxy/README.md) (AWS)
- [External Database](./database-connectivity/external-database/README.md)
- [Connection Pooling](./database-connectivity/connection-pooling/README.md)

### API Gateway
- [Kong](./api-gateway/kong-example/README.md)
- [GCP API Gateway](./api-gateway/gcp-api-gateway/README.md)

### Service Mesh
- [Istio Basics](./service-mesh/istio-basics/README.md)

## Cleanup

To destroy all resources:

```bash
./scripts/cleanup.sh
```

**Warning:** This will delete the cluster, VPC, and all integration deployments!

## Next Steps

After completing this lab:

1. Review integration patterns relevant to your use case
2. Practice discovery questions with customer scenarios
3. Understand security considerations for each pattern
4. Compare Cloud SQL Proxy vs RDS Proxy patterns
5. Proceed to Lab 08: Handoff and Runbooks

## Additional Resources

**Authentication:**
- [OAuth2 Proxy Documentation](https://oauth2-proxy.github.io/oauth2-proxy/)

**Database:**
- [Cloud SQL Proxy Documentation](https://cloud.google.com/sql/docs/postgres/sql-proxy) (GCP)
- [RDS Proxy Documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-proxy.html) (AWS)

**API Gateway:**
- [Kong Documentation](https://docs.konghq.com/)

**Service Mesh:**
- [Istio Documentation](https://istio.io/latest/docs/)

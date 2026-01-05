# Migration Guide: GCP ↔ AWS

This guide provides step-by-step instructions for migrating Kubernetes deployments between GCP (GKE) and AWS (EKS).

## Overview

Migration between GCP and AWS involves:
1. **Infrastructure Migration** - VPC, clusters, networking
2. **Application Migration** - Kubernetes workloads
3. **Configuration Updates** - Authentication, networking, services
4. **Validation** - Testing and verification

## Migration Scenarios

### Scenario 1: GCP → AWS Migration

**Use Cases:**
- Customer requires AWS
- Cost optimization (long-term)
- Compliance requirements
- Existing AWS infrastructure

### Scenario 2: AWS → GCP Migration

**Use Cases:**
- Cost reduction (free control plane)
- Simpler architecture needs
- Google Workspace integration
- Compliance requirements

## Pre-Migration Checklist

### 1. Inventory Current Resources

**GCP Inventory:**
```bash
# List GKE clusters
gcloud container clusters list

# List VPCs
gcloud compute networks list

# List firewall rules
gcloud compute firewall-rules list

# List Cloud SQL instances
gcloud sql instances list
```

**AWS Inventory:**
```bash
# List EKS clusters
aws eks list-clusters --region REGION

# List VPCs
aws ec2 describe-vpcs --region REGION

# List security groups
aws ec2 describe-security-groups --region REGION

# List RDS instances
aws rds describe-db-instances --region REGION
```

### 2. Document Current Configuration

Create a migration document with:
- Cluster configuration (node count, instance types, regions)
- Network topology (VPC CIDR, subnets, routes)
- Security rules (firewall rules / security groups)
- Authentication setup (Workload Identity / IRSA)
- Database connections
- Application dependencies

### 3. Plan Migration Strategy

**Options:**
1. **Big Bang** - Migrate everything at once
2. **Phased** - Migrate component by component
3. **Parallel** - Run both during transition
4. **Blue-Green** - New environment, cutover

## GCP → AWS Migration

### Phase 1: Infrastructure Setup

#### Step 1: Create AWS VPC

```hcl
# Map GCP VPC to AWS VPC
module "vpc" {
  source = "../../modules/aws/vpc"
  
  # Map GCP CIDR to AWS
  vpc_cidr = "10.0.0.0/16"  # Match or adjust GCP CIDR
  
  # Map GCP subnets to AWS subnets
  public_subnet_cidr  = "10.0.1.0/24"  # GCP public subnet
  private_subnet_cidr = "10.0.2.0/24"  # GCP private subnet
  
  availability_zones = ["us-west-2a", "us-west-2b"]
}
```

**Key Differences:**
- GCP subnets are regional → AWS subnets are zonal
- Create one subnet per availability zone in AWS

#### Step 2: Create EKS Cluster

```hcl
# Map GKE cluster to EKS cluster
module "eks_cluster" {
  source = "../../modules/aws/eks-cluster"
  
  cluster_name = var.cluster_name
  region       = "us-west-2"  # Map GCP region to AWS region
  subnet_ids   = module.vpc.private_subnet_ids
  
  # Map GKE node configuration
  node_count     = 2  # Match GKE node count
  instance_type  = "t3.medium"  # Map GCP machine type
  min_node_count = 1
  max_node_count = 5
}
```

**Key Differences:**
- GKE uses `machine_type` → EKS uses `instance_type`
- GKE node pools → EKS node groups
- EKS requires control plane ($0.10/hour)

#### Step 3: Map Security Rules

**GCP Firewall Rules → AWS Security Groups:**

```hcl
# GCP Firewall Rule
resource "google_compute_firewall" "allow_ingress" {
  name    = "allow-ingress"
  network = var.network_name
  
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-ingress"]
}

# AWS Security Group (equivalent)
resource "aws_security_group" "allow_ingress" {
  name = "allow-ingress"
  vpc_id = var.vpc_id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

**Key Differences:**
- GCP: Network-level, tag-based targeting
- AWS: Instance-level, security group attachment

### Phase 2: Authentication Migration

#### GCP Workload Identity → AWS IRSA

**GCP Configuration:**
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-sa
  namespace: default
  annotations:
    iam.gke.io/gcp-service-account: "app-sa@PROJECT.iam.gserviceaccount.com"
```

**AWS Configuration:**
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-sa
  namespace: default
  annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::ACCOUNT:role/app-role"
```

**Migration Steps:**
1. Create IAM role in AWS
2. Update service account annotations
3. Update application code (if using provider SDKs)
4. Test authentication

### Phase 3: Database Migration

#### Cloud SQL → RDS

**GCP Configuration:**
```yaml
# Cloud SQL Proxy Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cloud-sql-proxy
spec:
  template:
    spec:
      containers:
      - name: cloud-sql-proxy
        image: gcr.io/cloud-sql-connectors/cloud-sql-proxy:latest
        args:
        - "PROJECT:REGION:INSTANCE"
```

**AWS Configuration:**
```yaml
# Application connects directly to RDS Proxy
apiVersion: v1
kind: ConfigMap
metadata:
  name: db-config
data:
  DB_HOST: "rds-proxy-endpoint.proxy-abc123.us-west-2.rds.amazonaws.com"
  DB_PORT: "5432"
```

**Migration Steps:**
1. Create RDS instance (or use existing)
2. Create RDS Proxy (optional, for connection pooling)
3. Update connection strings
4. Update authentication (IAM or credentials)
5. Test connectivity

### Phase 4: Application Migration

#### Kubernetes Workloads

Most Kubernetes workloads are cloud-agnostic and can be migrated directly:

```bash
# Export from GCP
kubectl get all --all-namespaces -o yaml > workloads.yaml

# Review and update:
# - Service account annotations (Workload Identity → IRSA)
# - ConfigMaps (database endpoints, etc.)
# - Secrets (if needed)
# - Ingress annotations (GCP-specific → AWS-specific)

# Apply to AWS
kubectl apply -f workloads.yaml
```

**Key Updates Needed:**
1. **Service Account Annotations:**
   ```yaml
   # Remove GCP annotation
   # iam.gke.io/gcp-service-account: "..."
   
   # Add AWS annotation
   eks.amazonaws.com/role-arn: "arn:aws:iam::ACCOUNT:role/ROLE"
   ```

2. **Database Endpoints:**
   ```yaml
   # Update ConfigMaps with new database endpoints
   DB_HOST: "new-rds-endpoint"
   ```

3. **Ingress Annotations:**
   ```yaml
   # GCP
   kubernetes.io/ingress.class: "gce"
   
   # AWS (NGINX Ingress)
   kubernetes.io/ingress.class: "nginx"
   ```

## AWS → GCP Migration

### Phase 1: Infrastructure Setup

#### Step 1: Create GCP VPC

```hcl
# Map AWS VPC to GCP VPC
module "vpc" {
  source = "../../modules/gcp/vpc-standard"
  
  network_name = "${var.cluster_name}-vpc"
  region       = "us-central1"  # Map AWS region to GCP region
  
  # Map AWS subnets (combine zonal subnets into regional)
  public_subnet_cidr  = "10.0.1.0/24"  # Combine AWS public subnets
  private_subnet_cidr = "10.0.2.0/24"  # Combine AWS private subnets
}
```

**Key Differences:**
- AWS subnets are zonal → GCP subnets are regional
- Combine multiple AWS subnets into one GCP subnet

#### Step 2: Create GKE Cluster

```hcl
# Map EKS cluster to GKE cluster
module "gke_cluster" {
  source = "../../modules/gcp/gke-cluster"
  
  project_id   = var.project_id
  cluster_name = var.cluster_name
  region       = "us-central1"
  network      = module.vpc.network_name
  subnetwork   = module.vpc.private_subnet_name
  
  # Map EKS node configuration
  node_count   = 2  # Match EKS node count
  machine_type = "e2-medium"  # Map AWS instance type
  min_node_count = 1
  max_node_count = 5
}
```

**Key Differences:**
- EKS uses `instance_type` → GKE uses `machine_type`
- EKS node groups → GKE node pools
- GKE control plane is free

#### Step 3: Map Security Rules

**AWS Security Groups → GCP Firewall Rules:**

```hcl
# AWS Security Group
resource "aws_security_group" "allow_ingress" {
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# GCP Firewall Rule (equivalent)
resource "google_compute_firewall" "allow_ingress" {
  name    = "allow-ingress"
  network = var.network_name
  
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-ingress"]
}
```

**Key Differences:**
- AWS: Instance-level, security group attachment
- GCP: Network-level, tag-based targeting

### Phase 2: Authentication Migration

#### AWS IRSA → GCP Workload Identity

**AWS Configuration:**
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-sa
  namespace: default
  annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::ACCOUNT:role/app-role"
```

**GCP Configuration:**
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-sa
  namespace: default
  annotations:
    iam.gke.io/gcp-service-account: "app-sa@PROJECT.iam.gserviceaccount.com"
```

**Migration Steps:**
1. Create GCP service account
2. Enable Workload Identity on GKE cluster
3. Bind GKE service account to GCP service account
4. Update service account annotations
5. Update application code (if using provider SDKs)
6. Test authentication

### Phase 3: Database Migration

#### RDS → Cloud SQL

**AWS Configuration:**
```yaml
# Application connects to RDS Proxy
apiVersion: v1
kind: ConfigMap
metadata:
  name: db-config
data:
  DB_HOST: "rds-proxy-endpoint.proxy-abc123.us-west-2.rds.amazonaws.com"
```

**GCP Configuration:**
```yaml
# Cloud SQL Proxy Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cloud-sql-proxy
spec:
  template:
    spec:
      containers:
      - name: cloud-sql-proxy
        image: gcr.io/cloud-sql-connectors/cloud-sql-proxy:latest
        args:
        - "PROJECT:REGION:INSTANCE"
```

**Migration Steps:**
1. Create Cloud SQL instance (or use existing)
2. Deploy Cloud SQL Proxy as Kubernetes pod
3. Update connection strings to use proxy service
4. Update authentication (Workload Identity)
5. Test connectivity

## Common Migration Patterns

### Pattern 1: Network CIDR Mapping

**Challenge:** GCP and AWS may use different CIDR ranges

**Solution:**
```hcl
# Option 1: Use same CIDR (if no conflicts)
vpc_cidr = "10.0.0.0/16"  # Same for both

# Option 2: Use different CIDR and update routes
# GCP: 10.0.0.0/16
# AWS: 10.1.0.0/16
# Update application configs to use new IPs
```

### Pattern 2: Subnet Consolidation

**Challenge:** AWS has zonal subnets, GCP has regional subnets

**Solution:**
```hcl
# AWS: Multiple zonal subnets
# us-west-2a: 10.0.1.0/24
# us-west-2b: 10.0.2.0/24

# GCP: One regional subnet covering both
# us-central1: 10.0.1.0/24 (spans all zones)
```

### Pattern 3: Security Rule Translation

**Challenge:** Different security models (firewall rules vs security groups)

**Solution:**
1. Document all current rules
2. Map to equivalent rules in target provider
3. Test rule application
4. Verify connectivity

### Pattern 4: Authentication Translation

**Challenge:** Different authentication mechanisms

**Solution:**
1. Create equivalent IAM/service account
2. Map permissions
3. Update service account annotations
4. Test authentication
5. Update application code if needed

## Migration Validation

### Post-Migration Checklist

1. **Infrastructure:**
   - [ ] VPC created and configured
   - [ ] Cluster deployed and healthy
   - [ ] Nodes running and ready
   - [ ] Network connectivity verified

2. **Security:**
   - [ ] Firewall rules/security groups applied
   - [ ] Network policies working
   - [ ] Authentication configured
   - [ ] Secrets migrated

3. **Applications:**
   - [ ] All pods running
   - [ ] Services accessible
   - [ ] Ingress working
   - [ ] Database connectivity verified

4. **Functionality:**
   - [ ] End-to-end tests passing
   - [ ] Performance acceptable
   - [ ] Monitoring working
   - [ ] Logging configured

### Testing Strategy

```bash
# 1. Infrastructure Tests
kubectl get nodes
kubectl get pods --all-namespaces

# 2. Connectivity Tests
kubectl run test --image=curlimages/curl --rm -it --restart=Never -- \
  curl -v https://www.google.com

# 3. Database Tests
kubectl run db-test --image=postgres:14-alpine --rm -it --restart=Never -- \
  psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "SELECT version();"

# 4. Application Tests
# Run your application's test suite
# Verify all functionality works
```

## Rollback Plan

### If Migration Fails

1. **Keep Source Environment Running:**
   - Don't destroy source until migration validated
   - Maintain parallel environments during transition

2. **Document Issues:**
   - Record all problems encountered
   - Note configuration differences
   - Update migration plan

3. **Rollback Steps:**
   - Revert to source environment
   - Fix issues in migration plan
   - Retry migration

## Cost Considerations

### Migration Costs

**During Migration:**
- Run both environments in parallel
- Double costs during transition
- Plan for 1-2 weeks overlap

**After Migration:**
- Destroy source environment
- Monitor new environment costs
- Optimize as needed

### Cost Optimization

**GCP:**
- Use preemptible nodes for non-production
- Right-size node pools
- Use committed use discounts

**AWS:**
- Use Spot instances for non-production
- Right-size node groups
- Use Reserved Instances for production

## Additional Resources

- [GCP Migration Guide](https://cloud.google.com/migrate)
- [AWS Migration Guide](https://aws.amazon.com/migration/)
- [Provider Comparison](./provider-comparison.md)
- [Multi-Cloud Considerations](./multi-cloud-considerations.md)


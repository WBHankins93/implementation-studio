# Multi-Region Deployment Patterns

This document covers enterprise-scale multi-region deployment patterns for Kubernetes workloads, including Active-Passive, Active-Active, and Read Replica architectures.

## Overview

Multi-region deployments provide:
- **High Availability** - Survive regional outages
- **Disaster Recovery** - Failover to secondary region
- **Performance** - Serve users from nearest region
- **Compliance** - Data residency requirements

## Pattern 1: Active-Passive (Primary-Secondary)

### Architecture

```
Region A (Primary)                    Region B (Secondary)
┌─────────────────┐                  ┌─────────────────┐
│  GKE/EKS        │                  │  GKE/EKS        │
│  ┌───────────┐  │                  │  ┌───────────┐  │
│  │ App Pods  │  │                  │  │ App Pods  │  │
│  │ (Active)  │  │                  │  │ (Standby) │  │
│  └───────────┘  │                  │  └───────────┘  │
│       │         │                  │       │         │
│       ▼         │                  │       ▼         │
│  ┌───────────┐  │                  │  ┌───────────┐  │
│  │ Database  │◄─┼──────────────────┼─►│ Database  │  │
│  │ (Primary) │  │  Replication     │  │ (Replica) │  │
│  └───────────┘  │                  │  └───────────┘  │
└─────────────────┘                  └─────────────────┘
       │                                      │
       └──────────┬───────────────────────────┘
                  ▼
         Global Load Balancer
                  │
                  ▼
              Users
```

### Characteristics

- **Primary Region:** Handles all traffic, active workloads
- **Secondary Region:** Standby, ready for failover
- **Database:** Primary in Region A, replica in Region B
- **Traffic:** 100% to primary, 0% to secondary
- **Failover:** Manual or automated (DNS/load balancer)

### Use Cases

- **Disaster Recovery** - Failover during regional outage
- **Compliance** - Data residency with backup region
- **Cost Optimization** - Secondary region can use smaller resources
- **Planned Maintenance** - Failover during primary region maintenance

### Terraform Example

```hcl
# Primary Region (us-central1)
module "primary_cluster" {
  source = "../../modules/gcp/gke-cluster"
  
  project_id    = var.project_id
  region        = "us-central1"
  cluster_name  = "primary-cluster"
  
  node_pools = [{
    name         = "primary-pool"
    machine_type = "e2-medium"
    min_count    = 3
    max_count    = 10
  }]
}

# Secondary Region (us-east1)
module "secondary_cluster" {
  source = "../../modules/gcp/gke-cluster"
  
  project_id    = var.project_id
  region        = "us-east1"
  cluster_name  = "secondary-cluster"
  
  node_pools = [{
    name         = "secondary-pool"
    machine_type = "e2-small"  # Smaller for cost savings
    min_count    = 1
    max_count    = 5
  }]
}

# Global Load Balancer
resource "google_compute_backend_service" "global" {
  name                  = "multi-region-backend"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL"
  
  backend {
    group = module.primary_cluster.instance_group
    balancing_mode = "UTILIZATION"
  }
  
  backend {
    group = module.secondary_cluster.instance_group
    balancing_mode = "UTILIZATION"
    failover = true  # Failover to secondary
  }
}
```

### Cost Analysis

**Monthly Cost Estimate (GCP):**
- Primary Region: ~$300-500/month (3 nodes, active)
- Secondary Region: ~$100-200/month (1 node, standby)
- Load Balancer: ~$20/month
- **Total:** ~$420-720/month

**AWS Equivalent:**
- Primary Region: ~$400-600/month (EKS + nodes)
- Secondary Region: ~$150-250/month (EKS + nodes)
- Global Accelerator: ~$20/month
- **Total:** ~$570-870/month

### Failover Process

1. **Detect Failure** - Health checks fail in primary region
2. **Route Traffic** - Load balancer routes to secondary
3. **Activate Secondary** - Scale up secondary region if needed
4. **Update DNS** - Point users to secondary region
5. **Monitor** - Verify secondary region is handling traffic

## Pattern 2: Active-Active

### Architecture

```
Region A (Active)                     Region B (Active)
┌─────────────────┐                  ┌─────────────────┐
│  GKE/EKS        │                  │  GKE/EKS        │
│  ┌───────────┐  │                  │  ┌───────────┐  │
│  │ App Pods  │  │                  │  │ App Pods  │  │
│  │ (Active)  │  │                  │  │ (Active)  │  │
│  └───────────┘  │                  │  └───────────┘  │
│       │         │                  │       │         │
│       ▼         │                  │       ▼         │
│  ┌───────────┐  │                  │  ┌───────────┐  │
│  │ Database  │◄─┼──────────────────┼─►│ Database  │  │
│  │ (Primary) │  │  Replication     │  │ (Replica) │  │
│  └───────────┘  │                  │  └───────────┘  │
└─────────────────┘                  └─────────────────┘
       │                                      │
       └──────────┬───────────────────────────┘
                  ▼
         Global Load Balancer
         (50% / 50% split)
                  │
                  ▼
              Users
```

### Characteristics

- **Both Regions Active:** Handle traffic simultaneously
- **Traffic Split:** 50% to each region (or geo-based routing)
- **Database:** Primary in one region, read replica in other
- **Performance:** Users served from nearest region
- **Resilience:** Automatic failover if one region fails

### Use Cases

- **Global Users** - Serve users from nearest region
- **High Availability** - No single point of failure
- **Performance** - Reduced latency for global users
- **Scale** - Distribute load across regions

### Terraform Example

```hcl
# Region A (us-central1) - 50% traffic
module "region_a_cluster" {
  source = "../../modules/gcp/gke-cluster"
  
  project_id    = var.project_id
  region        = "us-central1"
  cluster_name  = "region-a-cluster"
  
  node_pools = [{
    name         = "region-a-pool"
    machine_type = "e2-medium"
    min_count    = 3
    max_count    = 10
  }]
}

# Region B (us-east1) - 50% traffic
module "region_b_cluster" {
  source = "../../modules/gcp/gke-cluster"
  
  project_id    = var.project_id
  region        = "us-east1"
  cluster_name  = "region-b-cluster"
  
  node_pools = [{
    name         = "region-b-pool"
    machine_type = "e2-medium"
    min_count    = 3
    max_count    = 10
  }]
}

# Global Load Balancer with Geo-based Routing
resource "google_compute_backend_service" "global" {
  name                  = "active-active-backend"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL"
  
  # Region A - US West
  backend {
    group = module.region_a_cluster.instance_group
    balancing_mode = "UTILIZATION"
  }
  
  # Region B - US East
  backend {
    group = module.region_b_cluster.instance_group
    balancing_mode = "UTILIZATION"
  }
}

# Geo-based routing (optional)
resource "google_compute_url_map" "geo_routing" {
  name = "geo-routing"
  
  default_service = google_compute_backend_service.global.id
  
  host_rule {
    hosts        = ["*"]
    path_matcher = "geo-matcher"
  }
  
  path_matcher {
    name            = "geo-matcher"
    default_service = google_compute_backend_service.global.id
    
    # Route US West to Region A
    route_rules {
      priority = 1
      match_rules {
        region_codes = ["US-CA", "US-OR", "US-WA"]
      }
      service = module.region_a_cluster.backend_service
    }
    
    # Route US East to Region B
    route_rules {
      priority = 2
      match_rules {
        region_codes = ["US-NY", "US-VA", "US-FL"]
      }
      service = module.region_b_cluster.backend_service
    }
  }
}
```

### Cost Analysis

**Monthly Cost Estimate (GCP):**
- Region A: ~$300-500/month (3 nodes, active)
- Region B: ~$300-500/month (3 nodes, active)
- Load Balancer: ~$20/month
- **Total:** ~$620-1020/month

**AWS Equivalent:**
- Region A: ~$400-600/month (EKS + nodes)
- Region B: ~$400-600/month (EKS + nodes)
- Global Accelerator: ~$20/month
- **Total:** ~$820-1220/month

## Pattern 3: Read Replicas

### Architecture

```
Region A (Primary)                    Region B (Read Replica)
┌─────────────────┐                  ┌─────────────────┐
│  GKE/EKS        │                  │  GKE/EKS        │
│  ┌───────────┐  │                  │  ┌───────────┐  │
│  │ App Pods  │  │                  │  │ App Pods  │  │
│  │ (Read/Write)│                  │  │ (Read Only)│  │
│  └───────────┘  │                  │  └───────────┘  │
│       │         │                  │       │         │
│       ▼         │                  │       ▼         │
│  ┌───────────┐  │                  │  ┌───────────┐  │
│  │ Database  │──┼──────────────────┼─►│ Database  │  │
│  │ (Primary) │  │  Replication     │  │ (Replica) │  │
│  └───────────┘  │                  │  └───────────┘  │
└─────────────────┘                  └─────────────────┘
       │                                      │
       │                                      │
   Write Traffic                          Read Traffic
```

### Characteristics

- **Primary Region:** Handles all writes and some reads
- **Replica Region:** Handles read-only traffic
- **Database:** Primary in Region A, read replica in Region B
- **Traffic:** Writes to primary, reads distributed
- **Performance:** Reduced latency for read operations

### Use Cases

- **Read-Heavy Workloads** - Distribute read load
- **Performance** - Serve reads from nearest region
- **Cost Optimization** - Replica can be smaller
- **Analytics** - Run analytics queries on replica

### Terraform Example

```hcl
# Primary Region (us-central1)
module "primary_cluster" {
  source = "../../modules/gcp/gke-cluster"
  
  project_id    = var.project_id
  region        = "us-central1"
  cluster_name  = "primary-cluster"
  
  node_pools = [{
    name         = "primary-pool"
    machine_type = "e2-medium"
    min_count    = 3
    max_count    = 10
  }]
}

# Read Replica Region (us-east1)
module "replica_cluster" {
  source = "../../modules/gcp/gke-cluster"
  
  project_id    = var.project_id
  region        = "us-east1"
  cluster_name  = "replica-cluster"
  
  node_pools = [{
    name         = "replica-pool"
    machine_type = "e2-small"  # Smaller for read-only
    min_count    = 2
    max_count    = 5
  }]
}

# Cloud SQL Primary (GCP)
resource "google_sql_database_instance" "primary" {
  name             = "primary-db"
  database_version = "POSTGRES_14"
  region           = "us-central1"
  
  settings {
    tier = "db-f1-micro"
    
    backup_configuration {
      enabled = true
    }
  }
}

# Cloud SQL Read Replica (GCP)
resource "google_sql_database_instance" "replica" {
  name                 = "replica-db"
  database_version     = "POSTGRES_14"
  region               = "us-east1"
  master_instance_name = google_sql_database_instance.primary.name
  replica_configuration {
    failover_target = false
  }
  
  settings {
    tier = "db-f1-micro"
  }
}
```

### Application Configuration

**Read/Write Splitting:**

```yaml
# Primary region - Read/Write
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config-primary
data:
  DATABASE_HOST: "primary-db:5432"
  DATABASE_MODE: "read-write"
---
# Replica region - Read Only
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config-replica
data:
  DATABASE_HOST: "replica-db:5432"
  DATABASE_MODE: "read-only"
```

### Cost Analysis

**Monthly Cost Estimate (GCP):**
- Primary Region: ~$300-500/month (3 nodes + primary DB)
- Replica Region: ~$150-250/month (2 nodes + replica DB)
- **Total:** ~$450-750/month

**AWS Equivalent:**
- Primary Region: ~$400-600/month (EKS + RDS primary)
- Replica Region: ~$200-300/month (EKS + RDS replica)
- **Total:** ~$600-900/month

## Pattern Comparison

| Pattern | Traffic Split | Cost | Complexity | Use Case |
|---------|--------------|------|------------|----------|
| **Active-Passive** | 100% / 0% | Low | Low | Disaster Recovery |
| **Active-Active** | 50% / 50% | High | High | Global Performance |
| **Read Replicas** | Writes: 100% / Reads: Split | Medium | Medium | Read-Heavy Workloads |

## Implementation Considerations

### Database Replication

**GCP Cloud SQL:**
- Built-in read replicas
- Automatic replication
- Failover support
- Cross-region replication

**AWS RDS:**
- Read replicas supported
- Cross-region replication
- Automatic failover (Multi-AZ)
- Performance Insights

### Network Connectivity

**Inter-Region Communication:**
- VPC peering (GCP)
- VPC peering or Transit Gateway (AWS)
- VPN tunnels for private connectivity
- Consider latency and bandwidth costs

### Data Consistency

**Replication Lag:**
- Asynchronous replication (eventual consistency)
- Synchronous replication (strong consistency, higher latency)
- Application-level conflict resolution

### Monitoring

**Key Metrics:**
- Replication lag
- Regional health
- Traffic distribution
- Failover readiness

## Best Practices

1. **Start Simple** - Begin with Active-Passive, evolve to Active-Active
2. **Monitor Replication** - Track replication lag and health
3. **Test Failover** - Regular failover drills
4. **Document Procedures** - Clear runbooks for failover
5. **Cost Optimization** - Right-size secondary regions
6. **Security** - Encrypt inter-region traffic
7. **Compliance** - Consider data residency requirements

## References

- [GCP Multi-Region Deployment](https://cloud.google.com/architecture/multi-region-deployment)
- [AWS Multi-Region Architecture](https://aws.amazon.com/architecture/multi-region/)
- [Database Replication Patterns](https://www.postgresql.org/docs/current/high-availability.html)

---

**Last Updated:** January 2026


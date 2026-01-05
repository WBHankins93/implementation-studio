# Disaster Recovery Strategies

This document covers disaster recovery (DR) strategies for Kubernetes deployments, including backup/restore, pilot light, warm standby, and hot standby patterns.

## Overview

Disaster Recovery ensures business continuity when primary infrastructure fails. Key metrics:

- **RTO (Recovery Time Objective)** - Maximum acceptable downtime
- **RPO (Recovery Point Objective)** - Maximum acceptable data loss
- **Cost** - Ongoing DR infrastructure costs

## Strategy Comparison

| Strategy | RTO | RPO | Cost | Complexity |
|---------|-----|-----|------|------------|
| **Backup/Restore** | Hours-Days | Hours-Days | Low | Low |
| **Pilot Light** | Minutes-Hours | Minutes-Hours | Low-Medium | Medium |
| **Warm Standby** | Minutes | Minutes | Medium-High | High |
| **Hot Standby** | Seconds | Seconds | High | Very High |

## Strategy 1: Backup/Restore

### Architecture

```
Primary Region                    Backup Storage
┌─────────────────┐              ┌─────────────────┐
│  GKE/EKS        │              │  Cloud Storage  │
│  ┌───────────┐  │              │  ┌───────────┐  │
│  │ App Pods  │  │              │  │ Backups   │  │
│  └───────────┘  │              │  │ (Daily)   │  │
│       │         │              │  └───────────┘  │
│       ▼         │              │                 │
│  ┌───────────┐  │              │  ┌───────────┐  │
│  │ Database  │──┼──────────────┼─►│ DB Backup │  │
│  └───────────┘  │   Backup     │  │ (Daily)   │  │
└─────────────────┘              └─────────────────┘
```

### Characteristics

- **RTO:** Hours to days (restore time)
- **RPO:** Hours to days (backup frequency)
- **Cost:** Low (storage only)
- **Complexity:** Low
- **Infrastructure:** No secondary region needed

### Use Cases

- **Non-Critical Workloads** - Can tolerate hours of downtime
- **Cost-Conscious** - Minimal DR investment
- **Development/Testing** - Lower availability requirements
- **Compliance** - Backup requirements without active DR

### Implementation

**Backup Strategy:**

```hcl
# GCP Cloud Storage for Backups
resource "google_storage_bucket" "backups" {
  name          = "app-backups-${var.project_id}"
  location      = "US"
  force_destroy = false
  
  versioning {
    enabled = true
  }
  
  lifecycle_rule {
    condition {
      age = 90  # Keep backups for 90 days
    }
    action {
      type = "Delete"
    }
  }
}

# Automated Database Backup (GCP Cloud SQL)
resource "google_sql_database_instance" "primary" {
  name             = "primary-db"
  database_version = "POSTGRES_14"
  region           = "us-central1"
  
  settings {
    tier = "db-f1-micro"
    
    backup_configuration {
      enabled                        = true
      start_time                    = "03:00"
      point_in_time_recovery_enabled = true
      backup_retention_settings {
        retained_backups = 7
        retention_unit   = "COUNT"
      }
    }
  }
}

# Kubernetes Backup (Velero)
resource "kubernetes_namespace" "velero" {
  metadata {
    name = "velero"
  }
}

# Velero backup schedule
resource "kubernetes_cron_job" "daily_backup" {
  metadata {
    name      = "daily-backup"
    namespace = kubernetes_namespace.velero.metadata[0].name
  }
  
  spec {
    schedule = "0 2 * * *"  # Daily at 2 AM
    
    job_template {
      spec {
        template {
          spec {
            container {
              name  = "velero"
              image = "velero/velero:latest"
              
              command = [
                "velero",
                "backup",
                "create",
                "backup-$(date +%Y%m%d)",
                "--include-namespaces=default"
              ]
            }
          }
        }
      }
    }
  }
}
```

**Restore Process:**

1. **Create New Infrastructure** - Provision new cluster in recovery region
2. **Restore Database** - Restore from backup
3. **Restore Kubernetes** - Restore from Velero backup
4. **Update DNS** - Point traffic to new region
5. **Verify** - Test application functionality

**Restore Time:** 2-4 hours (depending on data size)

### Cost Analysis

**Monthly Cost (GCP):**
- Backup Storage: ~$10-50/month (depends on data size)
- Backup Operations: ~$5-20/month
- **Total:** ~$15-70/month

**AWS Equivalent:**
- S3 Backup Storage: ~$10-50/month
- Backup Operations: ~$5-20/month
- **Total:** ~$15-70/month

## Strategy 2: Pilot Light

### Architecture

```
Primary Region                    Secondary Region (Pilot Light)
┌─────────────────┐              ┌─────────────────┐
│  GKE/EKS        │              │  GKE/EKS        │
│  ┌───────────┐  │              │  ┌───────────┐  │
│  │ App Pods  │  │              │  │ (Stopped) │  │
│  │ (Active)  │  │              │  │           │  │
│  └───────────┘  │              │  └───────────┘  │
│       │         │              │       │         │
│       ▼         │              │       ▼         │
│  ┌───────────┐  │              │  ┌───────────┐  │
│  │ Database  │──┼──────────────┼─►│ Database  │  │
│  │ (Primary) │  │  Replication │  │ (Replica) │  │
│  └───────────┘  │              │  └───────────┘  │
└─────────────────┘              └─────────────────┘
```

### Characteristics

- **RTO:** Minutes to hours (scale-up time)
- **RPO:** Minutes (replication lag)
- **Cost:** Low-Medium (minimal secondary resources)
- **Complexity:** Medium
- **Infrastructure:** Minimal secondary region (database replica only)

### Use Cases

- **Cost-Conscious DR** - Balance cost and recovery time
- **Moderate Availability** - Can tolerate minutes of downtime
- **Database-Heavy** - Database is critical, apps can scale quickly
- **Compliance** - DR requirements with cost constraints

### Implementation

**Pilot Light Setup:**

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

# Secondary Region (us-east1) - Minimal Resources
module "secondary_cluster" {
  source = "../../modules/gcp/gke-cluster"
  
  project_id    = var.project_id
  region        = "us-east1"
  cluster_name  = "secondary-cluster"
  
  # Minimal node pool (can scale to zero)
  node_pools = [{
    name         = "secondary-pool"
    machine_type = "e2-small"
    min_count    = 0  # Scale to zero
    max_count    = 10
  }]
}

# Database Replica (Always Running)
resource "google_sql_database_instance" "replica" {
  name                 = "replica-db"
  database_version     = "POSTGRES_14"
  region               = "us-east1"
  master_instance_name = google_sql_database_instance.primary.name
  
  replica_configuration {
    failover_target = true
  }
  
  settings {
    tier = "db-f1-micro"  # Minimal size
  }
}
```

**Failover Process:**

1. **Detect Failure** - Health checks fail in primary
2. **Scale Up Secondary** - Scale node pool from 0 to required size
3. **Promote Replica** - Promote database replica to primary
4. **Deploy Applications** - Deploy app pods to secondary cluster
5. **Update DNS** - Route traffic to secondary region
6. **Verify** - Test application functionality

**Failover Time:** 5-15 minutes

### Cost Analysis

**Monthly Cost (GCP):**
- Primary Region: ~$300-500/month
- Secondary Cluster: ~$0-50/month (scaled to zero)
- Database Replica: ~$30-50/month
- **Total:** ~$330-600/month

**AWS Equivalent:**
- Primary Region: ~$400-600/month
- Secondary Cluster: ~$0-75/month (scaled to zero)
- RDS Replica: ~$40-60/month
- **Total:** ~$440-735/month

## Strategy 3: Warm Standby

### Architecture

```
Primary Region                    Secondary Region (Warm Standby)
┌─────────────────┐              ┌─────────────────┐
│  GKE/EKS        │              │  GKE/EKS        │
│  ┌───────────┐  │              │  ┌───────────┐  │
│  │ App Pods  │  │              │  │ App Pods  │  │
│  │ (Active)  │  │              │  │ (Standby) │  │
│  └───────────┘  │              │  └───────────┘  │
│       │         │              │       │         │
│       ▼         │              │       ▼         │
│  ┌───────────┐  │              │  ┌───────────┐  │
│  │ Database  │──┼──────────────┼─►│ Database  │  │
│  │ (Primary) │  │  Replication │  │ (Replica) │  │
│  └───────────┘  │              │  └───────────┘  │
└─────────────────┘              └─────────────────┘
```

### Characteristics

- **RTO:** Minutes (quick failover)
- **RPO:** Minutes (replication lag)
- **Cost:** Medium-High (secondary region always running)
- **Complexity:** High
- **Infrastructure:** Full secondary region (smaller scale)

### Use Cases

- **High Availability** - Minimal downtime acceptable
- **Business Critical** - Revenue-impacting applications
- **Compliance** - Regulatory DR requirements
- **Customer-Facing** - Public-facing applications

### Implementation

**Warm Standby Setup:**

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

# Secondary Region (us-east1) - Always Running
module "secondary_cluster" {
  source = "../../modules/gcp/gke-cluster"
  
  project_id    = var.project_id
  region        = "us-east1"
  cluster_name  = "secondary-cluster"
  
  # Smaller but always running
  node_pools = [{
    name         = "secondary-pool"
    machine_type = "e2-small"
    min_count    = 2  # Always running
    max_count    = 10
  }]
}

# Applications deployed but scaled down
resource "kubernetes_deployment" "app_standby" {
  metadata {
    name      = "app-standby"
    namespace = "default"
  }
  
  spec {
    replicas = 1  # Minimal replicas
    
    template {
      spec {
        container {
          name  = "app"
          image = "myapp:latest"
          
          # Read-only mode
          env {
            name  = "DATABASE_MODE"
            value = "read-only"
          }
        }
      }
    }
  }
}
```

**Failover Process:**

1. **Detect Failure** - Automated health check failure
2. **Promote Replica** - Promote database replica to primary
3. **Scale Up Applications** - Scale app replicas to full capacity
4. **Switch Traffic** - Update load balancer to route to secondary
5. **Verify** - Automated health checks confirm functionality

**Failover Time:** 2-5 minutes

### Cost Analysis

**Monthly Cost (GCP):**
- Primary Region: ~$300-500/month
- Secondary Region: ~$150-250/month (smaller scale)
- Database Replica: ~$30-50/month
- **Total:** ~$480-800/month

**AWS Equivalent:**
- Primary Region: ~$400-600/month
- Secondary Region: ~$200-300/month
- RDS Replica: ~$40-60/month
- **Total:** ~$640-960/month

## Strategy 4: Hot Standby (Active-Active)

### Architecture

```
Primary Region                    Secondary Region (Hot Standby)
┌─────────────────┐              ┌─────────────────┐
│  GKE/EKS        │              │  GKE/EKS        │
│  ┌───────────┐  │              │  ┌───────────┐  │
│  │ App Pods  │  │              │  │ App Pods  │  │
│  │ (Active)  │  │              │  │ (Active)  │  │
│  └───────────┘  │              │  └───────────┘  │
│       │         │              │       │         │
│       ▼         │              │       ▼         │
│  ┌───────────┐  │              │  ┌───────────┐  │
│  │ Database  │──┼──────────────┼─►│ Database  │  │
│  │ (Primary) │  │  Replication │  │ (Replica) │  │
│  └───────────┘  │              │  └───────────┘  │
└─────────────────┘              └─────────────────┘
       │                                      │
       └──────────┬───────────────────────────┘
                  ▼
         Global Load Balancer
```

### Characteristics

- **RTO:** Seconds (instant failover)
- **RPO:** Seconds (near-zero data loss)
- **Cost:** High (full secondary region)
- **Complexity:** Very High
- **Infrastructure:** Full secondary region (same scale)

### Use Cases

- **Mission Critical** - Zero downtime required
- **Financial Systems** - Transaction processing
- **Real-Time Systems** - Gaming, trading platforms
- **Enterprise SLA** - 99.99%+ availability requirements

### Implementation

**Hot Standby Setup:**

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

# Secondary Region (us-east1) - Full Scale
module "secondary_cluster" {
  source = "../../modules/gcp/gke-cluster"
  
  project_id    = var.project_id
  region        = "us-east1"
  cluster_name  = "secondary-cluster"
  
  # Same scale as primary
  node_pools = [{
    name         = "secondary-pool"
    machine_type = "e2-medium"
    min_count    = 3
    max_count    = 10
  }]
}

# Global Load Balancer with Health Checks
resource "google_compute_backend_service" "global" {
  name                  = "hot-standby-backend"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL"
  
  health_checks = [google_compute_health_check.app.id]
  
  backend {
    group = module.primary_cluster.instance_group
    balancing_mode = "UTILIZATION"
  }
  
  backend {
    group = module.secondary_cluster.instance_group
    balancing_mode = "UTILIZATION"
    failover = true
  }
}

# Health Check
resource "google_compute_health_check" "app" {
  name = "app-health-check"
  
  http_health_check {
    port         = 80
    request_path = "/health"
  }
  
  check_interval_sec  = 5
  timeout_sec         = 3
  healthy_threshold   = 2
  unhealthy_threshold = 3
}
```

**Failover Process:**

1. **Automatic Detection** - Health checks fail in primary
2. **Instant Failover** - Load balancer routes to secondary
3. **Promote Replica** - Database replica promoted (if needed)
4. **No Downtime** - Traffic continues to secondary
5. **Monitor** - Verify secondary handling all traffic

**Failover Time:** < 30 seconds

### Cost Analysis

**Monthly Cost (GCP):**
- Primary Region: ~$300-500/month
- Secondary Region: ~$300-500/month (same scale)
- Database Replica: ~$30-50/month
- Load Balancer: ~$20/month
- **Total:** ~$650-1070/month

**AWS Equivalent:**
- Primary Region: ~$400-600/month
- Secondary Region: ~$400-600/month
- RDS Replica: ~$40-60/month
- Global Accelerator: ~$20/month
- **Total:** ~$860-1280/month

## Strategy Selection Guide

### Choose Backup/Restore If:
- ✅ Downtime of hours is acceptable
- ✅ Cost is primary concern
- ✅ Non-critical workloads
- ✅ Development/testing environments

### Choose Pilot Light If:
- ✅ Downtime of minutes is acceptable
- ✅ Cost-conscious but need faster recovery
- ✅ Database is critical, apps can scale quickly
- ✅ Moderate availability requirements

### Choose Warm Standby If:
- ✅ Downtime of minutes is unacceptable
- ✅ Business-critical applications
- ✅ Compliance requirements
- ✅ Customer-facing applications

### Choose Hot Standby If:
- ✅ Zero downtime required
- ✅ Mission-critical systems
- ✅ Financial/transaction processing
- ✅ 99.99%+ availability SLA

## Best Practices

1. **Test Regularly** - Failover drills monthly/quarterly
2. **Monitor Replication** - Track replication lag and health
3. **Document Procedures** - Clear runbooks for failover
4. **Automate Where Possible** - Reduce manual intervention
5. **Cost Optimization** - Right-size secondary regions
6. **Security** - Encrypt backups and replication
7. **Compliance** - Meet regulatory requirements

## References

- [GCP Disaster Recovery](https://cloud.google.com/architecture/disaster-recovery)
- [AWS Disaster Recovery](https://aws.amazon.com/disaster-recovery/)
- [Velero Backup Tool](https://velero.io/)

---

**Last Updated:** January 2026


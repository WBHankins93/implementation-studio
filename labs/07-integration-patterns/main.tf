terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure providers conditionally
provider "google" {
  count   = var.cloud_provider == "gcp" ? 1 : 0
  project = var.project_id
  region  = var.region
}

provider "aws" {
  count  = var.cloud_provider == "aws" ? 1 : 0
  region = var.region
}

# ============================================================================
# GCP Resources (when cloud_provider = "gcp")
# ============================================================================

# VPC Network (GCP)
module "vpc_gcp" {
  count  = var.cloud_provider == "gcp" ? 1 : 0
  source = "../../modules/gcp/vpc-standard"

  network_name        = "${var.cluster_name}-vpc"
  region              = var.region
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

# GKE Cluster (GCP)
module "gke_cluster" {
  count  = var.cloud_provider == "gcp" ? 1 : 0
  source = "../../modules/gcp/gke-cluster"

  project_id   = var.project_id
  cluster_name = var.cluster_name
  region       = var.region
  network      = module.vpc_gcp[0].network_name
  subnetwork   = module.vpc_gcp[0].private_subnet_name

  private_endpoint       = false
  network_policy_enabled = true
  enable_vpa             = var.enable_vpa

  node_count     = var.node_count
  machine_type   = var.machine_type
  min_node_count = var.min_node_count
  max_node_count = var.max_node_count

  resource_labels = merge(var.resource_labels, {
    purpose = "integration-patterns"
  })
}

# Cloud SQL Instance (GCP, optional)
resource "google_sql_database_instance" "main" {
  count = var.cloud_provider == "gcp" && var.create_database ? 1 : 0

  name             = "${var.cluster_name}-db"
  database_version = "POSTGRES_14"
  region           = var.region

  settings {
    tier = "db-f1-micro" # Smallest tier for cost

    ip_configuration {
      ipv4_enabled    = false
      private_network = module.vpc_gcp[0].network_id
    }
  }

  deletion_protection = false
}

# Cloud SQL Database (GCP)
resource "google_sql_database" "main" {
  count = var.cloud_provider == "gcp" && var.create_database ? 1 : 0

  name     = var.db_name
  instance = google_sql_database_instance.main[0].name
}

# Cloud SQL User (GCP)
resource "google_sql_user" "main" {
  count = var.cloud_provider == "gcp" && var.create_database ? 1 : 0

  name     = var.db_username
  instance = google_sql_database_instance.main[0].name
  password = var.db_password
}

# Artifact Registry (GCP)
module "artifact_registry" {
  count  = var.cloud_provider == "gcp" ? 1 : 0
  source = "../../modules/gcp/artifact-registry"

  project_id    = var.project_id
  region        = var.region
  repository_id = "${var.cluster_name}-repo"
  description   = "Container registry for ${var.cluster_name}"

  gke_service_account = null
}

# ============================================================================
# AWS Resources (when cloud_provider = "aws")
# ============================================================================

# VPC Network (AWS)
module "vpc_aws" {
  count  = var.cloud_provider == "aws" ? 1 : 0
  source = "../../modules/aws/vpc"

  network_name        = "${var.cluster_name}-vpc"
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zones  = var.availability_zones

  resource_tags = merge(var.resource_labels, {
    purpose = "integration-patterns"
  })
}

# EKS Cluster (AWS)
module "eks_cluster" {
  count  = var.cloud_provider == "aws" ? 1 : 0
  source = "../../modules/aws/eks-cluster"

  cluster_name = var.cluster_name
  region       = var.region
  subnet_ids   = module.vpc_aws[0].private_subnet_ids

  private_endpoint = false

  node_count     = var.node_count
  instance_type  = var.instance_type
  min_node_count = var.min_node_count
  max_node_count = var.max_node_count

  node_labels = var.node_labels
  resource_tags = merge(var.resource_labels, {
    purpose = "integration-patterns"
  })
}

# RDS Instance (AWS, optional)
module "rds" {
  count  = var.cloud_provider == "aws" && var.create_database ? 1 : 0
  source = "../../modules/aws/rds"

  db_instance_identifier = "${var.cluster_name}-db"
  vpc_id                 = module.vpc_aws[0].vpc_id
  vpc_cidr               = var.vpc_cidr
  subnet_ids             = module.vpc_aws[0].private_subnet_ids

  # Allow EKS nodes to access RDS
  allowed_security_group_ids = var.create_database ? [module.eks_cluster[0].cluster_security_group_id] : []

  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password

  # Optional: Create RDS Proxy for connection pooling
  create_rds_proxy = var.create_rds_proxy

  resource_tags = merge(var.resource_labels, {
    purpose = "integration-patterns"
  })
}

# ECR Repository (AWS)
module "ecr" {
  count  = var.cloud_provider == "aws" ? 1 : 0
  source = "../../modules/aws/ecr"

  repository_name = "${var.cluster_name}-repo"
  description     = "Container registry for ${var.cluster_name}"

  resource_tags = merge(var.resource_labels, {
    purpose = "integration-patterns"
  })
}

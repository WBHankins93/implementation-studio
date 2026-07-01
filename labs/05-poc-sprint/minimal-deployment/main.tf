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
  project = var.project_id
  region  = var.region
}

provider "aws" {
  region = var.region
}

# ============================================================================
# GCP Resources (when cloud_provider = "gcp")
# ============================================================================

# Minimal VPC (GCP)
module "vpc_gcp" {
  count  = var.cloud_provider == "gcp" ? 1 : 0
  source = "../../../modules/gcp/vpc-standard"

  network_name        = "${var.cluster_name}-vpc"
  region              = var.region
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

# Minimal GKE Cluster (smallest viable for POC)
module "gke_cluster" {
  count  = var.cloud_provider == "gcp" ? 1 : 0
  source = "../../../modules/gcp/gke-cluster"

  project_id   = var.project_id
  cluster_name = var.cluster_name
  region       = var.region
  network      = module.vpc_gcp[0].network_name
  subnetwork   = module.vpc_gcp[0].private_subnet_name

  private_endpoint       = false
  network_policy_enabled = false # Disabled for speed
  enable_vpa             = false # Disabled for speed

  node_count     = var.node_count
  machine_type   = var.machine_type
  min_node_count = 1
  max_node_count = 3 # Small for POC

  resource_labels = merge(var.resource_labels, {
    purpose   = "poc"
    temporary = "true"
  })
}

# Artifact Registry (optional, can use public images for POC)
module "artifact_registry" {
  count  = var.cloud_provider == "gcp" && var.create_registry ? 1 : 0
  source = "../../../modules/gcp/artifact-registry"

  project_id    = var.project_id
  region        = var.region
  repository_id = "${var.cluster_name}-repo"
  description   = "Container registry for POC"

  gke_service_account = null
}

# ============================================================================
# AWS Resources (when cloud_provider = "aws")
# ============================================================================

# Minimal VPC (AWS)
module "vpc_aws" {
  count  = var.cloud_provider == "aws" ? 1 : 0
  source = "../../../modules/aws/vpc"

  network_name        = "${var.cluster_name}-vpc"
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zones  = var.availability_zones

  resource_tags = merge(var.resource_labels, {
    purpose   = "poc"
    temporary = "true"
  })
}

# Minimal EKS Cluster (smallest viable for POC)
module "eks_cluster" {
  count  = var.cloud_provider == "aws" ? 1 : 0
  source = "../../../modules/aws/eks-cluster"

  cluster_name = var.cluster_name
  region       = var.region
  subnet_ids   = module.vpc_aws[0].private_subnet_ids

  private_endpoint = false

  node_count     = var.node_count
  instance_type  = var.instance_type
  min_node_count = 1
  max_node_count = 3 # Small for POC

  node_labels = var.node_labels
  resource_tags = merge(var.resource_labels, {
    purpose   = "poc"
    temporary = "true"
  })
}

# ECR Repository (optional, can use public images for POC)
module "ecr" {
  count  = var.cloud_provider == "aws" && var.create_registry ? 1 : 0
  source = "../../../modules/aws/ecr"

  repository_name = "${var.cluster_name}-repo"

  resource_tags = merge(var.resource_labels, {
    purpose   = "poc"
    temporary = "true"
  })
}

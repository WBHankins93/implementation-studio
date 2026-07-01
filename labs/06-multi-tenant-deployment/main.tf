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

# GCP VPC Network
module "vpc_gcp" {
  count  = var.cloud_provider == "gcp" ? 1 : 0
  source = "../../modules/gcp/vpc-standard"

  network_name        = "${var.cluster_name}-vpc"
  region              = var.region
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

# GCP GKE Cluster
module "gke_cluster" {
  count  = var.cloud_provider == "gcp" ? 1 : 0
  source = "../../modules/gcp/gke-cluster"

  project_id   = var.project_id
  cluster_name = var.cluster_name
  region       = var.region
  network      = module.vpc_gcp[0].network_name
  subnetwork   = module.vpc_gcp[0].private_subnet_name

  private_endpoint       = false
  network_policy_enabled = true # Required for network policies
  enable_vpa             = false

  node_count     = var.node_count
  machine_type   = var.machine_type
  min_node_count = var.min_node_count
  max_node_count = var.max_node_count

  resource_labels = merge(var.resource_labels, {
    purpose = "multi-tenant"
  })
}

# ============================================================================
# AWS Resources (when cloud_provider = "aws")
# ============================================================================

# AWS VPC Network
module "vpc_aws" {
  count  = var.cloud_provider == "aws" ? 1 : 0
  source = "../../modules/aws/vpc"

  network_name        = "${var.cluster_name}-vpc"
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zones  = var.availability_zones

  resource_tags = merge(var.resource_labels, {
    purpose = "multi-tenant"
  })
}

# AWS EKS Cluster
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
    purpose = "multi-tenant"
  })
}

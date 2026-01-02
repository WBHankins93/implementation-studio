terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Configure the Google Cloud Provider (optional - can use Kind instead)
provider "google" {
  project = var.use_gcp ? var.project_id : null
  region  = var.region
}

# VPC Network (only if using GCP)
module "vpc" {
  count = var.use_gcp ? 1 : 0
  
  source = "../../modules/gcp/vpc-standard"
  
  network_name       = "${var.cluster_name}-vpc"
  region             = var.region
  public_subnet_cidr = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

# GKE Cluster (only if using GCP)
module "gke_cluster" {
  count = var.use_gcp ? 1 : 0
  
  source = "../../modules/gcp/gke-cluster"
  
  project_id     = var.project_id
  cluster_name   = var.cluster_name
  region         = var.region
  network        = module.vpc[0].network_name
  subnetwork     = module.vpc[0].private_subnet_name
  
  private_endpoint        = false
  network_policy_enabled  = true  # Required for network policies
  enable_vpa             = false
  
  node_count     = var.node_count
  machine_type   = var.machine_type
  min_node_count = var.min_node_count
  max_node_count = var.max_node_count
  
  resource_labels = merge(var.resource_labels, {
    purpose = "multi-tenant"
  })
}


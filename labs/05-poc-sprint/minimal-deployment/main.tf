terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Configure the Google Cloud Provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# Minimal VPC (reuse existing or create simple one)
module "vpc" {
  source = "../../modules/gcp/vpc-standard"
  
  network_name       = "${var.cluster_name}-vpc"
  region             = var.region
  public_subnet_cidr = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

# Minimal GKE Cluster (smallest viable for POC)
module "gke_cluster" {
  source = "../../modules/gcp/gke-cluster"
  
  project_id     = var.project_id
  cluster_name   = var.cluster_name
  region         = var.region
  network        = module.vpc.network_name
  subnetwork     = module.vpc.private_subnet_name
  
  private_endpoint        = false
  network_policy_enabled  = false  # Disabled for speed
  enable_vpa              = false  # Disabled for speed
  
  node_count     = var.node_count
  machine_type   = var.machine_type
  min_node_count = 1
  max_node_count = 3  # Small for POC
  
  resource_labels = merge(var.resource_labels, {
    purpose = "poc"
    temporary = "true"
  })
}

# Artifact Registry (optional, can use public images for POC)
module "artifact_registry" {
  count = var.create_registry ? 1 : 0
  
  source = "../../modules/gcp/artifact-registry"
  
  project_id    = var.project_id
  region        = var.region
  repository_id = "${var.cluster_name}-repo"
  description   = "Container registry for POC"
  
  gke_service_account = null
}


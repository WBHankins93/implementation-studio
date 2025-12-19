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

# VPC Network
module "vpc" {
  source = "../../modules/gcp/vpc-standard"
  
  network_name       = "${var.cluster_name}-vpc"
  region             = var.region
  public_subnet_cidr = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

# GKE Cluster
module "gke_cluster" {
  source = "../../modules/gcp/gke-cluster"
  
  project_id     = var.project_id
  cluster_name   = var.cluster_name
  region         = var.region
  network        = module.vpc.network_name
  subnetwork     = module.vpc.private_subnet_name
  
  private_endpoint        = false  # Public endpoint for standard deployment
  network_policy_enabled = true
  enable_vpa             = var.enable_vpa
  
  node_count     = var.node_count
  machine_type   = var.machine_type
  min_node_count = var.min_node_count
  max_node_count = var.max_node_count
  
  resource_labels = var.resource_labels
}

# Artifact Registry
module "artifact_registry" {
  source = "../../modules/gcp/artifact-registry"
  
  project_id    = var.project_id
  region        = var.region
  repository_id = "${var.cluster_name}-repo"
  description   = "Container registry for ${var.cluster_name}"
  
  gke_service_account = null  # Will be set after cluster creation
}


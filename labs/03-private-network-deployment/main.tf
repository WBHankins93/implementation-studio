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

# Private VPC Network
module "vpc" {
  source = "../../modules/gcp/vpc-private"
  
  network_name          = "${var.cluster_name}-vpc"
  region                = var.region
  private_subnet_cidr   = var.private_subnet_cidr
  management_subnet_cidr = var.management_subnet_cidr
  enable_management_nat  = var.enable_bastion_nat
}

# Private GKE Cluster
module "gke_cluster" {
  source = "../../modules/gcp/gke-cluster"
  
  project_id     = var.project_id
  cluster_name   = var.cluster_name
  region         = var.region
  network        = module.vpc.network_name
  subnetwork     = module.vpc.private_subnet_name
  
  # Private cluster configuration
  private_endpoint        = true  # Private API endpoint
  master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  network_policy_enabled  = true
  enable_vpa             = var.enable_vpa
  
  node_count     = var.node_count
  machine_type   = var.machine_type
  min_node_count = var.min_node_count
  max_node_count = var.max_node_count
  
  resource_labels = var.resource_labels
}

# Service Account for Bastion Host
resource "google_service_account" "bastion" {
  account_id   = "${var.cluster_name}-bastion"
  display_name = "Bastion Host Service Account for ${var.cluster_name}"
}

# Grant necessary permissions to bastion service account
resource "google_project_iam_member" "bastion_gke_access" {
  project = var.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.bastion.email}"
}

# Firewall rule to allow SSH to bastion from authorized IPs
resource "google_compute_firewall" "bastion_ssh" {
  name    = "${var.cluster_name}-bastion-ssh"
  network = module.vpc.network_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.bastion_authorized_networks
  target_tags   = ["bastion"]
  
  description = "Allow SSH access to bastion host from authorized networks"
}

# Firewall rule to allow bastion to access GKE master
resource "google_compute_firewall" "bastion_to_gke" {
  name    = "${var.cluster_name}-bastion-to-gke"
  network = module.vpc.network_name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = [var.management_subnet_cidr]
  target_tags   = ["gke-master"]
  
  description = "Allow bastion to access GKE master endpoint"
}

# Bastion Host
resource "google_compute_instance" "bastion" {
  name         = "${var.cluster_name}-bastion"
  machine_type = var.bastion_machine_type
  zone         = "${var.region}-a"
  
  tags = ["bastion"]

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/debian-12"
      size  = 20
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = module.vpc.network_name
    subnetwork = module.vpc.management_subnet_name
    
    # Assign external IP for SSH access (can be removed for fully private)
    access_config {
      # Ephemeral external IP
    }
  }

  service_account {
    email  = google_service_account.bastion.email
    scopes = ["cloud-platform"]
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y kubectl google-cloud-sdk-gke-gcloud-auth-plugin
    gcloud components install gke-gcloud-auth-plugin -q
  EOF
}

# Artifact Registry (for container images)
module "artifact_registry" {
  source = "../../modules/gcp/artifact-registry"
  
  project_id    = var.project_id
  region        = var.region
  repository_id = "${var.cluster_name}-repo"
  description   = "Container registry for ${var.cluster_name}"
  
  gke_service_account = null  # Will be set after cluster creation
}


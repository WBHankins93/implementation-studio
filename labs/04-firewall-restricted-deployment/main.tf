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

# Additional subnet for proxy (optional, can use existing subnet)
resource "google_compute_subnetwork" "proxy" {
  name          = "${var.cluster_name}-proxy"
  ip_cidr_range = var.proxy_subnet_cidr
  region        = var.region
  network       = module.vpc.network_id
  
  private_ip_google_access = true
  
  description = "Subnet for proxy server"
  
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
  }
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
  network_policy_enabled  = true
  enable_vpa             = var.enable_vpa
  
  node_count     = var.node_count
  machine_type   = var.machine_type
  min_node_count = var.min_node_count
  max_node_count = var.max_node_count
  
  resource_labels = merge(var.resource_labels, {
    firewall-restricted = "true"
  })
}

# Service Account for Proxy
resource "google_service_account" "proxy" {
  account_id   = "${var.cluster_name}-proxy"
  display_name = "Proxy Service Account for ${var.cluster_name}"
}

# Proxy VM Instance
resource "google_compute_instance" "proxy" {
  name         = "${var.cluster_name}-proxy"
  machine_type = var.proxy_machine_type
  zone         = "${var.region}-a"
  
  tags = ["proxy", "allow-proxy-access"]

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/debian-12"
      size  = 20
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = module.vpc.network_name
    subnetwork = google_compute_subnetwork.proxy.name
    
    # External IP for proxy (needed for outbound internet access)
    access_config {
      # Ephemeral external IP
    }
  }

  service_account {
    email  = google_service_account.proxy.email
    scopes = ["cloud-platform"]
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  metadata_startup_script = templatefile("${path.module}/proxy-config/squid-startup.sh", {
    proxy_port = var.proxy_port
  })
}

# Firewall rule to allow access to proxy
resource "google_compute_firewall" "allow_proxy_access" {
  name    = "${var.cluster_name}-allow-proxy-access"
  network = module.vpc.network_name

  allow {
    protocol = "tcp"
    ports    = [var.proxy_port]
  }

  source_ranges = [var.private_subnet_cidr]  # Allow from GKE nodes
  target_tags   = ["allow-proxy-access"]
  
  description = "Allow GKE nodes to access proxy server"
}

# Strict Egress Firewall Rules
module "firewall_rules" {
  source = "../../modules/gcp/firewall-rules"
  
  network_name        = module.vpc.network_name
  enable_strict_egress = var.enable_strict_egress
  target_tags         = ["gke-node"]
  
  proxy_subnet_cidr = var.proxy_subnet_cidr
  proxy_ports       = [var.proxy_port]
  
  allowed_external_endpoints = var.allowed_external_endpoints
  
  internal_ranges = [
    var.public_subnet_cidr,
    var.private_subnet_cidr,
    var.proxy_subnet_cidr
  ]
  
  allow_gcp_services = var.allow_gcp_services
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


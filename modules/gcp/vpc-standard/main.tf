terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# VPC Network
resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  
  description = "VPC network for ${var.network_name}"
}

# Public Subnet
resource "google_compute_subnetwork" "public" {
  name          = "${var.network_name}-public"
  ip_cidr_range = var.public_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
  
  description = "Public subnet for ${var.network_name}"
  
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
  }
}

# Private Subnet
resource "google_compute_subnetwork" "private" {
  name          = "${var.network_name}-private"
  ip_cidr_range = var.private_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
  private_ip_google_access = true
  
  description = "Private subnet for ${var.network_name}"
  
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
  }
}

# Cloud Router for NAT
resource "google_compute_router" "nat_router" {
  name    = "${var.network_name}-nat-router"
  region  = var.region
  network = google_compute_network.vpc.id
  
  bgp {
    asn = 64514
  }
}

# Cloud NAT for private subnet internet access
resource "google_compute_router_nat" "nat" {
  name                               = "${var.network_name}-nat"
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}


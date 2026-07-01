# VPC Network
resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"

  description = "Private VPC network for ${var.network_name}"
}

# Private Subnet for GKE
resource "google_compute_subnetwork" "private" {
  name          = "${var.network_name}-private"
  ip_cidr_range = var.private_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id

  # Enable private Google access for GCP services
  private_ip_google_access = true

  description = "Private subnet for GKE nodes in ${var.network_name}"

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
  }
}

# Management Subnet for Bastion Host
resource "google_compute_subnetwork" "management" {
  name          = "${var.network_name}-management"
  ip_cidr_range = var.management_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id

  # Enable private Google access
  private_ip_google_access = true

  description = "Management subnet for bastion host in ${var.network_name}"

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
  }
}

# Cloud Router for NAT (optional, only for management subnet if needed)
resource "google_compute_router" "nat_router" {
  count   = var.enable_management_nat ? 1 : 0
  name    = "${var.network_name}-nat-router"
  region  = var.region
  network = google_compute_network.vpc.id

  bgp {
    asn = 64514
  }
}

# Cloud NAT for management subnet (optional, only if enabled)
resource "google_compute_router_nat" "management_nat" {
  count  = var.enable_management_nat ? 1 : 0
  name   = "${var.network_name}-management-nat"
  router = google_compute_router.nat_router[0].name
  region = var.region

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.management.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

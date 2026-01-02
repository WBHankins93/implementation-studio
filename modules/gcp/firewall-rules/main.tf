terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Default deny-all egress rule
resource "google_compute_firewall" "deny_all_egress" {
  count = var.enable_strict_egress ? 1 : 0
  
  name    = "${var.network_name}-deny-all-egress"
  network = var.network_name
  direction = "EGRESS"
  priority   = 65534  # Lower priority (higher number) = applied first

  deny {
    protocol = "all"
  }

  destination_ranges = ["0.0.0.0/0"]
  target_tags       = var.target_tags
  
  description = "Deny all egress traffic (strict firewall mode)"
}

# Allow DNS egress
resource "google_compute_firewall" "allow_dns" {
  count = var.enable_strict_egress ? 1 : 0
  
  name    = "${var.network_name}-allow-dns"
  network = var.network_name
  direction = "EGRESS"
  priority   = 1000

  allow {
    protocol = "udp"
    ports    = ["53"]
  }
  
  allow {
    protocol = "tcp"
    ports    = ["53"]
  }

  destination_ranges = ["8.8.8.8/32", "8.8.4.4/32"]  # Google DNS
  target_tags       = var.target_tags
  
  description = "Allow DNS queries to Google DNS"
}

# Allow egress to proxy (if using proxy)
resource "google_compute_firewall" "allow_proxy" {
  count = var.enable_strict_egress && var.proxy_subnet_cidr != null ? 1 : 0
  
  name    = "${var.network_name}-allow-proxy"
  network = var.network_name
  direction = "EGRESS"
  priority   = 1000

  allow {
    protocol = "tcp"
    ports    = var.proxy_ports
  }

  destination_ranges = [var.proxy_subnet_cidr]
  target_tags       = var.target_tags
  
  description = "Allow egress to proxy server"
}

# Allow specific external endpoints (allowlist)
resource "google_compute_firewall" "allow_external_endpoints" {
  for_each = var.enable_strict_egress ? var.allowed_external_endpoints : {}
  
  name    = "${var.network_name}-allow-${replace(each.key, ".", "-")}"
  network = var.network_name
  direction = "EGRESS"
  priority   = 1000

  allow {
    protocol = each.value.protocol
    ports    = each.value.ports
  }

  destination_ranges = [each.value.cidr]
  target_tags       = var.target_tags
  
  description = "Allow egress to ${each.key}: ${each.value.description}"
}

# Allow internal VPC traffic (always allowed)
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.network_name}-allow-internal"
  network = var.network_name
  direction = "EGRESS"
  priority   = 100

  allow {
    protocol = "all"
  }

  destination_ranges = var.internal_ranges
  target_tags       = var.target_tags
  
  description = "Allow all internal VPC traffic"
}

# Allow egress to GCP services (Private Google Access)
resource "google_compute_firewall" "allow_gcp_services" {
  count = var.enable_strict_egress && var.allow_gcp_services ? 1 : 0
  
  name    = "${var.network_name}-allow-gcp-services"
  network = var.network_name
  direction = "EGRESS"
  priority   = 1000

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  # GCP service ranges (simplified - in production, use more specific ranges)
  destination_ranges = [
    "199.36.153.4/30",  # Google APIs
    "199.36.153.8/30",  # Google APIs
  ]
  target_tags       = var.target_tags
  
  description = "Allow egress to GCP services (Private Google Access)"
}


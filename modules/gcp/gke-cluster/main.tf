terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Service Account for GKE nodes
resource "google_service_account" "gke_node" {
  account_id   = "${var.cluster_name}-node-sa"
  display_name = "GKE Node Service Account for ${var.cluster_name}"
}

# Grant necessary permissions to node service account
resource "google_project_iam_member" "gke_node_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gke_node.email}"
}

resource "google_project_iam_member" "gke_node_monitoring" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gke_node.email}"
}

resource "google_project_iam_member" "gke_node_monitoring_viewer" {
  project = var.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.gke_node.email}"
}

# GKE Cluster
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region
  project  = var.project_id

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.network
  subnetwork = var.subnetwork

  # Private cluster configuration
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = var.private_endpoint
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  # Enable network policy
  network_policy {
    enabled = var.network_policy_enabled
  }

  # Enable workload identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Enable binary authorization
  binary_authorization {
    evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
  }

  # Enable vertical pod autoscaling
  vertical_pod_autoscaling {
    enabled = var.enable_vpa
  }

  # Enable GKE release channel
  release_channel {
    channel = var.release_channel
  }

  # Maintenance window
  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  # Master authorized networks (allow public access if not private endpoint)
  dynamic "master_authorized_networks_config" {
    for_each = var.private_endpoint ? [] : [1]
    content {
      cidr_blocks {
        cidr_block   = "0.0.0.0/0"
        display_name  = "All"
      }
    }
  }

  # Enable logging and monitoring
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  # Resource labels
  resource_labels = var.resource_labels

  depends_on = [
    google_project_iam_member.gke_node_logging,
    google_project_iam_member.gke_node_monitoring,
    google_project_iam_member.gke_node_monitoring_viewer,
  ]
}

# Node Pool
resource "google_container_node_pool" "primary" {
  name       = "${var.cluster_name}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  project    = var.project_id
  node_count = var.node_count

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    preemptible     = var.preemptible
    machine_type    = var.machine_type
    disk_size_gb    = var.disk_size_gb
    disk_type       = var.disk_type
    service_account = google_service_account.gke_node.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    # Enable workload identity
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # Labels
    labels = var.node_labels

    # Taints
    dynamic "taint" {
      for_each = var.node_taints
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }
  }

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }
}


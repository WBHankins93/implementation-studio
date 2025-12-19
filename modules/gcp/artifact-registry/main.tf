terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Artifact Registry Repository
resource "google_artifact_registry_repository" "repo" {
  location      = var.region
  repository_id = var.repository_id
  description   = var.description
  format        = "DOCKER"

  labels = var.labels
}

# IAM binding for GKE service account (if provided)
resource "google_artifact_registry_repository_iam_member" "gke_reader" {
  count      = var.gke_service_account != null ? 1 : 0
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.repo.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${var.gke_service_account}"
}


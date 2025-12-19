variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "repository_id" {
  description = "Repository ID"
  type        = string
}

variable "description" {
  description = "Repository description"
  type        = string
  default     = "Container image repository"
}

variable "labels" {
  description = "Labels to apply to the repository"
  type        = map(string)
  default     = {}
}

variable "gke_service_account" {
  description = "GKE service account email for IAM binding (optional)"
  type        = string
  default     = null
}


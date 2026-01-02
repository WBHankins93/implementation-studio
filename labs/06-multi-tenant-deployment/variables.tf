variable "project_id" {
  description = "GCP project ID (required if use_gcp is true)"
  type        = string
  default     = ""
}

variable "use_gcp" {
  description = "Use GCP (true) or Kind (false) for cluster"
  type        = bool
  default     = false
}

variable "cluster_name" {
  description = "Name of the cluster (GKE or Kind)"
  type        = string
  default     = "multi-tenant-cluster"
}

variable "region" {
  description = "GCP region (if using GCP)"
  type        = string
  default     = "us-central1"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet (GCP only)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet (GCP only)"
  type        = string
  default     = "10.0.2.0/24"
}

variable "node_count" {
  description = "Number of nodes per zone (GCP only)"
  type        = number
  default     = 2
}

variable "machine_type" {
  description = "Machine type for nodes (GCP only)"
  type        = string
  default     = "e2-medium"
}

variable "min_node_count" {
  description = "Minimum number of nodes (GCP only)"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of nodes (GCP only)"
  type        = number
  default     = 5
}

variable "resource_labels" {
  description = "Labels to apply to cluster resources"
  type        = map(string)
  default = {
    environment = "learning"
    managed-by  = "terraform"
    lab         = "06-multi-tenant"
  }
}


variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "implementation-studio"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "node_count" {
  description = "Number of nodes per zone"
  type        = number
  default     = 2
}

variable "machine_type" {
  description = "Machine type for nodes"
  type        = string
  default     = "e2-medium"
}

variable "min_node_count" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of nodes"
  type        = number
  default     = 5
}

variable "enable_vpa" {
  description = "Enable Vertical Pod Autoscaling"
  type        = bool
  default     = false
}

variable "resource_labels" {
  description = "Labels to apply to cluster resources"
  type        = map(string)
  default = {
    environment = "learning"
    managed-by  = "terraform"
  }
}


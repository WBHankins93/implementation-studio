variable "cloud_provider" {
  description = "Cloud provider: gcp or aws (use 'kind' for local deployment, no Terraform needed)"
  type        = string
  default     = "gcp"
  validation {
    condition     = contains(["gcp", "aws"], var.cloud_provider)
    error_message = "Cloud provider must be 'gcp' or 'aws'. For local deployment, use Kind directly (no Terraform)."
  }
}

# Common variables
variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "poc-cluster"
}

variable "region" {
  description = "Cloud region (GCP region or AWS region)"
  type        = string
  default     = "us-central1" # Default to GCP region, user should change for AWS
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
  description = "Number of nodes (per zone for GCP, desired count for AWS) - minimal for POC"
  type        = number
  default     = 1
}

variable "create_registry" {
  description = "Create container registry (optional for POC, can use public images)"
  type        = bool
  default     = false
}

variable "resource_labels" {
  description = "Labels/tags to apply to cluster resources"
  type        = map(string)
  default = {
    environment = "poc"
    managed-by  = "terraform"
    lab         = "05-poc-sprint"
    temporary   = "true"
  }
}

# GCP-specific variables
variable "project_id" {
  description = "GCP project ID (required when cloud_provider = 'gcp')"
  type        = string
  default     = null
}

variable "machine_type" {
  description = "GCP machine type for nodes (small for POC)"
  type        = string
  default     = "e2-small" # Smaller than standard for cost
}

# AWS-specific variables
variable "vpc_cidr" {
  description = "CIDR block for AWS VPC (required when cloud_provider = 'aws')"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of AWS availability zones (required when cloud_provider = 'aws')"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

variable "instance_type" {
  description = "AWS EC2 instance type for nodes (small for POC)"
  type        = string
  default     = "t3.small" # Small for POC cost
}

variable "node_labels" {
  description = "Kubernetes labels to apply to AWS nodes"
  type        = map(string)
  default     = {}
}

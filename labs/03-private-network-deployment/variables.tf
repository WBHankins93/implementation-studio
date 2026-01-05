variable "cloud_provider" {
  description = "Cloud provider: gcp or aws"
  type        = string
  default     = "gcp"
  validation {
    condition     = contains(["gcp", "aws"], var.cloud_provider)
    error_message = "Cloud provider must be 'gcp' or 'aws'."
  }
}

# Common variables
variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "implementation-studio-private"
}

variable "region" {
  description = "Cloud region (GCP region or AWS region)"
  type        = string
  default     = "us-central1" # Default to GCP region, user should change for AWS
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet (cluster nodes)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "management_subnet_cidr" {
  description = "CIDR block for management subnet (bastion host)"
  type        = string
  default     = "10.0.2.0/24"
}

variable "node_count" {
  description = "Number of nodes (per zone for GCP, desired count for AWS)"
  type        = number
  default     = 2
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

variable "bastion_authorized_networks" {
  description = "List of CIDR blocks allowed to SSH to bastion"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Restrict this in production!
}

variable "resource_labels" {
  description = "Labels/tags to apply to cluster resources"
  type        = map(string)
  default = {
    environment = "learning"
    managed-by  = "terraform"
    lab         = "03-private-network"
  }
}

# GCP-specific variables
variable "project_id" {
  description = "GCP project ID (required when cloud_provider = 'gcp')"
  type        = string
  default     = null
}

variable "master_ipv4_cidr_block" {
  description = "CIDR block for GKE master (must not overlap with subnets, GCP only)"
  type        = string
  default     = "172.16.0.0/28"
}

variable "machine_type" {
  description = "GCP machine type for nodes (e.g., e2-medium)"
  type        = string
  default     = "e2-medium"
}

variable "enable_vpa" {
  description = "Enable Vertical Pod Autoscaling (GCP only)"
  type        = bool
  default     = false
}

variable "bastion_machine_type" {
  description = "GCP machine type for bastion host"
  type        = string
  default     = "e2-micro"
}

variable "enable_bastion_nat" {
  description = "Enable NAT for bastion subnet (allows bastion to access internet, GCP only)"
  type        = bool
  default     = false
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
  description = "AWS EC2 instance type for nodes (e.g., t3.medium)"
  type        = string
  default     = "t3.medium"
}

variable "bastion_instance_type" {
  description = "AWS EC2 instance type for bastion host"
  type        = string
  default     = "t3.micro"
}

variable "node_labels" {
  description = "Kubernetes labels to apply to AWS nodes"
  type        = map(string)
  default     = {}
}

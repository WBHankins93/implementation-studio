variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "implementation-studio-private"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet (GKE nodes)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "management_subnet_cidr" {
  description = "CIDR block for management subnet (bastion host)"
  type        = string
  default     = "10.0.2.0/24"
}

variable "master_ipv4_cidr_block" {
  description = "CIDR block for GKE master (must not overlap with subnets)"
  type        = string
  default     = "172.16.0.0/28"
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

variable "bastion_machine_type" {
  description = "Machine type for bastion host"
  type        = string
  default     = "e2-micro"
}

variable "bastion_authorized_networks" {
  description = "List of CIDR blocks allowed to SSH to bastion"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Restrict this in production!
}

variable "enable_bastion_nat" {
  description = "Enable NAT for bastion subnet (allows bastion to access internet)"
  type        = bool
  default     = false
}

variable "resource_labels" {
  description = "Labels to apply to cluster resources"
  type        = map(string)
  default = {
    environment = "learning"
    managed-by  = "terraform"
    lab         = "03-private-network"
  }
}


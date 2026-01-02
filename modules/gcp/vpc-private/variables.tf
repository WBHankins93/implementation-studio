variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
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

variable "enable_management_nat" {
  description = "Enable NAT for management subnet (allows bastion to access internet)"
  type        = bool
  default     = false
}


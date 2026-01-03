variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet (EKS nodes)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "management_subnet_cidr" {
  description = "CIDR block for management subnet (bastion host)"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

variable "enable_management_nat" {
  description = "Enable NAT gateway for management subnet (requires public subnet - simplified version)"
  type        = bool
  default     = false
}

variable "resource_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}


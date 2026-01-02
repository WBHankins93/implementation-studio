variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "implementation-studio-firewall"
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
  description = "CIDR block for private subnet (GKE nodes)"
  type        = string
  default     = "10.0.2.0/24"
}

variable "proxy_subnet_cidr" {
  description = "CIDR block for proxy subnet"
  type        = string
  default     = "10.0.3.0/24"
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

variable "proxy_machine_type" {
  description = "Machine type for proxy server"
  type        = string
  default     = "e2-micro"
}

variable "proxy_port" {
  description = "Port for proxy server"
  type        = number
  default     = 3128
}

variable "enable_strict_egress" {
  description = "Enable strict egress firewall rules"
  type        = bool
  default     = true
}

variable "allow_gcp_services" {
  description = "Allow egress to GCP services (Private Google Access)"
  type        = bool
  default     = true
}

variable "allowed_external_endpoints" {
  description = "Map of allowed external endpoints (when not using proxy)"
  type = map(object({
    protocol    = string
    ports       = list(string)
    cidr        = string
    description = string
  }))
  default = {}
}

variable "resource_labels" {
  description = "Labels to apply to cluster resources"
  type        = map(string)
  default = {
    environment = "learning"
    managed-by  = "terraform"
    lab         = "04-firewall-restricted"
  }
}


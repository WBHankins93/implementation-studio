variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "enable_strict_egress" {
  description = "Enable strict egress firewall rules (deny-all by default)"
  type        = bool
  default     = false
}

variable "target_tags" {
  description = "Target tags for firewall rules (applied to instances with these tags)"
  type        = list(string)
  default     = []
}

variable "proxy_subnet_cidr" {
  description = "CIDR block of proxy subnet (if using proxy)"
  type        = string
  default     = null
}

variable "proxy_ports" {
  description = "Ports used by proxy server"
  type        = list(string)
  default     = ["3128", "8080"]
}

variable "allowed_external_endpoints" {
  description = "Map of allowed external endpoints (key: name, value: {protocol, ports, cidr, description})"
  type = map(object({
    protocol    = string
    ports       = list(string)
    cidr        = string
    description = string
  }))
  default = {}
}

variable "internal_ranges" {
  description = "Internal IP ranges (VPC subnets)"
  type        = list(string)
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

variable "allow_gcp_services" {
  description = "Allow egress to GCP services (Private Google Access)"
  type        = bool
  default     = true
}


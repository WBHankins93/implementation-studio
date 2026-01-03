variable "name_prefix" {
  description = "Prefix for security group names"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "cluster_security_group_id" {
  description = "Security group ID of the EKS cluster"
  type        = string
}

variable "enable_strict_egress" {
  description = "Enable strict egress rules (deny all by default, then allow specific)"
  type        = bool
  default     = false
}

variable "dns_servers" {
  description = "List of DNS server IPs to allow"
  type        = list(string)
  default     = ["8.8.8.8/32", "8.8.4.4/32"] # Google DNS
}

variable "proxy_security_group_id" {
  description = "Security group ID of the proxy server (alternative to proxy_cidr)"
  type        = string
  default     = null
}

variable "proxy_cidr" {
  description = "CIDR block of the proxy server (alternative to proxy_security_group_id)"
  type        = string
  default     = null
}

variable "proxy_port" {
  description = "Port of the proxy server"
  type        = number
  default     = 3128 # Squid default port
}

variable "allow_aws_services" {
  description = "Allow HTTPS egress to AWS services (requires prefix_list_ids)"
  type        = bool
  default     = false
}

variable "aws_services_prefix_list_ids" {
  description = "List of VPC prefix list IDs for AWS services (e.g., S3, ECR)"
  type        = list(string)
  default     = []
}

variable "allowed_external_endpoints" {
  description = "Map of external endpoints to allow (key = name, value = {cidr, port, protocol, description})"
  type = map(object({
    cidr        = string
    port        = number
    protocol    = string
    description = string
  }))
  default = {}
}

variable "resource_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}


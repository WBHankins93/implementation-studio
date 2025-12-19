variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "network" {
  description = "VPC network name"
  type        = string
}

variable "subnetwork" {
  description = "Subnet name"
  type        = string
}

variable "private_endpoint" {
  description = "Enable private endpoint (private cluster)"
  type        = bool
  default     = false
}

variable "master_ipv4_cidr_block" {
  description = "CIDR block for GKE master"
  type        = string
  default     = "172.16.0.0/28"
}

variable "network_policy_enabled" {
  description = "Enable network policy"
  type        = bool
  default     = true
}

variable "enable_vpa" {
  description = "Enable Vertical Pod Autoscaling"
  type        = bool
  default     = false
}

variable "release_channel" {
  description = "GKE release channel"
  type        = string
  default     = "REGULAR"
  validation {
    condition     = contains(["REGULAR", "RAPID", "STABLE", "UNSPECIFIED"], var.release_channel)
    error_message = "Release channel must be REGULAR, RAPID, STABLE, or UNSPECIFIED."
  }
}

variable "node_count" {
  description = "Number of nodes per zone"
  type        = number
  default     = 1
}

variable "min_node_count" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of nodes"
  type        = number
  default     = 3
}

variable "machine_type" {
  description = "Machine type for nodes"
  type        = string
  default     = "e2-medium"
}

variable "disk_size_gb" {
  description = "Disk size in GB"
  type        = number
  default     = 100
}

variable "disk_type" {
  description = "Disk type"
  type        = string
  default     = "pd-standard"
}

variable "preemptible" {
  description = "Use preemptible instances"
  type        = bool
  default     = false
}

variable "node_labels" {
  description = "Labels to apply to nodes"
  type        = map(string)
  default     = {}
}

variable "node_taints" {
  description = "Taints to apply to nodes"
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
}

variable "resource_labels" {
  description = "Labels to apply to cluster resources"
  type        = map(string)
  default     = {}
}


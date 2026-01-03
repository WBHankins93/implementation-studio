variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "node_subnet_ids" {
  description = "List of subnet IDs for EKS nodes (defaults to subnet_ids if not specified)"
  type        = list(string)
  default     = null
}

variable "private_endpoint" {
  description = "Enable private endpoint (private cluster)"
  type        = bool
  default     = false
}

variable "public_access_cidrs" {
  description = "List of CIDR blocks allowed to access the public endpoint (when private_endpoint is false)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "kubernetes_version" {
  description = "Kubernetes version for the cluster"
  type        = string
  default     = null # Let AWS determine latest stable version
}

variable "network_policy_enabled" {
  description = "Enable Kubernetes network policies (requires VPC CNI addon)"
  type        = bool
  default     = true
}

variable "node_count" {
  description = "Desired number of nodes in the node group"
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
  default     = 3
}

variable "instance_type" {
  description = "EC2 instance type for nodes"
  type        = string
  default     = "t3.medium"
}

variable "disk_size_gb" {
  description = "Disk size in GB for nodes"
  type        = number
  default     = 20
}

variable "ami_type" {
  description = "AMI type for nodes (AL2_x86_64, AL2_ARM_64, CUSTOM, BOTTLEROCKET_ARM_64, BOTTLEROCKET_x86_64)"
  type        = string
  default     = "AL2_x86_64"
  validation {
    condition = contains([
      "AL2_x86_64",
      "AL2_ARM_64",
      "CUSTOM",
      "BOTTLEROCKET_ARM_64",
      "BOTTLEROCKET_x86_64"
    ], var.ami_type)
    error_message = "AMI type must be one of: AL2_x86_64, AL2_ARM_64, CUSTOM, BOTTLEROCKET_ARM_64, BOTTLEROCKET_x86_64."
  }
}

variable "capacity_type" {
  description = "Type of capacity for nodes (ON_DEMAND or SPOT)"
  type        = string
  default     = "ON_DEMAND"
  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.capacity_type)
    error_message = "Capacity type must be ON_DEMAND or SPOT."
  }
}

variable "node_labels" {
  description = "Key-value map of Kubernetes labels to apply to nodes"
  type        = map(string)
  default     = {}
}

variable "node_taints" {
  description = "List of Kubernetes taints to apply to nodes. Note: Taints should be applied via Kubernetes after node group creation for better control."
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
}

variable "update_max_unavailable" {
  description = "Maximum number of nodes unavailable during updates"
  type        = number
  default     = 1
}

variable "kms_key_id" {
  description = "KMS key ID for cluster encryption. If not provided, a new key will be created."
  type        = string
  default     = null
}

variable "enabled_cluster_log_types" {
  description = "List of log types to enable (api, audit, authenticator, controllerManager, scheduler)"
  type        = list(string)
  default     = ["api", "audit"]
}

variable "log_retention_in_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 7
}

variable "additional_security_group_ids" {
  description = "Additional security group IDs to attach to the cluster"
  type        = list(string)
  default     = []
}

variable "resource_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}


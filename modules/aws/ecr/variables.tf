variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Image tag mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Encryption type for the repository (AES256 or KMS)"
  type        = string
  default     = "AES256"
  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "Encryption type must be AES256 or KMS."
  }
}

variable "kms_key_id" {
  description = "The KMS key to use when encryption_type is KMS. If not specified, uses the default AWS managed key for ECR."
  type        = string
  default     = null
}

variable "lifecycle_policy" {
  description = "The policy document for ECR lifecycle policy (JSON string). If null, no lifecycle policy is applied."
  type        = string
  default     = null
}

variable "repository_policy" {
  description = "The policy document for the ECR repository (JSON string). If null, no repository policy is applied."
  type        = string
  default     = null
}

variable "eks_node_role_arn" {
  description = "ARN of the EKS node role to grant ECR pull permissions. If null, no IAM policy is created."
  type        = string
  default     = null
}

variable "resource_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}


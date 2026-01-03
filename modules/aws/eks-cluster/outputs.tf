output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.primary.name
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint"
  value       = aws_eks_cluster.primary.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Base64 encoded certificate authority data"
  value       = aws_eks_cluster.primary.certificate_authority[0].data
  sensitive   = true
}

output "cluster_id" {
  description = "ID of the EKS cluster"
  value       = aws_eks_cluster.primary.id
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = aws_eks_cluster.primary.arn
}

output "cluster_version" {
  description = "Kubernetes version of the cluster"
  value       = aws_eks_cluster.primary.version
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the cluster control plane"
  value       = aws_eks_cluster.primary.vpc_config[0].cluster_security_group_id
}

output "node_group_name" {
  description = "Name of the node group"
  value       = aws_eks_node_group.primary.node_group_name
}

output "node_group_arn" {
  description = "ARN of the node group"
  value       = aws_eks_node_group.primary.arn
}

output "node_role_arn" {
  description = "IAM role ARN for EKS nodes (for IRSA configuration)"
  value       = aws_iam_role.eks_node_group.arn
}

output "cluster_role_arn" {
  description = "IAM role ARN for EKS cluster"
  value       = aws_iam_role.eks_cluster.arn
}

output "kms_key_id" {
  description = "KMS key ARN used for cluster encryption"
  value       = var.kms_key_id != null ? var.kms_key_id : (length(aws_kms_key.eks) > 0 ? aws_kms_key.eks[0].arn : null)
}


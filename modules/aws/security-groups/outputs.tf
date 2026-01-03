output "nodes_security_group_id" {
  description = "ID of the security group for EKS nodes"
  value       = aws_security_group.eks_nodes.id
}

output "nodes_security_group_arn" {
  description = "ARN of the security group for EKS nodes"
  value       = aws_security_group.eks_nodes.arn
}


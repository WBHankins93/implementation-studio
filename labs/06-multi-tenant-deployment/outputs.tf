# GCP Outputs
output "gcp_cluster_name" {
  description = "Name of the GKE cluster (GCP only)"
  value       = var.cloud_provider == "gcp" ? module.gke_cluster[0].cluster_name : null
}

output "gcp_cluster_endpoint" {
  description = "GKE cluster endpoint (GCP only)"
  value       = var.cloud_provider == "gcp" ? module.gke_cluster[0].cluster_endpoint : null
  sensitive   = true
}

output "gcp_cluster_location" {
  description = "GKE cluster location (GCP only)"
  value       = var.cloud_provider == "gcp" ? module.gke_cluster[0].cluster_location : null
}

# AWS Outputs
output "aws_cluster_name" {
  description = "Name of the EKS cluster (AWS only)"
  value       = var.cloud_provider == "aws" ? module.eks_cluster[0].cluster_name : null
}

output "aws_cluster_endpoint" {
  description = "EKS cluster endpoint (AWS only)"
  value       = var.cloud_provider == "aws" ? module.eks_cluster[0].cluster_endpoint : null
  sensitive   = true
}

output "aws_cluster_arn" {
  description = "EKS cluster ARN (AWS only)"
  value       = var.cloud_provider == "aws" ? module.eks_cluster[0].cluster_arn : null
}

# Common outputs (provider-agnostic)
output "cluster_name" {
  description = "Name of the Kubernetes cluster"
  value = var.cloud_provider == "kind" ? var.cluster_name : (
    var.cloud_provider == "gcp" ? module.gke_cluster[0].cluster_name : module.eks_cluster[0].cluster_name
  )
}

output "cluster_type" {
  description = "Type of cluster (kind, gke, or eks)"
  value       = var.cloud_provider == "kind" ? "kind" : (var.cloud_provider == "gcp" ? "gke" : "eks")
}

output "get_credentials_command" {
  description = "Command to get cluster credentials"
  value = var.cloud_provider == "kind" ? "kind get kubeconfig --name ${var.cluster_name}" : (
    var.cloud_provider == "gcp" ? "gcloud container clusters get-credentials ${module.gke_cluster[0].cluster_name} --region ${var.region} --project ${var.project_id}" : "aws eks update-kubeconfig --region ${var.region} --name ${module.eks_cluster[0].cluster_name}"
  )
}

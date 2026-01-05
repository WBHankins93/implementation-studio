# Common outputs (provider-agnostic)
output "cluster_name" {
  description = "Name of the Kubernetes cluster"
  value       = var.cloud_provider == "gcp" ? module.gke_cluster[0].cluster_name : module.eks_cluster[0].cluster_name
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint"
  value       = var.cloud_provider == "gcp" ? module.gke_cluster[0].cluster_endpoint : module.eks_cluster[0].cluster_endpoint
  sensitive   = true
}

output "get_credentials_command" {
  description = "Command to get cluster credentials"
  value       = var.cloud_provider == "gcp" ? "gcloud container clusters get-credentials ${module.gke_cluster[0].cluster_name} --region ${var.region} --project ${var.project_id}" : "aws eks update-kubeconfig --region ${var.region} --name ${module.eks_cluster[0].cluster_name}"
}

output "vpc_network_name" {
  description = "VPC network name/ID"
  value       = var.cloud_provider == "gcp" ? module.vpc_gcp[0].network_name : module.vpc_aws[0].vpc_id
}

output "registry_url" {
  description = "Container registry URL (if created)"
  value       = var.create_registry ? (var.cloud_provider == "gcp" ? module.artifact_registry[0].repository_url : module.ecr[0].repository_url) : null
}

# GCP-specific outputs
output "gcp_cluster_name" {
  description = "Name of the GKE cluster (GCP only)"
  value       = var.cloud_provider == "gcp" ? module.gke_cluster[0].cluster_name : null
}

output "gcp_artifact_registry_url" {
  description = "Artifact Registry URL (GCP only, if created)"
  value       = var.cloud_provider == "gcp" && var.create_registry ? module.artifact_registry[0].repository_url : null
}

# AWS-specific outputs
output "aws_cluster_name" {
  description = "Name of the EKS cluster (AWS only)"
  value       = var.cloud_provider == "aws" ? module.eks_cluster[0].cluster_name : null
}

output "aws_ecr_repository_url" {
  description = "ECR repository URL (AWS only, if created)"
  value       = var.cloud_provider == "aws" && var.create_registry ? module.ecr[0].repository_url : null
}

# GCP Outputs
output "gcp_cluster_name" {
  description = "Name of the GKE cluster (GCP only)"
  value       = var.cloud_provider == "gcp" ? module.gke_cluster[0].cluster_name : null
}

output "gcp_cluster_endpoint" {
  description = "Kubernetes API endpoint (GCP only)"
  value       = var.cloud_provider == "gcp" ? module.gke_cluster[0].cluster_endpoint : null
  sensitive   = true
}

output "gcp_cluster_location" {
  description = "Location of the cluster (GCP only)"
  value       = var.cloud_provider == "gcp" ? module.gke_cluster[0].cluster_location : null
}

output "gcp_proxy_name" {
  description = "Name of the proxy server (GCP only)"
  value       = var.cloud_provider == "gcp" ? google_compute_instance.proxy[0].name : null
}

output "gcp_proxy_zone" {
  description = "Zone of the proxy server (GCP only)"
  value       = var.cloud_provider == "gcp" ? google_compute_instance.proxy[0].zone : null
}

output "gcp_proxy_internal_ip" {
  description = "Internal IP of the proxy server (GCP only)"
  value       = var.cloud_provider == "gcp" ? google_compute_instance.proxy[0].network_interface[0].network_ip : null
}

output "gcp_proxy_external_ip" {
  description = "External IP of the proxy server (GCP only)"
  value       = var.cloud_provider == "gcp" ? google_compute_instance.proxy[0].network_interface[0].access_config[0].nat_ip : null
}

output "gcp_artifact_registry_url" {
  description = "Artifact Registry URL (GCP only)"
  value       = var.cloud_provider == "gcp" ? module.artifact_registry[0].repository_url : null
}

# AWS Outputs
output "aws_cluster_name" {
  description = "Name of the EKS cluster (AWS only)"
  value       = var.cloud_provider == "aws" ? module.eks_cluster[0].cluster_name : null
}

output "aws_cluster_endpoint" {
  description = "Kubernetes API endpoint (AWS only)"
  value       = var.cloud_provider == "aws" ? module.eks_cluster[0].cluster_endpoint : null
  sensitive   = true
}

output "aws_cluster_arn" {
  description = "EKS cluster ARN (AWS only)"
  value       = var.cloud_provider == "aws" ? module.eks_cluster[0].cluster_arn : null
}

output "aws_proxy_public_ip" {
  description = "Public IP of the proxy server (AWS only)"
  value       = var.cloud_provider == "aws" ? aws_instance.proxy[0].public_ip : null
}

output "aws_proxy_private_ip" {
  description = "Private IP of the proxy server (AWS only)"
  value       = var.cloud_provider == "aws" ? aws_instance.proxy[0].private_ip : null
}

output "aws_ecr_repository_url" {
  description = "ECR repository URL (AWS only)"
  value       = var.cloud_provider == "aws" ? module.ecr[0].repository_url : null
}

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

output "proxy_internal_ip" {
  description = "Internal IP of the proxy server"
  value       = var.cloud_provider == "gcp" ? google_compute_instance.proxy[0].network_interface[0].network_ip : aws_instance.proxy[0].private_ip
}

output "proxy_external_ip" {
  description = "External IP of the proxy server"
  value       = var.cloud_provider == "gcp" ? google_compute_instance.proxy[0].network_interface[0].access_config[0].nat_ip : aws_instance.proxy[0].public_ip
}

output "proxy_url" {
  description = "Proxy URL for HTTP_PROXY/HTTPS_PROXY environment variables"
  value       = var.cloud_provider == "gcp" ? "http://${google_compute_instance.proxy[0].network_interface[0].network_ip}:${var.proxy_port}" : "http://${aws_instance.proxy[0].private_ip}:${var.proxy_port}"
}

output "get_credentials_command" {
  description = "Command to get cluster credentials"
  value       = var.cloud_provider == "gcp" ? "gcloud container clusters get-credentials ${module.gke_cluster[0].cluster_name} --region ${var.region} --project ${var.project_id}" : "aws eks update-kubeconfig --region ${var.region} --name ${module.eks_cluster[0].cluster_name}"
}

output "vpc_network_name" {
  description = "VPC network name/ID"
  value       = var.cloud_provider == "gcp" ? module.vpc_gcp[0].network_name : module.vpc_aws[0].vpc_id
}

output "private_subnet_name" {
  description = "Private subnet name/ID"
  value       = var.cloud_provider == "gcp" ? module.vpc_gcp[0].private_subnet_name : module.vpc_aws[0].private_subnet_ids[0]
}

output "proxy_subnet_name" {
  description = "Proxy subnet name/ID"
  value       = var.cloud_provider == "gcp" ? google_compute_subnetwork.proxy[0].name : aws_subnet.proxy[0].id
}

output "registry_url" {
  description = "Container registry URL"
  value       = var.cloud_provider == "gcp" ? module.artifact_registry[0].repository_url : module.ecr[0].repository_url
}

output "firewall_rules" {
  description = "List of firewall rules/security groups created (GCP only)"
  value       = var.cloud_provider == "gcp" ? module.firewall_rules[0].firewall_rules : null
}

output "security_groups" {
  description = "List of security groups created (AWS only)"
  value       = var.cloud_provider == "aws" ? module.security_groups[0].security_group_ids : null
}

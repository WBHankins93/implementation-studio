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
  description = "Container registry URL"
  value       = var.cloud_provider == "gcp" ? module.artifact_registry[0].repository_url : module.ecr[0].repository_url
}

# GCP-specific outputs
output "gcp_cluster_name" {
  description = "Name of the GKE cluster (GCP only)"
  value       = var.cloud_provider == "gcp" ? module.gke_cluster[0].cluster_name : null
}

output "gcp_cloud_sql_instance_name" {
  description = "Cloud SQL instance name (GCP only, if created)"
  value       = var.cloud_provider == "gcp" && var.create_database ? google_sql_database_instance.main[0].name : null
}

output "gcp_cloud_sql_connection_name" {
  description = "Cloud SQL connection name (GCP only, if created)"
  value       = var.cloud_provider == "gcp" && var.create_database ? google_sql_database_instance.main[0].connection_name : null
}

output "gcp_cloud_sql_private_ip" {
  description = "Cloud SQL private IP (GCP only, if created)"
  value       = var.cloud_provider == "gcp" && var.create_database ? google_sql_database_instance.main[0].private_ip_address : null
  sensitive   = true
}

output "gcp_artifact_registry_url" {
  description = "Artifact Registry URL (GCP only)"
  value       = var.cloud_provider == "gcp" ? module.artifact_registry[0].repository_url : null
}

# AWS-specific outputs
output "aws_cluster_name" {
  description = "Name of the EKS cluster (AWS only)"
  value       = var.cloud_provider == "aws" ? module.eks_cluster[0].cluster_name : null
}

output "aws_rds_endpoint" {
  description = "RDS instance endpoint (AWS only, if created)"
  value       = var.cloud_provider == "aws" && var.create_database ? module.rds[0].db_instance_endpoint : null
}

output "aws_rds_address" {
  description = "RDS instance hostname (AWS only, if created)"
  value       = var.cloud_provider == "aws" && var.create_database ? module.rds[0].db_instance_address : null
}

output "aws_rds_port" {
  description = "RDS instance port (AWS only, if created)"
  value       = var.cloud_provider == "aws" && var.create_database ? module.rds[0].db_instance_port : null
}

output "aws_rds_proxy_endpoint" {
  description = "RDS Proxy endpoint (AWS only, if created)"
  value       = var.cloud_provider == "aws" && var.create_database && var.create_rds_proxy ? module.rds[0].rds_proxy_endpoint : null
}

output "aws_ecr_repository_url" {
  description = "ECR repository URL (AWS only)"
  value       = var.cloud_provider == "aws" ? module.ecr[0].repository_url : null
}

# Database outputs (provider-agnostic)
output "database_endpoint" {
  description = "Database endpoint (hostname:port)"
  value = var.create_database ? (
    var.cloud_provider == "gcp" ? "${google_sql_database_instance.main[0].private_ip_address}:5432" : module.rds[0].db_instance_endpoint
  ) : null
}

output "database_host" {
  description = "Database hostname"
  value = var.create_database ? (
    var.cloud_provider == "gcp" ? google_sql_database_instance.main[0].private_ip_address : module.rds[0].db_instance_address
  ) : null
}

output "database_port" {
  description = "Database port"
  value = var.create_database ? (
    var.cloud_provider == "gcp" ? 5432 : module.rds[0].db_instance_port
  ) : null
}

output "database_name" {
  description = "Database name"
  value       = var.create_database ? var.db_name : null
}

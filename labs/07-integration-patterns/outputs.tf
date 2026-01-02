output "cluster_name" {
  description = "Name of the GKE cluster"
  value       = module.gke_cluster.cluster_name
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint"
  value       = module.gke_cluster.cluster_endpoint
  sensitive   = true
}

output "get_credentials_command" {
  description = "Command to get cluster credentials"
  value       = "gcloud container clusters get-credentials ${module.gke_cluster.cluster_name} --region ${var.region} --project ${var.project_id}"
}

output "cloud_sql_instance_name" {
  description = "Cloud SQL instance name (if created)"
  value       = var.create_cloud_sql ? google_sql_database_instance.main[0].name : null
}

output "cloud_sql_connection_name" {
  description = "Cloud SQL connection name (if created)"
  value       = var.create_cloud_sql ? google_sql_database_instance.main[0].connection_name : null
}

output "cloud_sql_private_ip" {
  description = "Cloud SQL private IP (if created)"
  value       = var.create_cloud_sql ? google_sql_database_instance.main[0].private_ip_address : null
  sensitive   = true
}

output "vpc_network_name" {
  description = "VPC network name"
  value       = module.vpc.network_name
}

output "artifact_registry_url" {
  description = "Artifact Registry URL"
  value       = module.artifact_registry.repository_url
}


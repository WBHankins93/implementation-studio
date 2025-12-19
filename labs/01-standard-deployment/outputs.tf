output "cluster_name" {
  description = "Name of the GKE cluster"
  value       = module.gke_cluster.cluster_name
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint"
  value       = module.gke_cluster.cluster_endpoint
  sensitive   = true
}

output "cluster_location" {
  description = "Location of the cluster"
  value       = module.gke_cluster.cluster_location
}

output "get_credentials_command" {
  description = "Command to get cluster credentials"
  value       = "gcloud container clusters get-credentials ${module.gke_cluster.cluster_name} --region ${var.region} --project ${var.project_id}"
}

output "artifact_registry_url" {
  description = "Artifact Registry URL"
  value       = module.artifact_registry.repository_url
}

output "vpc_network_name" {
  description = "VPC network name"
  value       = module.vpc.network_name
}


output "cluster_name" {
  description = "Name of the cluster"
  value       = var.use_gcp ? module.gke_cluster[0].cluster_name : var.cluster_name
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint (GCP only)"
  value       = var.use_gcp ? module.gke_cluster[0].cluster_endpoint : "kind cluster - use kubectl"
  sensitive   = true
}

output "get_credentials_command" {
  description = "Command to get cluster credentials (GCP only)"
  value       = var.use_gcp ? "gcloud container clusters get-credentials ${module.gke_cluster[0].cluster_name} --region ${var.region} --project ${var.project_id}" : "kind get kubeconfig --name ${var.cluster_name}"
}

output "cluster_type" {
  description = "Type of cluster (gke or kind)"
  value       = var.use_gcp ? "gke" : "kind"
}


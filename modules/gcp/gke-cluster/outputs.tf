output "cluster_name" {
  description = "Name of the GKE cluster"
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint"
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Base64 encoded certificate"
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "cluster_location" {
  description = "Location of the cluster"
  value       = google_container_cluster.primary.location
}

output "cluster_id" {
  description = "ID of the cluster"
  value       = google_container_cluster.primary.id
}

output "node_pool_name" {
  description = "Name of the node pool"
  value       = google_container_node_pool.primary.name
}


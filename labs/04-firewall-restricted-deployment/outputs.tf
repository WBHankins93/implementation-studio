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

output "proxy_name" {
  description = "Name of the proxy server"
  value       = google_compute_instance.proxy.name
}

output "proxy_zone" {
  description = "Zone of the proxy server"
  value       = google_compute_instance.proxy.zone
}

output "proxy_internal_ip" {
  description = "Internal IP of the proxy server"
  value       = google_compute_instance.proxy.network_interface[0].network_ip
}

output "proxy_external_ip" {
  description = "External IP of the proxy server"
  value       = google_compute_instance.proxy.network_interface[0].access_config[0].nat_ip
}

output "proxy_url" {
  description = "Proxy URL for HTTP_PROXY/HTTPS_PROXY environment variables"
  value       = "http://${google_compute_instance.proxy.network_interface[0].network_ip}:${var.proxy_port}"
}

output "get_credentials_command" {
  description = "Command to get cluster credentials"
  value       = "gcloud container clusters get-credentials ${module.gke_cluster.cluster_name} --region ${var.region} --project ${var.project_id}"
}

output "vpc_network_name" {
  description = "VPC network name"
  value       = module.vpc.network_name
}

output "private_subnet_name" {
  description = "Private subnet name"
  value       = module.vpc.private_subnet_name
}

output "proxy_subnet_name" {
  description = "Proxy subnet name"
  value       = google_compute_subnetwork.proxy.name
}

output "artifact_registry_url" {
  description = "Artifact Registry URL"
  value       = module.artifact_registry.repository_url
}

output "firewall_rules" {
  description = "List of firewall rules created"
  value       = module.firewall_rules.firewall_rules
}


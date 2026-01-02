output "cluster_name" {
  description = "Name of the GKE cluster"
  value       = module.gke_cluster.cluster_name
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint (private)"
  value       = module.gke_cluster.cluster_endpoint
  sensitive   = true
}

output "cluster_location" {
  description = "Location of the cluster"
  value       = module.gke_cluster.cluster_location
}

output "bastion_name" {
  description = "Name of the bastion host"
  value       = google_compute_instance.bastion.name
}

output "bastion_zone" {
  description = "Zone of the bastion host"
  value       = google_compute_instance.bastion.zone
}

output "bastion_external_ip" {
  description = "External IP of the bastion host"
  value       = google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip
}

output "bastion_ssh_command" {
  description = "Command to SSH to bastion host"
  value       = "gcloud compute ssh ${google_compute_instance.bastion.name} --zone ${google_compute_instance.bastion.zone} --project ${var.project_id}"
}

output "get_credentials_command" {
  description = "Command to get cluster credentials (run from bastion)"
  value       = "gcloud container clusters get-credentials ${module.gke_cluster.cluster_name} --region ${var.region} --project ${var.project_id} --internal-ip"
}

output "vpc_network_name" {
  description = "VPC network name"
  value       = module.vpc.network_name
}

output "private_subnet_name" {
  description = "Private subnet name"
  value       = module.vpc.private_subnet_name
}

output "management_subnet_name" {
  description = "Management subnet name"
  value       = module.vpc.management_subnet_name
}

output "artifact_registry_url" {
  description = "Artifact Registry URL"
  value       = module.artifact_registry.repository_url
}


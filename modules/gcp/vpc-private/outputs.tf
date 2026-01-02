output "network_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.vpc.name
}

output "network_id" {
  description = "ID of the VPC network"
  value       = google_compute_network.vpc.id
}

output "private_subnet_name" {
  description = "Name of the private subnet"
  value       = google_compute_subnetwork.private.name
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = google_compute_subnetwork.private.id
}

output "management_subnet_name" {
  description = "Name of the management subnet"
  value       = google_compute_subnetwork.management.name
}

output "management_subnet_id" {
  description = "ID of the management subnet"
  value       = google_compute_subnetwork.management.id
}


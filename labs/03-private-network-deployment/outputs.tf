# GCP Outputs
output "gcp_cluster_name" {
  description = "Name of the GKE cluster (GCP only)"
  value       = var.cloud_provider == "gcp" ? module.gke_cluster[0].cluster_name : null
}

output "gcp_cluster_endpoint" {
  description = "Kubernetes API endpoint (private, GCP only)"
  value       = var.cloud_provider == "gcp" ? module.gke_cluster[0].cluster_endpoint : null
  sensitive   = true
}

output "gcp_cluster_location" {
  description = "Location of the cluster (GCP only)"
  value       = var.cloud_provider == "gcp" ? module.gke_cluster[0].cluster_location : null
}

output "gcp_bastion_name" {
  description = "Name of the bastion host (GCP only)"
  value       = var.cloud_provider == "gcp" ? google_compute_instance.bastion[0].name : null
}

output "gcp_bastion_zone" {
  description = "Zone of the bastion host (GCP only)"
  value       = var.cloud_provider == "gcp" ? google_compute_instance.bastion[0].zone : null
}

output "gcp_bastion_external_ip" {
  description = "External IP of the bastion host (GCP only)"
  value       = var.cloud_provider == "gcp" ? google_compute_instance.bastion[0].network_interface[0].access_config[0].nat_ip : null
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
  description = "Kubernetes API endpoint (private, AWS only)"
  value       = var.cloud_provider == "aws" ? module.eks_cluster[0].cluster_endpoint : null
  sensitive   = true
}

output "aws_cluster_arn" {
  description = "EKS cluster ARN (AWS only)"
  value       = var.cloud_provider == "aws" ? module.eks_cluster[0].cluster_arn : null
}

output "aws_bastion_public_ip" {
  description = "Public IP of the bastion host (AWS only)"
  value       = var.cloud_provider == "aws" ? aws_instance.bastion[0].public_ip : null
}

output "aws_bastion_private_ip" {
  description = "Private IP of the bastion host (AWS only)"
  value       = var.cloud_provider == "aws" ? aws_instance.bastion[0].private_ip : null
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
  description = "Kubernetes API endpoint (private)"
  value       = var.cloud_provider == "gcp" ? module.gke_cluster[0].cluster_endpoint : module.eks_cluster[0].cluster_endpoint
  sensitive   = true
}

output "bastion_ssh_command" {
  description = "Command to SSH to bastion host"
  value       = var.cloud_provider == "gcp" ? "gcloud compute ssh ${google_compute_instance.bastion[0].name} --zone ${google_compute_instance.bastion[0].zone} --project ${var.project_id}" : "ssh -i ~/.ssh/id_rsa ec2-user@${aws_instance.bastion[0].public_ip}"
}

output "get_credentials_command" {
  description = "Command to get cluster credentials (run from bastion)"
  value       = var.cloud_provider == "gcp" ? "gcloud container clusters get-credentials ${module.gke_cluster[0].cluster_name} --region ${var.region} --project ${var.project_id} --internal-ip" : "aws eks update-kubeconfig --region ${var.region} --name ${module.eks_cluster[0].cluster_name}"
}

output "vpc_network_name" {
  description = "VPC network name"
  value       = var.cloud_provider == "gcp" ? module.vpc_gcp[0].network_name : module.vpc_aws[0].vpc_id
}

output "private_subnet_name" {
  description = "Private subnet name/ID"
  value       = var.cloud_provider == "gcp" ? module.vpc_gcp[0].private_subnet_name : module.vpc_aws[0].private_subnet_ids[0]
}

output "management_subnet_name" {
  description = "Management subnet name/ID"
  value       = var.cloud_provider == "gcp" ? module.vpc_gcp[0].management_subnet_name : module.vpc_aws[0].management_subnet_id
}

output "registry_url" {
  description = "Container registry URL"
  value       = var.cloud_provider == "gcp" ? module.artifact_registry[0].repository_url : module.ecr[0].repository_url
}

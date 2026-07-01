terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure providers conditionally
provider "google" {
  project = var.project_id
  region  = var.region
}

provider "aws" {
  region = var.region
}

# ============================================================================
# GCP Resources (when cloud_provider = "gcp")
# ============================================================================

# Private VPC Network (GCP)
module "vpc_gcp" {
  count  = var.cloud_provider == "gcp" ? 1 : 0
  source = "../../modules/gcp/vpc-private"

  network_name           = "${var.cluster_name}-vpc"
  region                 = var.region
  private_subnet_cidr    = var.private_subnet_cidr
  management_subnet_cidr = var.management_subnet_cidr
  enable_management_nat  = var.enable_bastion_nat
}

# Private GKE Cluster
module "gke_cluster" {
  count  = var.cloud_provider == "gcp" ? 1 : 0
  source = "../../modules/gcp/gke-cluster"

  project_id   = var.project_id
  cluster_name = var.cluster_name
  region       = var.region
  network      = module.vpc_gcp[0].network_name
  subnetwork   = module.vpc_gcp[0].private_subnet_name

  # Private cluster configuration
  private_endpoint       = true # Private API endpoint
  master_ipv4_cidr_block = var.master_ipv4_cidr_block
  network_policy_enabled = true
  enable_vpa             = var.enable_vpa

  node_count     = var.node_count
  machine_type   = var.machine_type
  min_node_count = var.min_node_count
  max_node_count = var.max_node_count

  resource_labels = var.resource_labels
}

# Service Account for Bastion Host (GCP)
resource "google_service_account" "bastion" {
  count        = var.cloud_provider == "gcp" ? 1 : 0
  account_id   = "${var.cluster_name}-bastion"
  display_name = "Bastion Host Service Account for ${var.cluster_name}"
}

# Grant necessary permissions to bastion service account (GCP)
resource "google_project_iam_member" "bastion_gke_access" {
  count   = var.cloud_provider == "gcp" ? 1 : 0
  project = var.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.bastion[0].email}"
}

# Firewall rule to allow SSH to bastion from authorized IPs (GCP)
resource "google_compute_firewall" "bastion_ssh" {
  count   = var.cloud_provider == "gcp" ? 1 : 0
  name    = "${var.cluster_name}-bastion-ssh"
  network = module.vpc_gcp[0].network_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.bastion_authorized_networks
  target_tags   = ["bastion"]

  description = "Allow SSH access to bastion host from authorized networks"
}

# Firewall rule to allow bastion to access GKE master (GCP)
resource "google_compute_firewall" "bastion_to_gke" {
  count   = var.cloud_provider == "gcp" ? 1 : 0
  name    = "${var.cluster_name}-bastion-to-gke"
  network = module.vpc_gcp[0].network_name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = [var.management_subnet_cidr]
  target_tags   = ["gke-master"]

  description = "Allow bastion to access GKE master endpoint"
}

# Bastion Host (GCP)
resource "google_compute_instance" "bastion" {
  count        = var.cloud_provider == "gcp" ? 1 : 0
  name         = "${var.cluster_name}-bastion"
  machine_type = var.bastion_machine_type
  zone         = "${var.region}-a"

  tags = ["bastion"]

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/debian-12"
      size  = 20
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = module.vpc_gcp[0].network_name
    subnetwork = module.vpc_gcp[0].management_subnet_name

    # Assign external IP for SSH access (can be removed for fully private)
    access_config {
      # Ephemeral external IP
    }
  }

  service_account {
    email  = google_service_account.bastion[0].email
    scopes = ["cloud-platform"]
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y kubectl google-cloud-sdk-gke-gcloud-auth-plugin
    gcloud components install gke-gcloud-auth-plugin -q
  EOF
}

# Artifact Registry (GCP)
module "artifact_registry" {
  count  = var.cloud_provider == "gcp" ? 1 : 0
  source = "../../modules/gcp/artifact-registry"

  project_id    = var.project_id
  region        = var.region
  repository_id = "${var.cluster_name}-repo"
  description   = "Container registry for ${var.cluster_name}"

  gke_service_account = null # Will be set after cluster creation
}

# ============================================================================
# AWS Resources (when cloud_provider = "aws")
# ============================================================================

# Private VPC Network (AWS)
module "vpc_aws" {
  count  = var.cloud_provider == "aws" ? 1 : 0
  source = "../../modules/aws/vpc-private"

  network_name           = "${var.cluster_name}-vpc"
  vpc_cidr               = var.vpc_cidr
  private_subnet_cidr    = var.private_subnet_cidr
  management_subnet_cidr = var.management_subnet_cidr
  availability_zones     = var.availability_zones

  resource_tags = merge(var.resource_labels, {
    purpose = "private-network"
  })
}

# Private EKS Cluster (AWS)
module "eks_cluster" {
  count  = var.cloud_provider == "aws" ? 1 : 0
  source = "../../modules/aws/eks-cluster"

  cluster_name = var.cluster_name
  region       = var.region
  subnet_ids   = module.vpc_aws[0].private_subnet_ids

  # Private endpoint configuration
  private_endpoint = true

  node_count     = var.node_count
  instance_type  = var.instance_type
  min_node_count = var.min_node_count
  max_node_count = var.max_node_count

  node_labels = var.node_labels
  resource_tags = merge(var.resource_labels, {
    purpose = "private-network"
  })
}

# Security Group for Bastion (AWS)
resource "aws_security_group" "bastion" {
  count       = var.cloud_provider == "aws" ? 1 : 0
  name        = "${var.cluster_name}-bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = module.vpc_aws[0].vpc_id

  # Allow SSH from authorized networks
  ingress {
    description = "SSH from authorized networks"
    from_port   = 22
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = var.bastion_authorized_networks
  }

  # Allow outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.resource_labels, {
    Name = "${var.cluster_name}-bastion-sg"
  })
}

# Security Group Rule: Bastion to EKS (AWS)
resource "aws_security_group_rule" "bastion_to_eks" {
  count                    = var.cloud_provider == "aws" ? 1 : 0
  description              = "Allow bastion to access EKS API"
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion[0].id
  security_group_id        = module.eks_cluster[0].cluster_security_group_id
}

# IAM Role for Bastion (AWS)
resource "aws_iam_role" "bastion" {
  count = var.cloud_provider == "aws" ? 1 : 0
  name  = "${var.cluster_name}-bastion-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })

  tags = merge(var.resource_labels, {
    Name = "${var.cluster_name}-bastion-role"
  })
}

# IAM Policy for Bastion to access EKS (AWS)
resource "aws_iam_role_policy" "bastion_eks_access" {
  count = var.cloud_provider == "aws" ? 1 : 0
  name  = "${var.cluster_name}-bastion-eks-access"
  role  = aws_iam_role.bastion[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "eks:DescribeCluster",
        "eks:ListClusters"
      ]
      Resource = "*"
    }]
  })
}

# IAM Instance Profile for Bastion (AWS)
resource "aws_iam_instance_profile" "bastion" {
  count = var.cloud_provider == "aws" ? 1 : 0
  name  = "${var.cluster_name}-bastion-profile"
  role  = aws_iam_role.bastion[0].name

  tags = merge(var.resource_labels, {
    Name = "${var.cluster_name}-bastion-profile"
  })
}

# Bastion Host (AWS)
data "aws_ami" "bastion" {
  count       = var.cloud_provider == "aws" ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "bastion" {
  count         = var.cloud_provider == "aws" ? 1 : 0
  ami           = data.aws_ami.bastion[0].id
  instance_type = var.bastion_instance_type
  subnet_id     = module.vpc_aws[0].management_subnet_id

  vpc_security_group_ids = [aws_security_group.bastion[0].id]
  iam_instance_profile   = aws_iam_instance_profile.bastion[0].name

  # Assign public IP for SSH access (can be removed for fully private with Systems Manager)
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    mv kubectl /usr/local/bin/
    # Install AWS CLI v2 if not present
    if ! command -v aws &> /dev/null; then
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
      unzip awscliv2.zip
      ./aws/install
    fi
  EOF

  tags = merge(var.resource_labels, {
    Name = "${var.cluster_name}-bastion"
  })
}

# ECR Repository (AWS)
module "ecr" {
  count  = var.cloud_provider == "aws" ? 1 : 0
  source = "../../modules/aws/ecr"

  repository_name = "${var.cluster_name}-repo"

  resource_tags = merge(var.resource_labels, {
    purpose = "private-network"
  })
}

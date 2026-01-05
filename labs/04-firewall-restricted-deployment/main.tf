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
  count   = var.cloud_provider == "gcp" ? 1 : 0
  project = var.project_id
  region  = var.region
}

provider "aws" {
  count  = var.cloud_provider == "aws" ? 1 : 0
  region = var.region
}

# ============================================================================
# GCP Resources (when cloud_provider = "gcp")
# ============================================================================

# VPC Network (GCP)
module "vpc_gcp" {
  count  = var.cloud_provider == "gcp" ? 1 : 0
  source = "../../modules/gcp/vpc-standard"

  network_name        = "${var.cluster_name}-vpc"
  region              = var.region
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

# Additional subnet for proxy (GCP)
resource "google_compute_subnetwork" "proxy" {
  count         = var.cloud_provider == "gcp" ? 1 : 0
  name          = "${var.cluster_name}-proxy"
  ip_cidr_range = var.proxy_subnet_cidr
  region        = var.region
  network       = module.vpc_gcp[0].network_id

  private_ip_google_access = true

  description = "Subnet for proxy server"

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
  }
}

# GKE Cluster (GCP)
module "gke_cluster" {
  count  = var.cloud_provider == "gcp" ? 1 : 0
  source = "../../modules/gcp/gke-cluster"

  project_id   = var.project_id
  cluster_name = var.cluster_name
  region       = var.region
  network      = module.vpc_gcp[0].network_name
  subnetwork   = module.vpc_gcp[0].private_subnet_name

  private_endpoint       = false # Public endpoint for standard deployment
  network_policy_enabled = true
  enable_vpa             = var.enable_vpa

  node_count     = var.node_count
  machine_type   = var.machine_type
  min_node_count = var.min_node_count
  max_node_count = var.max_node_count

  resource_labels = merge(var.resource_labels, {
    firewall-restricted = "true"
  })
}

# Service Account for Proxy (GCP)
resource "google_service_account" "proxy" {
  count        = var.cloud_provider == "gcp" ? 1 : 0
  account_id   = "${var.cluster_name}-proxy"
  display_name = "Proxy Service Account for ${var.cluster_name}"
}

# Proxy VM Instance (GCP)
resource "google_compute_instance" "proxy" {
  count        = var.cloud_provider == "gcp" ? 1 : 0
  name         = "${var.cluster_name}-proxy"
  machine_type = var.proxy_machine_type
  zone         = "${var.region}-a"

  tags = ["proxy", "allow-proxy-access"]

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/debian-12"
      size  = 20
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = module.vpc_gcp[0].network_name
    subnetwork = google_compute_subnetwork.proxy[0].name

    # External IP for proxy (needed for outbound internet access)
    access_config {
      # Ephemeral external IP
    }
  }

  service_account {
    email  = google_service_account.proxy[0].email
    scopes = ["cloud-platform"]
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  metadata_startup_script = templatefile("${path.module}/proxy-config/squid-startup.sh", {
    proxy_port = var.proxy_port
  })
}

# Firewall rule to allow access to proxy (GCP)
resource "google_compute_firewall" "allow_proxy_access" {
  count   = var.cloud_provider == "gcp" ? 1 : 0
  name    = "${var.cluster_name}-allow-proxy-access"
  network = module.vpc_gcp[0].network_name

  allow {
    protocol = "tcp"
    ports    = [var.proxy_port]
  }

  source_ranges = [var.private_subnet_cidr] # Allow from GKE nodes
  target_tags   = ["allow-proxy-access"]

  description = "Allow GKE nodes to access proxy server"
}

# Strict Egress Firewall Rules (GCP)
module "firewall_rules" {
  count  = var.cloud_provider == "gcp" ? 1 : 0
  source = "../../modules/gcp/firewall-rules"

  network_name         = module.vpc_gcp[0].network_name
  enable_strict_egress = var.enable_strict_egress
  target_tags          = ["gke-node"]

  proxy_subnet_cidr = var.proxy_subnet_cidr
  proxy_ports       = [var.proxy_port]

  allowed_external_endpoints = var.allowed_external_endpoints

  internal_ranges = [
    var.public_subnet_cidr,
    var.private_subnet_cidr,
    var.proxy_subnet_cidr
  ]

  allow_gcp_services = var.allow_gcp_services
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

# VPC Network (AWS)
module "vpc_aws" {
  count  = var.cloud_provider == "aws" ? 1 : 0
  source = "../../modules/aws/vpc"

  network_name        = "${var.cluster_name}-vpc"
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zones  = var.availability_zones

  resource_tags = merge(var.resource_labels, {
    firewall-restricted = "true"
  })
}

# Additional subnet for proxy (AWS)
resource "aws_subnet" "proxy" {
  count             = var.cloud_provider == "aws" ? 1 : 0
  vpc_id            = module.vpc_aws[0].vpc_id
  cidr_block        = var.proxy_subnet_cidr
  availability_zone = var.availability_zones[0]

  map_public_ip_on_launch = true

  tags = merge(var.resource_labels, {
    Name = "${var.cluster_name}-proxy-subnet"
    Type = "proxy"
  })
}

# Route table for proxy subnet (AWS)
resource "aws_route_table" "proxy" {
  count  = var.cloud_provider == "aws" ? 1 : 0
  vpc_id = module.vpc_aws[0].vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = module.vpc_aws[0].internet_gateway_id
  }

  tags = merge(var.resource_labels, {
    Name = "${var.cluster_name}-proxy-rt"
  })
}

resource "aws_route_table_association" "proxy" {
  count          = var.cloud_provider == "aws" ? 1 : 0
  subnet_id      = aws_subnet.proxy[0].id
  route_table_id = aws_route_table.proxy[0].id
}

# EKS Cluster (AWS) - Create first to get cluster security group ID
module "eks_cluster" {
  count  = var.cloud_provider == "aws" ? 1 : 0
  source = "../../modules/aws/eks-cluster"

  cluster_name = var.cluster_name
  region       = var.region
  subnet_ids   = module.vpc_aws[0].private_subnet_ids

  private_endpoint = false # Public endpoint for standard deployment

  node_count     = var.node_count
  instance_type  = var.instance_type
  min_node_count = var.min_node_count
  max_node_count = var.max_node_count

  node_labels = var.node_labels
  resource_tags = merge(var.resource_labels, {
    firewall-restricted = "true"
  })
}

# Strict Egress Security Groups (AWS) - Create after cluster and proxy
module "security_groups" {
  count  = var.cloud_provider == "aws" ? 1 : 0
  source = "../../modules/aws/security-groups"

  name_prefix               = var.cluster_name
  vpc_id                    = module.vpc_aws[0].vpc_id
  vpc_cidr                  = var.vpc_cidr
  cluster_security_group_id = module.eks_cluster[0].cluster_security_group_id
  enable_strict_egress      = var.enable_strict_egress

  # Proxy configuration
  proxy_security_group_id = aws_security_group.proxy[0].id
  proxy_port              = var.proxy_port

  # Allowed external endpoints (if not using proxy)
  # Convert from map with ports list to map with port number
  allowed_external_endpoints = {
    for k, v in var.allowed_external_endpoints : k => {
      cidr        = v.cidr
      port        = try(tonumber(v.ports[0]), 443)
      protocol    = v.protocol
      description = v.description
    }
  }

  resource_tags = merge(var.resource_labels, {
    firewall-restricted = "true"
  })

  depends_on = [
    module.eks_cluster,
    aws_security_group.proxy
  ]
}

# Security Group for Proxy (AWS)
resource "aws_security_group" "proxy" {
  count       = var.cloud_provider == "aws" ? 1 : 0
  name        = "${var.cluster_name}-proxy-sg"
  description = "Security group for proxy server"
  vpc_id      = module.vpc_aws[0].vpc_id

  # Allow inbound from private subnet (EKS nodes)
  ingress {
    description = "Proxy access from EKS nodes"
    from_port   = var.proxy_port
    to_port     = var.proxy_port
    protocol    = "tcp"
    cidr_blocks = [var.private_subnet_cidr]
  }

  # Allow all outbound (proxy needs internet access)
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.resource_labels, {
    Name = "${var.cluster_name}-proxy-sg"
  })
}

# IAM Role for Proxy (AWS)
resource "aws_iam_role" "proxy" {
  count = var.cloud_provider == "aws" ? 1 : 0
  name  = "${var.cluster_name}-proxy-role"

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
    Name = "${var.cluster_name}-proxy-role"
  })
}

resource "aws_iam_instance_profile" "proxy" {
  count = var.cloud_provider == "aws" ? 1 : 0
  name  = "${var.cluster_name}-proxy-profile"
  role  = aws_iam_role.proxy[0].name

  tags = merge(var.resource_labels, {
    Name = "${var.cluster_name}-proxy-profile"
  })
}

# Proxy EC2 Instance (AWS)
data "aws_ami" "proxy" {
  count       = var.cloud_provider == "aws" ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "proxy" {
  count         = var.cloud_provider == "aws" ? 1 : 0
  ami           = data.aws_ami.proxy[0].id
  instance_type = var.proxy_instance_type
  subnet_id     = aws_subnet.proxy[0].id

  vpc_security_group_ids = [aws_security_group.proxy[0].id]
  iam_instance_profile   = aws_iam_instance_profile.proxy[0].name

  associate_public_ip_address = true

  user_data = templatefile("${path.module}/proxy-config/squid-startup.sh", {
    proxy_port = var.proxy_port
  })

  tags = merge(var.resource_labels, {
    Name = "${var.cluster_name}-proxy"
  })
}

# Note: For EKS managed node groups, the security group rules created by the module
# will apply to traffic from the nodes. The nodes use the cluster's security groups
# and VPC CNI security groups. The strict egress rules are enforced at the VPC level.

# ECR Repository (AWS)
module "ecr" {
  count  = var.cloud_provider == "aws" ? 1 : 0
  source = "../../modules/aws/ecr"

  repository_name = "${var.cluster_name}-repo"
  description     = "Container registry for ${var.cluster_name}"

  resource_tags = merge(var.resource_labels, {
    firewall-restricted = "true"
  })
}

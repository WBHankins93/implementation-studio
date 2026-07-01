# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.resource_tags,
    {
      Name = "${var.cluster_name}-cluster-role"
    }
  )
}

# Attach AWS managed policy for EKS cluster
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# IAM Role for EKS Node Group
resource "aws_iam_role" "eks_node_group" {
  name = "${var.cluster_name}-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.resource_tags,
    {
      Name = "${var.cluster_name}-node-group-role"
    }
  )
}

# Attach AWS managed policies for EKS node group
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "eks_container_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group.name
}

# CloudWatch Log Group for EKS
resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.log_retention_in_days

  tags = merge(
    var.resource_tags,
    {
      Name = "${var.cluster_name}-logs"
    }
  )
}

# KMS Key for EKS encryption (if not provided)
resource "aws_kms_key" "eks" {
  count = var.kms_key_id == null ? 1 : 0

  description             = "EKS cluster encryption key for ${var.cluster_name}"
  deletion_window_in_days = 10

  tags = merge(
    var.resource_tags,
    {
      Name = "${var.cluster_name}-eks-encryption-key"
    }
  )
}

# Local value to determine KMS key ARN
locals {
  kms_key_arn = var.kms_key_id != null ? var.kms_key_id : (length(aws_kms_key.eks) > 0 ? aws_kms_key.eks[0].arn : null)
}

# EKS Cluster
resource "aws_eks_cluster" "primary" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.private_endpoint
    endpoint_public_access  = !var.private_endpoint
    public_access_cidrs     = var.private_endpoint ? [] : var.public_access_cidrs
    security_group_ids      = var.additional_security_group_ids
  }

  # Enable encryption at rest (if KMS key provided or created)
  dynamic "encryption_config" {
    for_each = local.kms_key_arn != null ? [1] : []
    content {
      provider {
        key_arn = local.kms_key_arn
      }
      resources = ["secrets"]
    }
  }

  # Enable logging
  enabled_cluster_log_types = var.enabled_cluster_log_types

  tags = merge(
    var.resource_tags,
    {
      Name = var.cluster_name
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_cloudwatch_log_group.eks_cluster,
  ]
}

# EKS Node Group
resource "aws_eks_node_group" "primary" {
  cluster_name    = aws_eks_cluster.primary.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node_group.arn
  subnet_ids      = var.node_subnet_ids != null ? var.node_subnet_ids : var.subnet_ids

  scaling_config {
    desired_size = var.node_count
    min_size     = var.min_node_count
    max_size     = var.max_node_count
  }

  instance_types = [var.instance_type]

  # Disk configuration
  disk_size = var.disk_size_gb

  # AMI type
  ami_type = var.ami_type

  # Capacity type (ON_DEMAND or SPOT)
  capacity_type = var.capacity_type

  # Update configuration
  update_config {
    max_unavailable = var.update_max_unavailable
  }

  # Labels
  labels = var.node_labels

  # Note: Taints should be applied via Kubernetes after node group creation
  # Example: kubectl taint nodes <node-name> key=value:effect

  tags = merge(
    var.resource_tags,
    {
      Name = "${var.cluster_name}-node-group"
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy,
  ]
}

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ECR Repository
resource "aws_ecr_repository" "repo" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key         = var.kms_key_id
  }

  tags = merge(
    var.resource_tags,
    {
      Name = var.repository_name
    }
  )
}

# Lifecycle Policy (optional)
resource "aws_ecr_lifecycle_policy" "repo" {
  count      = var.lifecycle_policy != null ? 1 : 0
  repository = aws_ecr_repository.repo.name

  policy = var.lifecycle_policy
}

# Repository Policy (optional, for cross-account access, etc.)
resource "aws_ecr_repository_policy" "repo" {
  count      = var.repository_policy != null ? 1 : 0
  repository = aws_ecr_repository.repo.name

  policy = var.repository_policy
}

# IAM Policy for EKS Node Role to pull images (if node role ARN provided)
resource "aws_iam_role_policy" "ecr_pull" {
  count = var.eks_node_role_arn != null ? 1 : 0
  name  = "${var.repository_name}-ecr-pull-policy"
  role  = var.eks_node_role_arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = aws_ecr_repository.repo.arn
      },
      {
        Effect   = "Allow"
        Action   = "ecr:GetAuthorizationToken"
        Resource = "*"
      }
    ]
  })
}


# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.db_instance_identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.resource_tags,
    {
      Name = "${var.db_instance_identifier}-subnet-group"
    }
  )
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name        = "${var.db_instance_identifier}-sg"
  description = "Security group for RDS instance"
  vpc_id      = var.vpc_id

  # Allow inbound from VPC CIDR (for private access)
  ingress {
    description = "PostgreSQL from VPC"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Allow inbound from specific security groups (e.g., EKS nodes)
  dynamic "ingress" {
    for_each = var.allowed_security_group_ids
    content {
      description     = "PostgreSQL from security group"
      from_port       = var.db_port
      to_port         = var.db_port
      protocol        = "tcp"
      security_groups = [ingress.value]
    }
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.resource_tags,
    {
      Name = "${var.db_instance_identifier}-sg"
    }
  )
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier = var.db_instance_identifier

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  # Network configuration
  publicly_accessible = var.publicly_accessible
  port                = var.db_port

  # Backup configuration
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  # Deletion protection
  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot

  # Monitoring
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn             = var.monitoring_role_arn

  # Performance Insights
  performance_insights_enabled = var.performance_insights_enabled

  tags = merge(
    var.resource_tags,
    {
      Name = var.db_instance_identifier
    }
  )
}

# IAM Role for RDS Proxy to read database credentials
resource "aws_iam_role" "rds_proxy" {
  count = var.create_rds_proxy ? 1 : 0

  name = "${var.db_instance_identifier}-proxy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.resource_tags,
    {
      Name = "${var.db_instance_identifier}-proxy-role"
    }
  )
}

resource "aws_iam_role_policy" "rds_proxy_secrets" {
  count = var.create_rds_proxy ? 1 : 0

  name = "${var.db_instance_identifier}-proxy-secrets"
  role = aws_iam_role.rds_proxy[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = aws_secretsmanager_secret.db_credentials[0].arn
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = "*"
      }
    ]
  })
}

# RDS Proxy (optional, for connection pooling)
resource "aws_db_proxy" "main" {
  count = var.create_rds_proxy ? 1 : 0

  name                   = "${var.db_instance_identifier}-proxy"
  engine_family          = var.engine_family
  role_arn               = aws_iam_role.rds_proxy[0].arn
  vpc_subnet_ids         = var.subnet_ids
  vpc_security_group_ids = [aws_security_group.rds_proxy[0].id]

  auth {
    auth_scheme = "SECRETS"
    secret_arn  = aws_secretsmanager_secret.db_credentials[0].arn
  }

  require_tls = var.proxy_require_tls

  tags = merge(
    var.resource_tags,
    {
      Name = "${var.db_instance_identifier}-proxy"
    }
  )
}

# Security Group for RDS Proxy
resource "aws_security_group" "rds_proxy" {
  count = var.create_rds_proxy ? 1 : 0

  name        = "${var.db_instance_identifier}-proxy-sg"
  description = "Security group for RDS Proxy"
  vpc_id      = var.vpc_id

  # Allow inbound from VPC CIDR
  ingress {
    description = "RDS Proxy from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Allow inbound from specific security groups
  dynamic "ingress" {
    for_each = var.allowed_security_group_ids
    content {
      description     = "RDS Proxy from security group"
      from_port       = 5432
      to_port         = 5432
      protocol        = "tcp"
      security_groups = [ingress.value]
    }
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.resource_tags,
    {
      Name = "${var.db_instance_identifier}-proxy-sg"
    }
  )
}

# Secrets Manager Secret for RDS credentials (for RDS Proxy)
resource "aws_secretsmanager_secret" "db_credentials" {
  count = var.create_rds_proxy ? 1 : 0

  name = "${var.db_instance_identifier}-credentials"

  tags = merge(
    var.resource_tags,
    {
      Name = "${var.db_instance_identifier}-credentials"
    }
  )
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  count = var.create_rds_proxy ? 1 : 0

  secret_id = aws_secretsmanager_secret.db_credentials[0].id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}

# RDS Proxy Target (connects proxy to RDS instance)
resource "aws_db_proxy_target" "main" {
  count = var.create_rds_proxy ? 1 : 0

  db_instance_identifier = aws_db_instance.main.id
  db_proxy_name          = aws_db_proxy.main[0].name
  target_group_name      = "default"
}

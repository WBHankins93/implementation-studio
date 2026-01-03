terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Security Group for EKS Nodes
resource "aws_security_group" "eks_nodes" {
  name        = "${var.name_prefix}-nodes-sg"
  description = "Security group for EKS nodes"
  vpc_id      = var.vpc_id

  # Note: AWS security groups are allow-only. By default, all egress is allowed.
  # To restrict egress, we don't create a default allow-all rule and only add specific allow rules.

  tags = merge(
    var.resource_tags,
    {
      Name = "${var.name_prefix}-nodes-sg"
    }
  )
}

# Security Group Rule: Allow all egress (only if strict egress is disabled)
resource "aws_security_group_rule" "allow_all_egress" {
  count = var.enable_strict_egress ? 0 : 1

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_nodes.id
  description       = "Allow all outbound traffic (default when strict egress disabled)"
}

# Security Group Rule: Allow DNS egress
resource "aws_security_group_rule" "allow_dns_egress" {
  count = var.enable_strict_egress ? 1 : 0

  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = var.dns_servers
  security_group_id = aws_security_group.eks_nodes.id
  description       = "Allow DNS queries"
}

# Security Group Rule: Allow DNS TCP egress (for large DNS responses)
resource "aws_security_group_rule" "allow_dns_tcp_egress" {
  count = var.enable_strict_egress ? 1 : 0

  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  cidr_blocks       = var.dns_servers
  security_group_id = aws_security_group.eks_nodes.id
  description       = "Allow DNS TCP queries (for large responses)"
}

# Security Group Rule: Allow egress to proxy (if using proxy)
resource "aws_security_group_rule" "allow_proxy_egress" {
  count = var.enable_strict_egress && var.proxy_security_group_id != null ? 1 : 0

  type                     = "egress"
  from_port                = var.proxy_port
  to_port                  = var.proxy_port
  protocol                 = "tcp"
  source_security_group_id = var.proxy_security_group_id
  security_group_id        = aws_security_group.eks_nodes.id
  description              = "Allow egress to proxy server"
}

# Security Group Rule: Allow egress to proxy by CIDR (alternative to security group)
resource "aws_security_group_rule" "allow_proxy_cidr_egress" {
  count = var.enable_strict_egress && var.proxy_security_group_id == null && var.proxy_cidr != null ? 1 : 0

  type              = "egress"
  from_port         = var.proxy_port
  to_port           = var.proxy_port
  protocol          = "tcp"
  cidr_blocks       = [var.proxy_cidr]
  security_group_id = aws_security_group.eks_nodes.id
  description       = "Allow egress to proxy server (by CIDR)"
}

# Security Group Rule: Allow internal VPC traffic
resource "aws_security_group_rule" "allow_internal_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.eks_nodes.id
  description       = "Allow all internal VPC traffic"
}

# Security Group Rule: Allow HTTPS egress to AWS services (if enabled)
resource "aws_security_group_rule" "allow_aws_services_egress" {
  count = var.enable_strict_egress && var.allow_aws_services ? 1 : 0

  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  prefix_list_ids   = var.aws_services_prefix_list_ids
  security_group_id = aws_security_group.eks_nodes.id
  description       = "Allow HTTPS to AWS services"
}

# Security Group Rule: Allow specific external endpoints (allowlist)
resource "aws_security_group_rule" "allow_external_endpoints" {
  for_each = var.enable_strict_egress ? var.allowed_external_endpoints : {}

  type              = "egress"
  from_port         = each.value.port
  to_port           = each.value.port
  protocol          = each.value.protocol
  cidr_blocks       = [each.value.cidr]
  security_group_id = aws_security_group.eks_nodes.id
  description       = "Allow egress to ${each.key}: ${each.value.description}"
}

# Security Group Rule: Allow inbound from cluster (for node-to-node communication)
resource "aws_security_group_rule" "allow_cluster_inbound" {
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = var.cluster_security_group_id
  security_group_id        = aws_security_group.eks_nodes.id
  description              = "Allow inbound from EKS cluster"
}

# Security Group Rule: Allow inbound from nodes (for node-to-node communication)
resource "aws_security_group_rule" "allow_nodes_inbound" {
  type              = "ingress"
  from_port         = 1025
  to_port           = 65535
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.eks_nodes.id
  description       = "Allow inbound from other nodes"
}


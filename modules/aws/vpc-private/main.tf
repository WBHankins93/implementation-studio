terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# VPC (no internet gateway)
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.resource_tags,
    {
      Name = var.network_name
    }
  )
}

# Private Subnet for EKS Nodes
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zones[0]

  tags = merge(
    var.resource_tags,
    {
      Name                              = "${var.network_name}-private"
      "kubernetes.io/role/internal-elb" = "1"
    }
  )
}

# Management Subnet for Bastion Host
resource "aws_subnet" "management" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.management_subnet_cidr
  availability_zone = length(var.availability_zones) > 1 ? var.availability_zones[1] : var.availability_zones[0]

  tags = merge(
    var.resource_tags,
    {
      Name = "${var.network_name}-management"
    }
  )
}

# Route Table for Private Subnet (no internet access)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.resource_tags,
    {
      Name = "${var.network_name}-private-rt"
    }
  )
}

# Route Table Association for Private Subnet
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# Route Table for Management Subnet (optional NAT if enabled)
resource "aws_route_table" "management" {
  vpc_id = aws_vpc.main.id

  # Only add NAT route if NAT is enabled
  dynamic "route" {
    for_each = var.enable_management_nat ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.management[0].id
    }
  }

  tags = merge(
    var.resource_tags,
    {
      Name = "${var.network_name}-management-rt"
    }
  )
}

# Route Table Association for Management Subnet
resource "aws_route_table_association" "management" {
  subnet_id      = aws_subnet.management.id
  route_table_id = aws_route_table.management.id
}

# VPC Endpoints for AWS Services (Private Google Access equivalent)
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  tags = merge(
    var.resource_tags,
    {
      Name = "${var.network_name}-s3-endpoint"
    }
  )
}

# Get current AWS region
data "aws_region" "current" {}

# Optional: NAT Gateway for Management Subnet (if enabled)
resource "aws_eip" "management_nat" {
  count = var.enable_management_nat ? 1 : 0

  domain = "vpc"

  tags = merge(
    var.resource_tags,
    {
      Name = "${var.network_name}-management-nat-eip"
    }
  )
}

# Note: NAT Gateway requires a public subnet. For a fully private VPC,
# you would need to create a small public subnet just for the NAT gateway,
# or use VPC endpoints instead. This is a simplified version.
# In production, you might want to separate this into a dedicated public subnet.

resource "aws_nat_gateway" "management" {
  count = var.enable_management_nat ? 1 : 0

  allocation_id = aws_eip.management_nat[0].id
  subnet_id     = aws_subnet.management.id # In production, this should be a separate public subnet

  tags = merge(
    var.resource_tags,
    {
      Name = "${var.network_name}-management-nat"
    }
  )

  depends_on = [aws_eip.management_nat]
}


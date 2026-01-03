output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private.id
}

output "private_subnet_cidr" {
  description = "CIDR block of the private subnet"
  value       = aws_subnet.private.cidr_block
}

output "private_subnet_ids" {
  description = "List of private subnet IDs (for EKS compatibility)"
  value       = [aws_subnet.private.id]
}

output "management_subnet_id" {
  description = "ID of the management subnet"
  value       = aws_subnet.management.id
}

output "management_subnet_cidr" {
  description = "CIDR block of the management subnet"
  value       = aws_subnet.management.cidr_block
}

output "s3_vpc_endpoint_id" {
  description = "ID of the S3 VPC endpoint"
  value       = aws_vpc_endpoint.s3.id
}


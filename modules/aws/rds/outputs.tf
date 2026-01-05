output "db_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.main.id
}

output "db_instance_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.main.arn
}

output "db_instance_endpoint" {
  description = "RDS instance endpoint (hostname:port)"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_address" {
  description = "RDS instance hostname"
  value       = aws_db_instance.main.address
}

output "db_instance_port" {
  description = "RDS instance port"
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.main.db_name
}

output "db_username" {
  description = "Database master username"
  value       = aws_db_instance.main.username
  sensitive   = true
}

output "db_security_group_id" {
  description = "Security group ID for RDS"
  value       = aws_security_group.rds.id
}

output "db_subnet_group_name" {
  description = "DB subnet group name"
  value       = aws_db_subnet_group.main.name
}

output "rds_proxy_endpoint" {
  description = "RDS Proxy endpoint (if created)"
  value       = var.create_rds_proxy ? aws_db_proxy.main[0].endpoint : null
}

output "rds_proxy_arn" {
  description = "RDS Proxy ARN (if created)"
  value       = var.create_rds_proxy ? aws_db_proxy.main[0].arn : null
}

output "rds_proxy_secret_arn" {
  description = "Secrets Manager secret ARN for RDS Proxy (if created)"
  value       = var.create_rds_proxy ? aws_secretsmanager_secret.db_credentials[0].arn : null
}


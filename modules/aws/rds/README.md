# AWS RDS Module

Terraform module for creating AWS RDS instances with optional RDS Proxy support.

## Features

- PostgreSQL or MySQL database instances
- Private subnet deployment (recommended)
- Security group configuration
- Optional RDS Proxy for connection pooling
- Secrets Manager integration for credentials
- CloudWatch logging support
- Backup and maintenance window configuration

## Usage

### Basic RDS Instance

```hcl
module "rds" {
  source = "../../modules/aws/rds"

  db_instance_identifier = "my-app-db"
  vpc_id                 = module.vpc.vpc_id
  vpc_cidr              = "10.0.0.0/16"
  subnet_ids            = module.vpc.private_subnet_ids

  db_name     = "appdb"
  db_username = "appuser"
  db_password = "secure-password"

  resource_tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### RDS with Proxy

```hcl
module "rds" {
  source = "../../modules/aws/rds"

  db_instance_identifier = "my-app-db"
  vpc_id                 = module.vpc.vpc_id
  vpc_cidr              = "10.0.0.0/16"
  subnet_ids            = module.vpc.private_subnet_ids

  db_name     = "appdb"
  db_username = "appuser"
  db_password = "secure-password"

  create_rds_proxy = true

  resource_tags = {
    Environment = "production"
  }
}
```

### RDS with EKS Access

```hcl
module "rds" {
  source = "../../modules/aws/rds"

  db_instance_identifier = "my-app-db"
  vpc_id                 = module.vpc.vpc_id
  vpc_cidr              = "10.0.0.0/16"
  subnet_ids            = module.vpc.private_subnet_ids

  # Allow EKS nodes to access RDS
  allowed_security_group_ids = [module.eks_cluster.node_security_group_id]

  db_name     = "appdb"
  db_username = "appuser"
  db_password = "secure-password"

  resource_tags = {
    Environment = "production"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| db_instance_identifier | Identifier for the RDS instance | `string` | n/a | yes |
| vpc_id | VPC ID where RDS will be deployed | `string` | n/a | yes |
| vpc_cidr | CIDR block of the VPC | `string` | n/a | yes |
| subnet_ids | List of subnet IDs for DB subnet group | `list(string)` | n/a | yes |
| engine | Database engine | `string` | `"postgres"` | no |
| engine_version | Engine version | `string` | `"14.9"` | no |
| instance_class | RDS instance class | `string` | `"db.t3.micro"` | no |
| allocated_storage | Allocated storage in GB | `number` | `20` | no |
| db_name | Name of the database to create | `string` | `"appdb"` | no |
| db_username | Master username | `string` | `"appuser"` | no |
| db_password | Master password | `string` | n/a | yes |
| publicly_accessible | Make RDS publicly accessible | `bool` | `false` | no |
| create_rds_proxy | Create RDS Proxy | `bool` | `false` | no |
| allowed_security_group_ids | Security groups allowed to access RDS | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| db_instance_endpoint | RDS instance endpoint (hostname:port) |
| db_instance_address | RDS instance hostname |
| db_instance_port | RDS instance port |
| db_name | Database name |
| db_security_group_id | Security group ID for RDS |
| rds_proxy_endpoint | RDS Proxy endpoint (if created) |
| rds_proxy_arn | RDS Proxy ARN (if created) |

## RDS Proxy

RDS Proxy provides connection pooling and failover capabilities:

- **Connection Pooling**: Reuses database connections
- **Failover**: Automatic failover to standby instances
- **IAM Authentication**: Optional IAM-based authentication
- **Secrets Manager**: Automatic credential rotation

### When to Use RDS Proxy

- High connection count applications
- Serverless applications (Lambda)
- Need for connection pooling
- Automatic failover requirements

## Security Best Practices

1. **Private Subnets**: Deploy RDS in private subnets
2. **Security Groups**: Restrict access to specific security groups
3. **Encryption**: Enable storage encryption
4. **No Public Access**: Keep `publicly_accessible = false`
5. **Secrets Manager**: Use Secrets Manager for credentials (with RDS Proxy)

## Cost Considerations

- **db.t3.micro**: ~$15/month (smallest tier)
- **db.t3.small**: ~$30/month
- **Storage**: ~$0.10/GB/month (gp3)
- **RDS Proxy**: ~$15/month + connection charges

## Additional Resources

- [AWS RDS Documentation](https://docs.aws.amazon.com/rds/)
- [RDS Proxy Documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-proxy.html)
- [RDS Best Practices](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_BestPractices.html)


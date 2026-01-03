# ECR Module

## What is This?

This module creates a Docker container registry in Amazon Elastic Container Registry (ECR). ECR is AWS's service for storing and managing container images, similar to Docker Hub but integrated with AWS services.

## When to Use This Module

- Need to store container images for your applications
- Want images close to your EKS clusters (faster pulls, lower latency)
- Require integration with AWS IAM for access control
- Building CI/CD pipelines that push images

## What It Creates

- **ECR Repository**: A Docker registry where you can push/pull images
- **Lifecycle Policy** (optional): Automatic cleanup of old images
- **Repository Policy** (optional): Cross-account or custom access policies
- **IAM Policy** (optional): Grants EKS node role permission to pull images

## How It Works

```
Developer/CI
   │
   ▼
┌─────────────────────────────┐
│  docker push                │
│  <account>.dkr.ecr.         │
│  <region>.amazonaws.com/    │
│  <repo>:tag                 │
└─────────────────────────────┘
   │
   ▼
┌─────────────────────────────┐
│  ECR Repository             │
│  - Stores images            │
│  - Manages versions         │
│  - Handles access control   │
│  - Vulnerability scanning   │
└─────────────────────────────┘
   │
   ▼
┌─────────────────────────────┐
│  EKS Cluster                │
│  - Pulls images on demand   │
│  - Uses IAM for auth        │
└─────────────────────────────┘
```

## Usage

### Basic Example

```hcl
module "ecr" {
  source = "../../modules/aws/ecr"
  
  repository_name = "my-app"
}
```

### With EKS Node Role Integration

```hcl
module "ecr" {
  source = "../../modules/aws/ecr"
  
  repository_name    = "my-app"
  eks_node_role_arn  = module.eks_cluster.node_role_arn
  scan_on_push       = true
  image_tag_mutability = "IMMUTABLE"
}
```

### With Lifecycle Policy

```hcl
module "ecr" {
  source = "../../modules/aws/ecr"
  
  repository_name = "my-app"
  
  lifecycle_policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      selection = {
        tagStatus     = "any"
        countType     = "imageCountMoreThan"
        countNumber   = 10
      }
      action = {
        type = "expire"
      }
    }]
  })
}
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| repository_name | Name of the ECR repository | `string` | n/a (required) |
| image_tag_mutability | MUTABLE or IMMUTABLE | `string` | `"MUTABLE"` |
| scan_on_push | Scan images for vulnerabilities on push | `bool` | `true` |
| encryption_type | AES256 or KMS | `string` | `"AES256"` |
| eks_node_role_arn | EKS node role ARN for pull permissions | `string` | `null` |

## Outputs

| Name | Description |
|------|-------------|
| repository_url | Full URL for docker push/pull |
| repository_arn | ARN of the repository |
| registry_id | AWS account ID where repository was created |

## After Creation

### Authenticate Docker with ECR

```bash
aws ecr get-login-password --region <region> | \
  docker login --username AWS --password-stdin \
  <account>.dkr.ecr.<region>.amazonaws.com
```

### Push an Image

```bash
docker tag my-image:latest <repository_url>:latest
docker push <repository_url>:latest
```

## Differences from GCP Artifact Registry

| Feature | GCP Artifact Registry | AWS ECR |
|---------|----------------------|---------|
| **URL Format** | Global or regional | Regional |
| **IAM Integration** | GCP IAM | AWS IAM |
| **Vulnerability Scanning** | Built-in | Built-in (with pricing) |
| **Lifecycle Policies** | Similar | Similar |

## Cost Considerations

- **Storage**: $0.10/GB/month for image storage
- **Data Transfer**: Standard AWS data transfer pricing
- **Vulnerability Scanning**: First scan free, subsequent scans charged
- **API Requests**: Minimal charges for API calls

**Tip**: Use lifecycle policies to automatically clean up old images and reduce storage costs.

## Related Modules

- `eks-cluster` - EKS cluster that pulls images from this registry

## Learn More

- [ECR Documentation](https://docs.aws.amazon.com/ecr/)
- [ECR Best Practices](https://docs.aws.amazon.com/ecr/latest/userguide/best-practices.html)
- [ECR Pricing](https://aws.amazon.com/ecr/pricing/)


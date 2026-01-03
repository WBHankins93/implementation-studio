# EKS Cluster Module

## What is This?

This module creates a production-ready Amazon Elastic Kubernetes Service (EKS) cluster. EKS is AWS's managed Kubernetes service that provides a fully managed control plane for deploying, managing, and scaling containerized applications.

## When to Use This Module

- Deploying Kubernetes workloads on AWS
- Need a managed Kubernetes service (no master node management)
- Require integration with other AWS services
- Want production-ready defaults (encryption, logging, monitoring)
- Need to use AWS-native features (IAM Roles for Service Accounts, VPC CNI)

## What It Creates

- **EKS Cluster**: A Kubernetes cluster with a managed control plane
- **Node Group**: Worker nodes that run your workloads
- **IAM Roles**: Separate roles for cluster and nodes with appropriate permissions
- **KMS Key**: Encryption key for cluster secrets (optional, can use existing)
- **CloudWatch Log Group**: Centralized logging for cluster logs

## Features

- **Private Endpoint**: Optional private-only API endpoint for enhanced security
- **Encryption at Rest**: KMS encryption for cluster secrets
- **CloudWatch Logging**: Centralized logging for cluster operations
- **Auto-scaling**: Node group auto-scaling based on demand
- **Multiple Instance Types**: Support for ON_DEMAND and SPOT instances
- **VPC CNI**: Native VPC networking (better performance than overlay networks)
- **IRSA Ready**: IAM role outputs for IAM Roles for Service Accounts configuration

## How It Works

```
┌─────────────────────────────────────────────────┐
│              AWS Account                        │
│                                                 │
│  ┌──────────────────────────────────────────┐  │
│  │        EKS Control Plane                 │  │
│  │  (Managed by AWS, in AWS account)        │  │
│  └──────────────────────────────────────────┘  │
│                 │                               │
│                 │ Kubernetes API                │
│                 ▼                               │
│  ┌──────────────────────────────────────────┐  │
│  │         EKS Node Group                   │  │
│  │  ┌──────────┐  ┌──────────┐             │  │
│  │  │  Node 1  │  │  Node 2  │  ...        │  │
│  │  └──────────┘  └──────────┘             │  │
│  │  (In your VPC subnets)                   │  │
│  └──────────────────────────────────────────┘  │
│                                                 │
│  ┌──────────────────────────────────────────┐  │
│  │         IAM Roles                        │  │
│  │  - Cluster Role (EKS API)                │  │
│  │  - Node Role (EC2, ECR, etc.)            │  │
│  └──────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
```

1. Creates IAM roles for cluster and nodes with necessary permissions
2. Provisions the EKS cluster with your specified configuration
3. Creates a node group with your specified instance type and count
4. Configures auto-scaling, encryption, and logging
5. Sets up CloudWatch log group for cluster logs

## Usage

### Basic Example

```hcl
module "eks_cluster" {
  source = "../../modules/aws/eks-cluster"
  
  cluster_name = "my-eks-cluster"
  region       = "us-west-2"
  subnet_ids   = module.vpc.private_subnet_ids
  
  node_count     = 2
  instance_type  = "t3.medium"
  min_node_count = 1
  max_node_count = 5
}
```

### With Private Endpoint

```hcl
module "eks_cluster" {
  source = "../../modules/aws/eks-cluster"
  
  # ... other variables ...
  
  private_endpoint = true  # Cluster API only accessible from VPC
}
```

### With Custom Labels and Tags

```hcl
module "eks_cluster" {
  source = "../../modules/aws/eks-cluster"
  
  # ... other variables ...
  
  node_labels = {
    environment = "production"
    team        = "platform"
  }
  
  resource_tags = {
    Environment = "production"
    Team        = "platform"
    CostCenter  = "engineering"
  }
}
```

### With SPOT Instances (Cost Optimization)

```hcl
module "eks_cluster" {
  source = "../../modules/aws/eks-cluster"
  
  # ... other variables ...
  
  capacity_type = "SPOT"  # Use SPOT instances for cost savings
}
```

## Prerequisites

Before using this module, ensure:

1. **AWS Account**: Account with appropriate permissions
2. **IAM Permissions**: Your account needs:
   - `eks:CreateCluster`, `eks:DescribeCluster`, `eks:DeleteCluster`
   - `eks:CreateNodegroup`, `eks:DescribeNodegroup`, `eks:DeleteNodegroup`
   - `iam:CreateRole`, `iam:AttachRolePolicy`, `iam:CreateServiceLinkedRole`
   - `ec2:CreateSecurityGroup`, `ec2:CreateTags`
   - `kms:CreateKey` (if not providing existing KMS key)
3. **VPC Network**: A VPC with subnets must exist (use `vpc` module)
4. **AWS CLI**: Configured with credentials: `aws configure`
5. **kubectl**: Installed and configured
6. **aws-iam-authenticator** or **aws cli v2**: For kubectl authentication

## Inputs

See `variables.tf` for complete list. Key variables:

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| cluster_name | Name of the EKS cluster | `string` | n/a | yes |
| region | AWS region | `string` | n/a | yes |
| subnet_ids | List of subnet IDs for the cluster | `list(string)` | n/a | yes |
| private_endpoint | Enable private endpoint (private cluster) | `bool` | `false` | no |
| node_count | Desired number of nodes | `number` | `2` | no |
| instance_type | EC2 instance type for nodes | `string` | `"t3.medium"` | no |
| min_node_count | Minimum nodes for autoscaling | `number` | `1` | no |
| max_node_count | Maximum nodes for autoscaling | `number` | `3` | no |
| network_policy_enabled | Enable Kubernetes network policies | `bool` | `true` | no |
| kubernetes_version | Kubernetes version (null = latest) | `string` | `null` | no |
| capacity_type | ON_DEMAND or SPOT | `string` | `"ON_DEMAND"` | no |

## Outputs

| Name | Description | Usage |
|------|-------------|-------|
| cluster_name | Name of the created cluster | Use with `aws eks` commands |
| cluster_endpoint | Kubernetes API endpoint | For `kubectl` configuration |
| cluster_ca_certificate | Base64 encoded certificate | For `kubectl` configuration |
| cluster_id | ID of the cluster | For AWS API calls |
| cluster_arn | ARN of the cluster | For IAM policies |
| node_group_name | Name of the node group | For node group management |
| node_role_arn | IAM role ARN for nodes | For IRSA configuration |
| cluster_role_arn | IAM role ARN for cluster | For cluster management |

## After Creation

### Get Cluster Credentials

```bash
aws eks update-kubeconfig \
  --region <region> \
  --name <cluster_name>
```

### Verify Access

```bash
kubectl get nodes
kubectl get pods --all-namespaces
```

### Configure IAM Roles for Service Accounts (IRSA)

After cluster creation, you can configure IRSA using the `node_role_arn` output:

```bash
# Example: Create OIDC provider for IRSA
eksctl utils associate-iam-oidc-provider \
  --cluster <cluster_name> \
  --region <region> \
  --approve
```

## Cost Considerations

- **Cluster Management**: $0.10/hour per cluster (managed control plane)
- **Nodes**: ~$0.05/hour per t3.medium node (varies by instance type)
- **Data Transfer**: Standard AWS data transfer pricing
- **Load Balancers**: ~$0.0225/hour per ALB (if using AWS Load Balancer Controller)
- **Storage**: EBS volumes for persistent volumes (varies by size/type)

**Tip**: Use SPOT instances for development/test (`capacity_type = "SPOT"`) - can save up to 90% on compute costs

## Differences from GCP GKE

| Feature | GCP GKE | AWS EKS |
|---------|---------|---------|
| **Control Plane Cost** | Free | $0.10/hour |
| **Networking** | VPC-native (automatic) | VPC CNI (automatic, but more configurable) |
| **IAM Integration** | Workload Identity | IRSA (IAM Roles for Service Accounts) |
| **Node Management** | Node pools | Node groups |
| **Auto-scaling** | Built-in | Cluster Autoscaler addon |
| **Encryption** | Optional | Required (at rest for secrets) |

## Troubleshooting

### Cluster Creation Fails

- Check IAM permissions (cluster and node roles)
- Verify VPC/subnets exist and are in correct AZs
- Ensure service-linked role exists: `aws iam get-role --role-name AWSServiceRoleForAmazonEKS`
- Check AWS service quotas

### Cannot Connect to Cluster

- Verify AWS credentials: `aws sts get-caller-identity`
- Check kubeconfig is updated: `aws eks update-kubeconfig --region <region> --name <cluster_name>`
- For private clusters, ensure you're on the VPC network or using VPN/bastion
- Verify security groups allow necessary traffic

### Nodes Not Joining

- Check node IAM role permissions
- Verify subnet route tables allow cluster communication
- Check security groups allow node-to-cluster and node-to-node traffic
- Verify VPC CNI addon is installed (if using network policies)

### Pods Stuck in Pending

- Check node capacity: `kubectl describe nodes`
- Verify node labels match pod node selectors
- Check taints/tolerations
- Verify persistent volume claims can be bound

## Related Modules

- `vpc` - Creates the VPC network and subnets this cluster uses
- `ecr` - Container registry for images
- `security-groups` - Network security for cluster traffic

## Learn More

- [EKS Documentation](https://docs.aws.amazon.com/eks/)
- [EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [EKS Pricing](https://aws.amazon.com/eks/pricing/)
- [VPC CNI Plugin](https://github.com/aws/amazon-vpc-cni-k8s)
- [IRSA Documentation](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)


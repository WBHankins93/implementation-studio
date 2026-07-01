# Implementation Studio Modules

This directory contains reusable infrastructure and Kubernetes building blocks used by the labs and intended to be adaptable for real implementation work.

## Catalog

### GCP Terraform Modules

| Module | Purpose |
| --- | --- |
| [artifact-registry](gcp/artifact-registry/README.md) | Google Artifact Registry repository for container images |
| [firewall-rules](gcp/firewall-rules/README.md) | Common GCP firewall patterns for restricted environments |
| [gke-cluster](gcp/gke-cluster/README.md) | GKE cluster module for standard and private deployments |
| [vpc-private](gcp/vpc-private/README.md) | Private GCP network baseline |
| [vpc-standard](gcp/vpc-standard/README.md) | Standard GCP VPC with public/private subnet patterns |

### AWS Terraform Modules

| Module | Purpose |
| --- | --- |
| [ecr](aws/ecr/README.md) | Elastic Container Registry repository |
| [eks-cluster](aws/eks-cluster/README.md) | EKS cluster module for standard and private deployments |
| [rds](aws/rds/README.md) | Relational database module with production-oriented options |
| [security-groups](aws/security-groups/README.md) | Security group patterns for EKS and restricted egress |
| [vpc](aws/vpc/README.md) | Standard AWS VPC with public/private subnet patterns |
| [vpc-private](aws/vpc-private/README.md) | Private AWS network baseline with endpoint-oriented design |

### Kubernetes Pattern Bundles

| Bundle | Purpose |
| --- | --- |
| [argo-workflows](kubernetes/argo-workflows/README.md) | Standard Argo Workflows Helm values |
| [argo-workflows-airgap](kubernetes/argo-workflows-airgap/README.md) | Offline-friendly Argo Workflows values, images list, and chart packaging |
| [ingress-nginx](kubernetes/ingress-nginx/README.md) | Public ingress-nginx values |
| [network-policies](kubernetes/network-policies/README.md) | Deny-all, ingress, DNS egress, and namespace isolation policies |
| [rbac-patterns](kubernetes/rbac-patterns/README.md) | Namespace admin, read-only, and deployment-only RBAC templates |
| [resource-quotas](kubernetes/resource-quotas/README.md) | Standard and limited quota profiles for tenant isolation |

## Provider Equivalents

| Capability | GCP | AWS | Kubernetes |
| --- | --- | --- | --- |
| Kubernetes cluster | `gke-cluster` | `eks-cluster` | `argo-workflows` deploys onto either |
| Standard network | `vpc-standard` | `vpc` | Network policies refine in-cluster behavior |
| Private network | `vpc-private` | `vpc-private` | Internal access patterns live in labs |
| Container registry | `artifact-registry` | `ecr` | Air-gap packaging supports offline registry use |
| Egress/security controls | `firewall-rules` | `security-groups` | `network-policies` |
| Tenant controls | Provider IAM plus cluster config | Provider IAM plus cluster config | `rbac-patterns`, `resource-quotas`, `network-policies` |

## Usage

Use modules from a lab or copy them into your own Terraform project.

```hcl
module "vpc" {
  source = "../../modules/gcp/vpc-standard"

  project_id = var.project_id
  region     = var.region
  name       = var.network_name
}

module "cluster" {
  source = "../../modules/gcp/gke-cluster"

  project_id  = var.project_id
  region      = var.region
  network     = module.vpc.network_name
  subnetwork  = module.vpc.private_subnet_name
  cluster_name = var.cluster_name
}
```

For AWS, use the matching AWS module family:

```hcl
module "vpc" {
  source = "../../modules/aws/vpc"

  region = var.region
  name   = var.network_name
}

module "cluster" {
  source = "../../modules/aws/eks-cluster"

  cluster_name = var.cluster_name
  subnet_ids   = module.vpc.private_subnet_ids
}
```

## Validation

Run these checks before changing modules:

```bash
terraform fmt -check -recursive
tools/validate-terraform.sh
tools/validate-modules.sh
```

The GitHub Actions workflow also runs Terraform format, init, validate, and tflint checks on Terraform changes.

## Module Standards

Every Terraform module should include:

- `main.tf`, `variables.tf`, `outputs.tf`, and `versions.tf`.
- A README with purpose, usage, inputs, outputs, and provider notes.
- Typed variables with descriptions and sensible defaults when safe.
- Outputs that support composition by labs and downstream projects.
- No environment-specific hardcoding unless the README explains why.

Every Kubernetes pattern bundle should include:

- A README that explains when to use the pattern.
- Manifests or Helm values that can be copied into labs.
- Security and production notes where the pattern changes risk posture.

## Related Documentation

- [Provider Comparison](../docs/02-multi-cloud/provider-comparison.md)
- [Feature Parity Matrix](../docs/02-multi-cloud/feature-parity-matrix.md)
- [Migration Guide](../docs/02-multi-cloud/migration-guide.md)
- [Module Maintenance](../docs/03-project-management/module-maintenance.md)

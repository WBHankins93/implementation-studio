# Validation Status

## Components

| Component | Validation Method | Status | Notes |
|-----------|------------------|--------|-------|
| Kubernetes manifests | kubeval, dry-run | ✅ Validated | All manifests validated locally |
| Helm charts | helm template | ✅ Validated | Charts render successfully |
| Terraform modules | terraform validate | ✅ Validated | All modules pass validation (GCP and AWS) |
| Terraform plan (GCP) | terraform plan | ⚠️ Reviewed | Requires GCP credentials |
| Terraform plan (AWS) | terraform plan | ⚠️ Reviewed | Requires AWS credentials |
| GCP resources | Requires deployment | ⚠️ Reviewed | Not deployed to GCP |
| AWS resources | Requires deployment | ⚠️ Reviewed | Not deployed to AWS |

## Multi-Cloud Support

This lab supports both **GCP** and **AWS** providers. Validation status applies to both providers unless otherwise noted.

### Provider-Specific Validation

**GCP (GKE):**
- ✅ Terraform modules validated
- ✅ Kubernetes manifests validated
- ⚠️ Requires GCP deployment for full validation

**AWS (EKS):**
- ✅ Terraform modules validated
- ✅ Kubernetes manifests validated
- ⚠️ Requires AWS deployment for full validation

## How to Validate

### Local Validation

```bash
# Validate Terraform (works for both providers)
cd labs/01-standard-deployment
terraform init
terraform validate
terraform fmt -check

# Validate with specific provider
# Set cloud_provider in terraform.tfvars, then:
terraform init
terraform validate
terraform plan  # Requires provider credentials

# Validate Kubernetes manifests
kubectl apply --dry-run=client -f manifests/

# Validate Helm charts
helm template argo-workflows argo/argo-workflows \
  -f ../../modules/kubernetes/argo-workflows/helm-values.yaml

helm template ingress-nginx ingress-nginx/ingress-nginx \
  -f ../../modules/kubernetes/ingress-nginx/helm-values.yaml
```

### Cloud Validation

#### GCP Validation

```bash
# Requires GCP project and credentials
cd labs/01-standard-deployment

# Set cloud_provider = "gcp" in terraform.tfvars
terraform plan
terraform apply
./scripts/deploy-argo.sh
./scripts/validate.sh
```

#### AWS Validation

```bash
# Requires AWS account and credentials
cd labs/01-standard-deployment

# Set cloud_provider = "aws" in terraform.tfvars
terraform plan
terraform apply
./scripts/deploy-argo.sh
./scripts/validate.sh
```

## Community Validation

If you've deployed this lab successfully, please:

1. Open an issue confirming successful deployment
2. Note your:
   - Cloud provider (GCP or AWS)
   - Region
   - Any modifications made
3. Update this file via PR if appropriate

### Community Validation Results

- **GCP:** ⏳ Awaiting community validation
- **AWS:** ⏳ Awaiting community validation

## Status Legend

- ✅ Validated - Tested and confirmed working
- ⏳ Pending - Not yet validated
- ⚠️ Reviewed - Code reviewed but not deployed
- ❌ Failed - Validation failed (see notes)

## Known Issues

None at this time. If you encounter issues, please open a GitHub issue with:
- Provider (GCP or AWS)
- Error messages
- Relevant logs
- Region/zone information

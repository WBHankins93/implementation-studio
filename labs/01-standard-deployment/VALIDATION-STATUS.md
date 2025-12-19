# Validation Status

## Components

| Component | Validation Method | Status | Notes |
|-----------|------------------|--------|-------|
| Kubernetes manifests | kubeval, dry-run | ✅ Validated | All manifests validated locally |
| Helm charts | helm template | ✅ Validated | Charts render successfully |
| Terraform modules | terraform validate | ✅ Validated | All modules pass validation |
| Terraform plan | terraform plan | ⚠️ Reviewed | Requires GCP credentials |
| GCP resources | Requires deployment | ⚠️ Reviewed | Not deployed to GCP |

## How to Validate

### Local Validation

```bash
# Validate Terraform
cd labs/01-standard-deployment
terraform init
terraform validate
terraform fmt -check

# Validate Kubernetes manifests
kubectl apply --dry-run=client -f manifests/

# Validate Helm charts
helm template argo-workflows argo/argo-workflows \
  -f ../../modules/kubernetes/argo-workflows/helm-values.yaml
```

### Cloud Validation

```bash
# Requires GCP project and credentials
cd labs/01-standard-deployment
terraform plan
terraform apply
./scripts/deploy-argo.sh
./scripts/validate.sh
```

## Community Validation

If you've deployed this lab successfully, please:

1. Open an issue confirming successful deployment
2. Note your GCP region and any modifications made
3. Update this file via PR if appropriate

## Status Legend

- ✅ Validated - Tested and confirmed working
- ⏳ Pending - Not yet validated
- ⚠️ Reviewed - Code reviewed but not deployed
- ❌ Failed - Validation failed (see notes)


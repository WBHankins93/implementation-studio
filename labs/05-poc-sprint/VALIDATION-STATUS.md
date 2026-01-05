# Validation Status

## Components

| Component | Validation Method | Status | Notes |
|-----------|------------------|--------|-------|
| Terraform configuration (GCP) | terraform validate | ✅ Validated | Minimal deployment validated |
| Terraform configuration (AWS) | terraform validate | ✅ Validated | Minimal deployment validated |
| Kubernetes manifests | kubectl apply --dry-run | ✅ Validated | Demo workflows validated |
| Helm charts | helm template | ✅ Validated | Charts render successfully |
| Templates | Manual review | ✅ Validated | All templates reviewed |
| Demo materials | Manual review | ✅ Validated | Demo scripts and guides reviewed |
| Scripts | Manual testing | ✅ Validated | Scripts tested locally (Kind, GCP, AWS) |

## Multi-Cloud Support

This lab supports **three deployment options**:

1. **Kind (Local)** - Zero cost, fastest deployment
2. **GCP (GKE)** - Cloud deployment for GCP environments
3. **AWS (EKS)** - Cloud deployment for AWS environments

The `quick-deploy.sh` script automatically detects and supports all three options.

## How to Validate

### Local Validation

```bash
# Validate Terraform
cd labs/05-poc-sprint/minimal-deployment
terraform init
terraform validate
terraform fmt -check

# Validate Kubernetes manifests
kubectl apply --dry-run=client -f manifests/

# Validate Helm charts
helm template argo-workflows argo/argo-workflows \
  --values ../../modules/kubernetes/argo-workflows/helm-values.yaml
```

### Cloud Validation (GCP)

```bash
# Deploy to GCP
cd labs/05-poc-sprint/minimal-deployment
cp terraform.tfvars.example terraform.tfvars
# Set cloud_provider = "gcp" and configure GCP settings
cd ..
./scripts/quick-deploy.sh
```

### Cloud Validation (AWS)

```bash
# Deploy to AWS
cd labs/05-poc-sprint/minimal-deployment
cp terraform.tfvars.example terraform.tfvars
# Set cloud_provider = "aws" and configure AWS settings
cd ..
./scripts/quick-deploy.sh
```

### Local Validation (Kind)

```bash
# Deploy with Kind (no terraform.tfvars needed)
cd labs/05-poc-sprint
./scripts/quick-deploy.sh
# Script will automatically use Kind if no terraform.tfvars exists
```

### Template Validation

Templates are validated through:
- Manual review
- Real-world usage
- Best practices alignment

## Provider-Specific Validation

### Kind (Local)
- ✅ **Cluster Creation:** Validated via Kind
- ✅ **Argo Workflows:** Validated via Helm
- ✅ **Demo Workflows:** Validated via kubectl

### GCP (GKE)
- ✅ **Terraform Configuration:** Validated
- ✅ **GKE Cluster:** Requires deployment to test
- ✅ **Argo Workflows:** Validated via Helm

### AWS (EKS)
- ✅ **Terraform Configuration:** Validated
- ✅ **EKS Cluster:** Requires deployment to test
- ✅ **Argo Workflows:** Validated via Helm

## Community Validation

If you've used these templates or completed this lab, please:

1. Open an issue sharing your experience
2. Note which deployment option you used (Kind, GCP, or AWS)
3. Note any improvements to templates
4. Share lessons learned
5. Update this file via PR if appropriate

### Community Validation Results

- **Kind:** ⏳ Awaiting community validation
- **GCP:** ⏳ Awaiting community validation
- **AWS:** ⏳ Awaiting community validation

## Status Legend

- ✅ Validated - Tested and confirmed working
- ⏳ Pending - Not yet validated
- ⚠️ Reviewed - Code reviewed but not deployed
- ❌ Failed - Validation failed (see notes)

## Notes

This lab focuses on process and templates rather than infrastructure validation. The infrastructure components (Terraform, Kubernetes) are validated, but the primary value is in the POC process templates and guides.

**Deployment Options:**
- **Kind:** Perfect for learning and zero-cost POCs
- **GCP/AWS:** For real cloud environment POCs
- All options use the same Kubernetes application layer (Argo Workflows)

# Testing Strategy

Implementation Studio uses a transparent, multi-layered testing strategy that acknowledges what can be tested locally versus what requires cloud deployment.

## Testing Philosophy

### Transparency First

Every lab includes a `VALIDATION-STATUS.md` file that clearly states:
- What has been tested
- How it was tested
- What requires cloud deployment
- What the community can help validate

### Local-First Where Possible

We prioritize content that can be validated locally:
- Kubernetes manifests
- Network policies
- RBAC configurations
- Air-gapped deployments (fully local)
- Multi-tenant isolation

### Honest About Cloud Requirements

We're transparent about what requires GCP:
- VPC creation
- GKE cluster provisioning
- Load balancers
- IAM bindings

## What Can Be Tested Locally

### Fully Local (Kind/Minikube)

These components can be fully validated without cloud access:

- **Kubernetes Manifests**
  - `kubectl apply --dry-run=client` (client-side validation)
  - `kubectl apply --dry-run=server` (server-side validation with cluster)
  - `kubeval` (schema validation)

- **Helm Charts**
  - `helm template` (render without deploying)
  - `helm lint` (chart validation)

- **Kustomize Overlays**
  - `kustomize build` (validate overlays)

- **Network Policies**
  - Deploy to Kind cluster
  - Test isolation between namespaces

- **RBAC Configurations**
  - Test with `kubectl auth can-i`
  - Validate in Kind cluster

- **Argo Workflows**
  - Full installation and execution in Kind
  - Workflow submission and execution

- **Air-Gapped Deployment**
  - This IS the target environment (fully local)

- **Multi-Tenant Isolation**
  - Namespace isolation
  - Resource quotas
  - Network policies

### Tools for Local Validation

```bash
# Kubernetes manifest validation
kubeval manifests/*.yaml

# Helm chart validation
helm template . | kubeval

# Kustomize validation
kustomize build . | kubeval

# Dry-run deployment
kubectl apply --dry-run=client -f manifests/

# Kind cluster for testing
kind create cluster --config kind-config.yaml
```

## What Requires Cloud Deployment

### GCP-Specific Resources

These require actual GCP deployment:

- **VPC Creation**
  - Subnet configuration
  - NAT gateway setup
  - Route tables

- **GKE Cluster Provisioning**
  - Cluster creation
  - Node pool configuration
  - Private cluster setup

- **IAM Bindings**
  - Service account creation
  - Role bindings
  - Workload identity

- **Load Balancers**
  - Ingress controller setup
  - External IP allocation
  - Health checks

- **Private Service Connect**
  - Private endpoint configuration
  - DNS resolution

- **Cloud SQL Connectivity**
  - Database proxy setup
  - Connection testing

### Terraform Validation

Even without deploying, we can validate:

```bash
# Format checking
terraform fmt -check

# Syntax validation
terraform validate

# Linting
tflint

# Planning (requires credentials but doesn't deploy)
terraform plan
```

## Validation Status Documentation

Each lab includes `VALIDATION-STATUS.md`:

```markdown
# Validation Status

## Components

| Component | Validation Method | Status | Notes |
|-----------|------------------|--------|-------|
| Kubernetes manifests | kubeval, dry-run | ✅ Validated | |
| Helm charts | helm template | ✅ Validated | |
| Network policies | Kind deployment | ✅ Validated | |
| Terraform modules | terraform validate | ✅ Validated | |
| GCP resources | Requires deployment | ⚠️ Reviewed | Not deployed to GCP |

## How to Validate

### Local Validation
./scripts/validate-local.sh

### Cloud Validation
# Requires GCP project and credentials
./scripts/validate-cloud.sh

## Community Validation

If you've deployed this lab successfully, please:
1. Open an issue confirming successful deployment
2. Note your GCP region and any modifications made
3. Update this file via PR if appropriate
```

## Validation Scripts

Each lab includes validation scripts:

- **validate-local.sh** - Runs all local validation checks
- **validate-cloud.sh** - Runs cloud-specific validation (requires GCP)

## Community Validation

We encourage the community to:

1. Deploy labs to GCP and report success
2. Note any issues or modifications needed
3. Update `VALIDATION-STATUS.md` via PR
4. Share region-specific findings

This creates a living validation record that helps others.

## CI/CD Validation

GitHub Actions workflows validate:

- Terraform formatting and syntax
- Kubernetes manifest validation
- Markdown linting
- Shell script syntax

See `.github/workflows/` for validation pipelines.

---

This transparent approach ensures users know what to expect and can contribute to validation efforts.


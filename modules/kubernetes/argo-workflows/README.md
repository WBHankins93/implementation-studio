# Argo Workflows Module

Standard Argo Workflows deployment for Kubernetes clusters.

## Purpose

Deploys Argo Workflows with:
- Helm-based installation
- Configurable namespace
- Ingress configuration (optional)
- RBAC setup
- Resource limits

## Usage

### Terraform (using Helm provider)

```hcl
module "argo_workflows" {
  source = "../../modules/kubernetes/argo-workflows"
  
  namespace = "argo"
  ingress_enabled = true
}
```

### Direct Helm Installation

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm install argo-workflows argo/argo-workflows \
  -f modules/kubernetes/argo-workflows/helm-values.yaml \
  -n argo --create-namespace
```

## Files

- `helm-values.yaml` - Helm chart values
- `kustomization.yaml` - Kustomize overlay (if needed)
- `README.md` - This file

## Requirements

- Kubernetes cluster (1.20+)
- Helm 3.x
- kubectl configured

## Status

⏳ Module in development


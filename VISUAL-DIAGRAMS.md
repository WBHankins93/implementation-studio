# Visual Diagrams

These diagrams are designed for quick orientation: which path to choose, how the pieces connect, and what evidence to collect before calling a deployment ready.

## Scenario Router

```mermaid
flowchart TD
  A[Customer environment constraint] --> B{What is blocked?}
  B -->|No internet| C[Lab 02 Air-Gapped]
  B -->|No public control plane| D[Lab 03 Private Network]
  B -->|Strict outbound controls| E[Lab 04 Firewall-Restricted]
  B -->|Shared platform boundaries| F[Lab 06 Multi-Tenant]
  B -->|External systems| G[Lab 07 Integration Patterns]
  B -->|Operational ownership| H[Lab 08 Handoff and Runbooks]
  B -->|Failure diagnosis| I[Lab 09 Troubleshooting]
  C --> J[Validation status]
  D --> J
  E --> J
  F --> J
  G --> J
  H --> J
  I --> J
```

## Implementation Flow

```mermaid
flowchart LR
  discovery[Discovery and constraints] --> select[Select lab and provider]
  select --> modules[Choose modules and manifests]
  modules --> deploy[Deploy infrastructure and Argo Workflows]
  deploy --> validate[Validate local and cloud behavior]
  validate --> handoff[Runbooks, training, and support handoff]
```

## Module Map

```mermaid
flowchart TB
  subgraph GCP
    gcpvpc[VPC Standard / Private]
    gke[GKE Cluster]
    gar[Artifact Registry]
    gfw[Firewall Rules]
  end

  subgraph AWS
    awsvpc[VPC / Private VPC]
    eks[EKS Cluster]
    ecr[ECR]
    rds[RDS and RDS Proxy]
    sg[Security Groups]
  end

  subgraph Kubernetes
    argo[Argo Workflows]
    netpol[Network Policies]
    rbac[RBAC Patterns]
    quota[Resource Quotas]
    ingress[Ingress NGINX]
  end

  gcpvpc --> gke --> argo
  gar --> argo
  gfw --> gke
  awsvpc --> eks --> argo
  ecr --> argo
  sg --> eks
  rds --> eks
  netpol --> argo
  rbac --> argo
  quota --> argo
  ingress --> argo
```

## Validation Ladder

```mermaid
flowchart TD
  A[Static checks] --> B[Local cluster checks]
  B --> C[Cloud syntax and provider validation]
  C --> D[Real account deployment]
  D --> E[Customer-specific controls]

  A1[terraform fmt, terraform validate, shell syntax, markdown links] -.-> A
  B1[Kind labs, manifests, workflows, troubleshooting scenarios] -.-> B
  C1[GCP/AWS module validation and provider-specific plans] -.-> C
  D1[IAM, quotas, regions, endpoint behavior, load balancers] -.-> D
  E1[Compliance, firewall approvals, SSO, support ownership] -.-> E
```

## Series Positioning

```mermaid
flowchart LR
  SP[Solutions Playbook<br/>customer motions and field guides]
  AI[AI Engineering Studio<br/>AI systems and POCs]
  DO[DevOps Studio<br/>platform and operations curriculum]
  IS[Implementation Studio<br/>constrained deployments and handoff]

  SP --> IS
  AI --> IS
  DO --> IS
  IS --> SP
```

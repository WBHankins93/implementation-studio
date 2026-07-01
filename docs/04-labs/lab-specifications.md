# Lab Specifications

Detailed specifications for all 9 labs in Implementation Studio.

## Multi-Cloud Support

Implementation Studio supports **multi-cloud deployments** for most labs:

- **GCP (GKE)** - Google Kubernetes Engine
- **AWS (EKS)** - Amazon Elastic Kubernetes Service
- **Kind** - Local Kubernetes (for labs that support it)

See [Provider Comparison Guide](../02-multi-cloud/provider-comparison.md) for detailed technical comparisons.

---

## Lab 01: Standard Deployment ✅

**Status:** Complete (Multi-Cloud: GCP ✅ | AWS ✅)  
**Time:** 1-2 hours | **Cost:** GCP $5-10 | AWS $8-15

**Learning Objectives:**
- Deploy a production-ready Kubernetes cluster with proper networking
- Install and configure Argo Workflows
- Set up ingress with TLS termination
- Implement basic monitoring and logging
- Understand the baseline that all other labs modify

**What Gets Deployed:**
- **GCP:** VPC with public and private subnets, GKE cluster, Artifact Registry
- **AWS:** VPC with public and private subnets, EKS cluster, ECR
- Argo Workflows with UI exposed via ingress
- Ingress-nginx controller
- Sample workflows demonstrating the reference application

**Prerequisites:**
- **GCP:** GCP project with billing enabled, `gcloud` CLI configured
- **AWS:** AWS account with appropriate permissions, `aws` CLI configured
- Terraform >= 1.5
- kubectl
- Helm 3

**Validation Status:** Kubernetes manifests testable locally; cloud infrastructure requires deployment

[View Lab 01 →](../../labs/01-standard-deployment/README.md)

---

## Lab 02: Air-Gapped Deployment ✅

**Status:** Complete (Kind-only, no cloud options)  
**Time:** 2-3 hours | **Cost:** $0 (fully local)

**Learning Objectives:**
- Understand what "air-gapped" means in practice
- Mirror container images to a private registry
- Package Helm charts for offline installation
- Deploy to a cluster with no internet access
- Plan update/patch strategies for isolated environments

**What Gets Deployed:**
- Kind cluster configured to simulate air-gap (no external network)
- Local container registry
- Argo Workflows from local images
- Sample workflows using local registry

**Key Techniques:**
- `docker save` / `docker load` for image transfer
- `helm pull` / `helm push` for chart packaging
- Registry mirroring strategies
- Manifest modification for private registries

**Prerequisites:**
- Docker
- Kind
- Helm 3
- kubectl
- ~10GB disk space for images

**Why Kind-Only:** True air-gapped environments have no internet AND no cloud connectivity. While you could technically simulate air-gap with private clusters + network policies, it would be confusing and not representative of real air-gapped scenarios. Kind provides perfect simulation without cloud costs.

**Validation Status:** Fully testable locally - this IS the target environment

[View Lab 02 →](../../labs/02-airgapped-deployment/README.md)

---

## Lab 03: Private Network Deployment ✅

**Status:** Complete (Multi-Cloud: GCP ✅ | AWS ✅)  
**Time:** 2-3 hours | **Cost:** GCP $8-15 | AWS $10-18

**Learning Objectives:**
- Deploy Kubernetes with private cluster configuration
- Configure private service access (Private Google Access / VPC Endpoints)
- Set up bastion host for cluster access
- Implement internal-only load balancers
- Understand VPN/Interconnect patterns (conceptual)

**What Gets Deployed:**
- **GCP:** Private VPC, Private GKE cluster, Bastion host (gcloud SSH)
- **AWS:** Private VPC, Private EKS cluster, Bastion host (SSH/SSM)
- Internal ingress controller
- Argo Workflows accessible only from within VPC

**Prerequisites:**
- Same as Lab 01 (provider-specific)
- Understanding of Lab 01 baseline

**Validation Status:** Kubernetes manifests testable locally; cloud infrastructure requires deployment

[View Lab 03 →](../../labs/03-private-network-deployment/README.md)

---

## Lab 04: Firewall-Restricted Deployment ✅

**Status:** Complete (Multi-Cloud: GCP ✅ | AWS ✅)  
**Time:** 2-3 hours | **Cost:** GCP $5-10 | AWS $8-15

**Learning Objectives:**
- Work within strict egress firewall rules / security groups
- Identify and document required external endpoints
- Configure applications to work through proxies
- Communicate requirements to customer security teams
- Implement allowlist-based network policies

**What Gets Deployed:**
- **GCP:** GKE cluster with strict egress firewall rules, Squid proxy VM
- **AWS:** EKS cluster with strict egress security groups, Squid proxy EC2
- Network policies enforcing egress restrictions
- Argo Workflows configured for proxy usage

**Key Techniques:**
- HTTP_PROXY / HTTPS_PROXY configuration
- Network policy egress rules
- Firewall rule / security group documentation
- Working with customer security teams (process documentation)

**Key Differences:**
- **GCP:** Firewall rules (network-level, can deny)
- **AWS:** Security groups (instance-level, allow-only)

**Validation Status:** Network policies testable locally; cloud firewall/security groups require deployment

[View Lab 04 →](../../labs/04-firewall-restricted-deployment/README.md)

---

## Lab 05: The POC Sprint ✅

**Status:** Complete (Multi-Cloud: GCP ✅ | AWS ✅ | Kind ✅)  
**Time:** 1-2 hours (deployment) + templates | **Cost:** Kind $0 | GCP $0-5 | AWS $0-5

**Learning Objectives:**
- Scope a time-boxed proof of concept
- Define measurable success criteria
- Deploy minimal viable infrastructure quickly
- Prepare and deliver effective demos
- Document outcomes for stakeholders

**What Gets Deployed:**
- **Kind:** Local cluster (fastest, zero cost) - Recommended
- **GCP:** Minimal GKE cluster
- **AWS:** Minimal EKS cluster
- Argo Workflows with pre-configured demo workflows
- Demo script and presentation materials

**Key Deliverables:**
- POC scope document template
- Success criteria framework
- Demo script and backup plan
- Final report template

**Validation Status:** Fully testable - templates and all deployment options

[View Lab 05 →](../../labs/05-poc-sprint/README.md)

---

## Lab 06: Multi-Tenant Deployment ✅

**Status:** Complete (Multi-Cloud: GCP ✅ | AWS ✅ | Kind ✅)  
**Time:** 2-3 hours | **Cost:** Kind $0 | GCP $0-10 | AWS $0-10

**Learning Objectives:**
- Implement namespace-based tenant isolation
- Configure RBAC for tenant separation
- Set up resource quotas per tenant
- Implement network policies for tenant isolation
- Manage tenant lifecycle (onboarding, offboarding)

**What Gets Deployed:**
- **Kind/GCP/AWS:** Kubernetes cluster (choose based on preference)
- Multiple tenant namespaces
- Tenant-specific RBAC, quotas, network policies
- Shared services namespace
- Argo Workflows per tenant

**Key Techniques:**
- Namespace isolation strategies
- NetworkPolicy for tenant separation
- ResourceQuota and LimitRange
- RBAC scoping

**Validation Status:** Fully testable locally with Kind; cloud options available

[View Lab 06 →](../../labs/06-multi-tenant-deployment/README.md)

---

## Lab 07: Integration Patterns ✅

**Status:** Complete (Multi-Cloud: GCP ✅ | AWS ✅)  
**Time:** 3-4 hours | **Cost:** GCP $10-20 | AWS $12-25

**Learning Objectives:**
- Integrate with external authentication (OAuth, SAML)
- Connect to external databases securely
- Configure API gateway patterns
- Understand service mesh basics for external traffic

**What Gets Deployed:**
- **GCP:** GKE cluster, Cloud SQL (optional), Cloud SQL Proxy
- **AWS:** EKS cluster, RDS (optional), RDS Proxy (optional)
- OAuth2-proxy for authentication (cloud-agnostic)
- Database proxy for secure connectivity
- Example API gateway configuration (Kong - cloud-agnostic)

**Key Techniques:**
- OAuth2/OIDC integration
- Secure database connectivity
- API gateway patterns
- Service mesh traffic management (Istio basics)

**Key Differences:**
- **GCP:** Cloud SQL Proxy (Kubernetes pod)
- **AWS:** RDS Proxy (managed service with connection pooling)

**Validation Status:** Some patterns testable locally; cloud services require deployment

[View Lab 07 →](../../labs/07-integration-patterns/README.md)

---

## Lab 08: Handoff and Runbooks ✅

**Status:** Complete (Cloud-Agnostic)  
**Time:** 2-3 hours | **Cost:** $0-5

**Learning Objectives:**
- Create production-ready documentation
- Set up monitoring dashboards
- Configure alerting rules
- Develop training materials for customer teams
- Execute knowledge transfer

**What Gets Deployed:**
- Prometheus + Grafana stack (cloud-agnostic)
- Pre-built dashboards for Argo Workflows
- Alerting rules for common issues
- Documentation templates

**Key Deliverables:**
- Deployment runbook template
- Incident response playbook
- Grafana dashboard JSON files
- Training agenda and exercises
- Handoff checklist

**Validation Status:** Dashboards and rules testable locally; full stack testable in Kind or cloud

[View Lab 08 →](../../labs/08-handoff-runbooks/README.md)

---

## Lab 09: Troubleshooting Scenarios ✅

**Status:** Complete (Cloud-Agnostic)  
**Time:** 2-4 hours (all scenarios) | **Cost:** $0 (fully local)

**Learning Objectives:**
- Diagnose common deployment failures systematically
- Use diagnostic tools effectively
- Document and communicate issues clearly
- Build pattern recognition for common problems

**Scenarios Covered:**
1. Network connectivity failures
2. Resource exhaustion (CPU, memory, disk)
3. Permission denied errors
4. Image pull failures
5. DNS resolution issues
6. Certificate/TLS problems

**What Gets Deployed:**
- Kind cluster
- Scripts that intentionally create each problem
- Diagnostic tool collection

**Key Techniques:**
- Systematic debugging methodology
- kubectl debug commands
- Log analysis
- Network troubleshooting

**Validation Status:** Fully testable locally

[View Lab 09 →](../../labs/09-troubleshooting-scenarios/README.md)

---

## Lab Support Matrix

| Lab | GCP | AWS | Kind | Notes |
|-----|-----|-----|------|-------|
| **Lab 01** | ✅ | ✅ | ❌ | Standard deployment |
| **Lab 02** | ❌ | ❌ | ✅ | Air-gapped (Kind-only) |
| **Lab 03** | ✅ | ✅ | ❌ | Private network |
| **Lab 04** | ✅ | ✅ | ❌ | Firewall-restricted |
| **Lab 05** | ✅ | ✅ | ✅ | POC Sprint (Kind recommended) |
| **Lab 06** | ✅ | ✅ | ✅ | Multi-tenant |
| **Lab 07** | ✅ | ✅ | ❌ | Integration patterns |
| **Lab 08** | ✅ | ✅ | ✅ | Handoff (cloud-agnostic) |
| **Lab 09** | ✅ | ✅ | ✅ | Troubleshooting (cloud-agnostic) |

## Provider Selection Guide

**Choose GCP if:**
- Cost-conscious (free control plane)
- Prefer simpler networking (VPC-native)
- Need faster setup
- Use Google Workspace

**Choose AWS if:**
- Need larger ecosystem
- Require connection pooling (RDS Proxy)
- Have existing AWS infrastructure
- Need enterprise-scale features

**Choose Kind if:**
- Learning/testing
- Zero cost requirement
- Fast iteration needed
- No cloud account available

See [Provider Comparison Guide](../02-multi-cloud/provider-comparison.md) for detailed technical comparisons.

## Additional Resources

- [Provider Comparison Guide](../02-multi-cloud/provider-comparison.md) - Technical GCP vs AWS comparison
- [Migration Guide](../02-multi-cloud/migration-guide.md) - How to migrate between providers
- [Feature Parity Matrix](../02-multi-cloud/feature-parity-matrix.md) - Detailed feature comparison
- [Multi-Cloud Considerations](../02-multi-cloud/multi-cloud-considerations.md) - Strategic analysis

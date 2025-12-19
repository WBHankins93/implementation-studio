# Lab Specifications

Detailed specifications for all 9 labs in Implementation Studio.

## Lab 01: Standard GKE Deployment ✅

**Status:** Complete  
**Time:** 1-2 hours | **Cost:** $5-10

**Learning Objectives:**
- Deploy a production-ready GKE cluster with proper networking
- Install and configure Argo Workflows
- Set up ingress with TLS termination
- Implement basic monitoring and logging
- Understand the baseline that all other labs modify

**What Gets Deployed:**
- GCP VPC with public and private subnets
- GKE cluster (private nodes, public endpoint)
- Argo Workflows with UI exposed via ingress
- Ingress-nginx controller
- Sample workflows demonstrating the reference application

**Prerequisites:**
- GCP project with billing enabled
- gcloud CLI configured
- Terraform >= 1.5
- kubectl
- Helm 3

**Validation Status:** Kubernetes manifests testable locally; GCP infrastructure requires cloud deployment

[View Lab 01 →](../labs/01-standard-deployment/README.md)

---

## Lab 02: Air-Gapped Deployment

**Status:** In Progress  
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

**Validation Status:** Fully testable locally - this IS the target environment

[View Lab 02 →](../labs/02-airgapped-deployment/README.md)

---

## Lab 03: Private Network Deployment

**Status:** Planned  
**Time:** 2-3 hours | **Cost:** $8-15

**Learning Objectives:**
- Deploy GKE with private cluster configuration
- Configure private Google Access for GCP services
- Set up bastion host for cluster access
- Implement internal-only load balancers
- Understand VPN/Interconnect patterns (conceptual)

**What Gets Deployed:**
- GCP VPC with private-only subnets
- Private GKE cluster (private nodes, private endpoint)
- Bastion host for access
- Internal ingress controller
- Argo Workflows accessible only from within VPC

**Prerequisites:**
- Same as Lab 01
- Understanding of Lab 01 baseline

**Validation Status:** Kubernetes manifests testable locally; GCP infrastructure requires cloud deployment

---

## Lab 04: Firewall-Restricted Deployment

**Status:** Planned  
**Time:** 2-3 hours | **Cost:** $5-10

**Learning Objectives:**
- Work within strict egress firewall rules
- Identify and document required external endpoints
- Configure applications to work through proxies
- Communicate requirements to customer security teams
- Implement allowlist-based network policies

**What Gets Deployed:**
- GKE cluster with strict egress firewall rules
- Squid proxy for controlled external access
- Network policies enforcing egress restrictions
- Argo Workflows configured for proxy usage

**Key Techniques:**
- HTTP_PROXY / HTTPS_PROXY configuration
- Network policy egress rules
- Firewall rule documentation
- Working with customer security teams (process documentation)

**Validation Status:** Partial - network policies testable locally, GCP firewall rules require cloud

---

## Lab 05: The POC Sprint

**Status:** Planned  
**Time:** 1-2 hours (deployment) + templates | **Cost:** $0-5

**Learning Objectives:**
- Scope a time-boxed proof of concept
- Define measurable success criteria
- Deploy minimal viable infrastructure quickly
- Prepare and deliver effective demos
- Document outcomes for stakeholders

**What Gets Deployed:**
- Minimal GKE cluster (or Kind for zero-cost option)
- Argo Workflows with pre-configured demo workflows
- Demo script and presentation materials

**Key Deliverables:**
- POC scope document template
- Success criteria framework
- Demo script and backup plan
- Final report template

**Validation Status:** Fully testable - templates and local deployment

---

## Lab 06: Multi-Tenant Deployment

**Status:** Planned  
**Time:** 2-3 hours | **Cost:** $0-10

**Learning Objectives:**
- Implement namespace-based tenant isolation
- Configure RBAC for tenant separation
- Set up resource quotas per tenant
- Implement network policies for tenant isolation
- Manage tenant lifecycle (onboarding, offboarding)

**What Gets Deployed:**
- GKE cluster (or Kind)
- Multiple tenant namespaces
- Tenant-specific RBAC, quotas, network policies
- Shared services namespace
- Argo Workflows per tenant

**Key Techniques:**
- Namespace isolation strategies
- NetworkPolicy for tenant separation
- ResourceQuota and LimitRange
- RBAC scoping

**Validation Status:** Fully testable locally with Kind

---

## Lab 07: Integration Patterns

**Status:** Planned  
**Time:** 3-4 hours | **Cost:** $10-20

**Learning Objectives:**
- Integrate with external authentication (OAuth, SAML)
- Connect to external databases securely
- Configure API gateway patterns
- Understand service mesh basics for external traffic

**What Gets Deployed:**
- GKE cluster with Argo Workflows
- OAuth2-proxy for authentication
- Cloud SQL proxy for database connectivity
- Example API gateway configuration

**Key Techniques:**
- OAuth2/OIDC integration
- Secure database connectivity
- API gateway patterns
- Service mesh traffic management (Istio basics)

**Validation Status:** Partial - some patterns testable locally, cloud services require deployment

---

## Lab 08: Handoff and Runbooks

**Status:** Planned  
**Time:** 2-3 hours | **Cost:** $0-5

**Learning Objectives:**
- Create production-ready documentation
- Set up monitoring dashboards
- Configure alerting rules
- Develop training materials for customer teams
- Execute knowledge transfer

**What Gets Deployed:**
- Prometheus + Grafana stack
- Pre-built dashboards for Argo Workflows
- Alerting rules for common issues
- Documentation templates

**Key Deliverables:**
- Deployment runbook template
- Incident response playbook
- Grafana dashboard JSON files
- Training agenda and exercises
- Handoff checklist

**Validation Status:** Dashboards and rules testable locally; full stack testable in Kind

---

## Lab 09: Troubleshooting Scenarios

**Status:** Planned  
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


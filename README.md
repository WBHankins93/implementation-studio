# Implementation Studio

> A production-grade learning platform teaching engineers how to deploy software into real-world customer environments with constraints.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 📑 Quick Navigation

- [What is This?](#-what-is-this)
- [Quick Start](#-quick-start)
- [Labs Overview](#-labs-overview)
- [Architecture](#-architecture)
- [Documentation](#-documentation)
- [Contributing](#-contributing)

---

## 🎯 What is This?

Implementation Studio teaches deployment scenarios with **real constraints** that enterprise and defense customers actually have:
- Air-gapped networks
- Private clusters
- Firewall restrictions
- Multi-tenant isolation

Unlike tutorials that teach tools in isolation, this platform focuses on the **customer implementation lifecycle** - getting software deployed and operational in constrained environments.

**Primary Audiences:**
- Solutions Engineers implementing software in customer environments
- Platform Engineers supporting customer-facing deployments
- DevOps Engineers learning "last mile" deployment patterns
- Engineers preparing for SE roles

---

## 🚀 Quick Start

1. **Clone and explore:**
   ```bash
   git clone https://github.com/WBHankins93/implementation-studio.git
   cd implementation-studio
   ```

2. **Read the getting started guide:**
   - [📖 Documentation Guide](./docs/README.md) - **Start here!** Organized docs with reading order
   - [Getting Started Guide](./docs/01-getting-started/getting-started.md) - Prerequisites, installation, first steps
   - [Learning Paths](./docs/01-getting-started/learning-paths.md) - Recommended progression

3. **Choose your first lab:**
   - **Lab 01** (Standard Deployment) - GCP or AWS → [View Lab 01](./labs/01-standard-deployment/README.md)
   - **Lab 02** (Air-Gapped) - Fully local, no cloud costs → [View Lab 02](./labs/02-airgapped-deployment/README.md)
   - **Lab 05** (POC Sprint) - Kind, GCP, or AWS → [View Lab 05](./labs/05-poc-sprint/README.md)

4. **Follow the lab README** - Each lab has comprehensive documentation

---

## 🧪 Labs Overview

| Lab | Name | Status | Providers | Time | Cost | Description | Link |
|-----|------|--------|-----------|------|------|-------------|------|
| 01 | Standard Deployment | ✅ Complete | GCP, AWS | 1-2h | $5-15 | Production-ready Kubernetes cluster baseline | [View Lab →](./labs/01-standard-deployment/README.md) |
| 02 | Air-Gapped Deployment | ✅ Complete | Kind | 2-3h | $0 | Deploy without internet access | [View Lab →](./labs/02-airgapped-deployment/README.md) |
| 03 | Private Network Deployment | ✅ Complete | GCP, AWS | 2-3h | $8-18 | Private clusters and bastion hosts | [View Lab →](./labs/03-private-network-deployment/README.md) |
| 04 | Firewall-Restricted Deployment | ✅ Complete | GCP, AWS | 2-3h | $5-15 | Work within strict egress rules | [View Lab →](./labs/04-firewall-restricted-deployment/README.md) |
| 05 | The POC Sprint | ✅ Complete | Kind, GCP, AWS | 1-2h | $0-5 | Scope and deliver proof of concepts | [View Lab →](./labs/05-poc-sprint/README.md) |
| 06 | Multi-Tenant Deployment | ✅ Complete | Kind, GCP, AWS | 2-3h | $0-10 | Namespace isolation and RBAC | [View Lab →](./labs/06-multi-tenant-deployment/README.md) |
| 07 | Integration Patterns | ✅ Complete | GCP, AWS | 3-4h | $10-25 | Auth, databases, API gateways | [View Lab →](./labs/07-integration-patterns/README.md) |
| 08 | Handoff and Runbooks | ✅ Complete | Cloud-Agnostic | 2-3h | $0-5 | Production documentation and monitoring | [View Lab →](./labs/08-handoff-runbooks/README.md) |
| 09 | Troubleshooting Scenarios | ✅ Complete | Cloud-Agnostic | 2-4h | $0 | Systematic debugging methodology | [View Lab →](./labs/09-troubleshooting-scenarios/README.md) |

**Each lab includes:**
- Comprehensive README with learning objectives
- Step-by-step instructions
- Architecture documentation
- Troubleshooting guides
- Validation status transparency

[View detailed lab specifications →](./docs/04-labs/lab-specifications.md)

---

## 🏗️ Architecture

### Repository Structure

```
implementation-studio/
├── docs/                    # Platform documentation + SE guides
├── modules/                 # Reusable Terraform & Kubernetes modules
│   ├── gcp/                 # GCP infrastructure modules
│   ├── aws/                 # AWS infrastructure modules
│   └── kubernetes/          # Kubernetes deployment modules (cloud-agnostic)
├── labs/                    # 9 hands-on learning labs
├── reference-app/           # Argo Workflows sample workloads
└── tools/                   # Validation, setup, cleanup scripts
```

### Modules

**GCP Modules** (`modules/gcp/`):
- `gke-cluster` - Standard GKE with configurable options
- `vpc-standard` - Public + private subnets, NAT gateway
- `vpc-private` - Fully private, no external IPs
- `artifact-registry` - Container registry
- `airgap-registry` - Registry for disconnected environments
- `firewall-rules` - Common firewall configurations
- `private-service-connect` - Private GCP service access

**AWS Modules** (`modules/aws/`):
- `eks-cluster` - Standard EKS with configurable options
- `vpc` - Public + private subnets, NAT gateway
- `vpc-private` - Fully private, VPC endpoints
- `ecr` - Elastic Container Registry
- `rds` - Relational Database Service
- `security-groups` - Security groups for strict egress control

**Kubernetes Modules** (`modules/kubernetes/`) - Cloud-agnostic:
- `argo-workflows` - Standard Argo deployment
- `argo-workflows-airgap` - Offline-ready Argo
- `ingress-nginx` - Public ingress controller
- `ingress-internal` - Internal-only ingress
- `network-policies` - Isolation patterns
- `rbac-patterns` - Permission templates
- `resource-quotas` - Multi-tenant resource limits

Each module includes comprehensive documentation. [View module documentation →](./modules/README.md)

### Multi-Cloud Support

Implementation Studio supports **both GCP and AWS** for cloud deployments:

- **GCP (GKE)** - Google Kubernetes Engine
- **AWS (EKS)** - Amazon Elastic Kubernetes Service
- **Kind** - Local Kubernetes (for labs that support it)

Most labs support multiple providers. Choose based on your needs:
- **GCP:** Lower costs, simpler networking, faster setup
- **AWS:** Larger ecosystem, connection pooling, enterprise features
- **Kind:** Zero cost, fastest iteration, perfect for learning

See [Provider Comparison Guide](./docs/02-multi-cloud/provider-comparison.md) for detailed technical comparisons.

### Reference Application

Argo Workflows serves as the reference application. [Learn more →](./docs/01-getting-started/reference-application.md)

---

## 📚 Documentation

> **📖 Start Here:** See the [Documentation Guide](./docs/README.md) for organized documentation and essential reading order.

### Quick Links

**Essential Reading (Start Here):**
- [📖 Documentation Guide](./docs/README.md) - **Read this first!** Organized docs with reading order
- [Getting Started](./docs/01-getting-started/getting-started.md) - Prerequisites, installation, first steps
- [Learning Paths](./docs/01-getting-started/learning-paths.md) - Recommended progression through labs
- [Reference Application](./docs/01-getting-started/reference-application.md) - Why Argo Workflows

**Multi-Cloud Documentation:**
- [Provider Comparison](./docs/02-multi-cloud/provider-comparison.md) - GCP vs AWS technical comparison
- [Migration Guide](./docs/02-multi-cloud/migration-guide.md) - How to migrate between providers
- [Feature Parity Matrix](./docs/02-multi-cloud/feature-parity-matrix.md) - Detailed feature comparison

**Project Information:**
- [Roadmap](./docs/03-project-management/roadmap.md) - Improvement roadmap and ADR planning
- [Quality Standards](./docs/03-project-management/quality-standards.md) - Code and documentation standards
- [Testing Strategy](./docs/03-project-management/testing-strategy.md) - What's validated locally vs cloud

**Lab Information:**
- [Lab Specifications](./docs/04-labs/lab-specifications.md) - Detailed specifications for all 9 labs

**For Solutions Engineers:**
- [Using Labs in Engagements](./docs/for-ses/using-in-engagements.md) - Adapt labs for real customers
- [Discovery Frameworks](./docs/for-ses/discovery-frameworks.md) - Technical discovery questions
- [Scoping POCs](./docs/for-ses/scoping-pocs.md) - How to scope and deliver POCs
- [Customer Handoff](./docs/for-ses/customer-handoff.md) - Transitioning to operations

**Operations:**
- [Cost Management](./docs/05-operations/cost-management.md) - Cost estimates and optimization

---

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

**Key Areas:**
- Lab validation and testing
- Documentation improvements
- Module enhancements
- Bug reports and fixes

---

## 📞 Contact

**Project Owner:** Ben Hankins  
**Repository:** [github.com/WBHankins93/implementation-studio](https://github.com/WBHankins93/implementation-studio)

**Related Projects:**
- [DevOps-Studio](https://github.com/WBHankins93/DevOps-Studio) - Production-grade DevOps learning labs
- [deployment-patterns](https://github.com/WBHankins93/deployment-patterns)
- [terraform-infra-platform](https://github.com/WBHankins93/terraform-infra-platform)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

*Last Updated: January 2026*

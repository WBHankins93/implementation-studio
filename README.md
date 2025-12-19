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
   - [Getting Started Guide](./docs/getting-started.md) - Prerequisites, installation, first steps
   - [Learning Paths](./docs/learning-paths.md) - Recommended progression

3. **Choose your first lab:**
   - **Lab 01** (Standard GKE) - If you have GCP access → [View Lab 01](./labs/01-standard-deployment/README.md)
   - **Lab 02** (Air-Gapped) - Fully local, no cloud costs → [View Lab 02](./labs/02-airgapped-deployment/README.md)

4. **Follow the lab README** - Each lab has comprehensive documentation

---

## 🧪 Labs Overview

| Lab | Name | Status | Time | Cost | Description | Link |
|-----|------|--------|------|------|-------------|------|
| 01 | Standard GKE Deployment | ✅ Complete | 1-2h | $5-10 | Production-ready GKE cluster baseline | [View Lab →](./labs/01-standard-deployment/README.md) |
| 02 | Air-Gapped Deployment | 🚧 In Progress | 2-3h | $0 | Deploy without internet access | [View Lab →](./labs/02-airgapped-deployment/README.md) |
| 03 | Private Network Deployment | 📋 Planned | 2-3h | $8-15 | Private clusters and bastion hosts | [View Lab →](./labs/03-private-network-deployment/README.md) |
| 04 | Firewall-Restricted Deployment | 📋 Planned | 2-3h | $5-10 | Work within strict egress rules | [View Lab →](./labs/04-firewall-restricted-deployment/README.md) |
| 05 | The POC Sprint | 📋 Planned | 1-2h | $0-5 | Scope and deliver proof of concepts | [View Lab →](./labs/05-poc-sprint/README.md) |
| 06 | Multi-Tenant Deployment | 📋 Planned | 2-3h | $0-10 | Namespace isolation and RBAC | [View Lab →](./labs/06-multi-tenant-deployment/README.md) |
| 07 | Integration Patterns | 📋 Planned | 3-4h | $10-20 | Auth, databases, API gateways | [View Lab →](./labs/07-integration-patterns/README.md) |
| 08 | Handoff and Runbooks | 📋 Planned | 2-3h | $0-5 | Production documentation and monitoring | [View Lab →](./labs/08-handoff-runbooks/README.md) |
| 09 | Troubleshooting Scenarios | 📋 Planned | 2-4h | $0 | Systematic debugging methodology | [View Lab →](./labs/09-troubleshooting-scenarios/README.md) |

**Each lab includes:**
- Comprehensive README with learning objectives
- Step-by-step instructions
- Architecture documentation
- Troubleshooting guides
- Validation status transparency

[View detailed lab specifications →](./docs/lab-specifications.md)

---

## 🏗️ Architecture

### Repository Structure

```
implementation-studio/
├── docs/                    # Platform documentation + SE guides
├── modules/                 # Reusable Terraform & Kubernetes modules
│   ├── gcp/                 # GCP infrastructure modules
│   └── kubernetes/          # Kubernetes deployment modules
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

**Kubernetes Modules** (`modules/kubernetes/`):
- `argo-workflows` - Standard Argo deployment
- `argo-workflows-airgap` - Offline-ready Argo
- `ingress-nginx` - Public ingress controller
- `ingress-internal` - Internal-only ingress
- `network-policies` - Isolation patterns
- `rbac-patterns` - Permission templates
- `resource-quotas` - Multi-tenant resource limits

Each module includes comprehensive documentation. [View module documentation →](./modules/README.md)

### Reference Application

Argo Workflows serves as the reference application. [Learn more →](./docs/reference-application.md)

---

## 📚 Documentation

### Getting Started
- [Getting Started Guide](./docs/getting-started.md) - Prerequisites, installation, first steps
- [Learning Paths](./docs/learning-paths.md) - Recommended progression through labs
- [Reference Application](./docs/reference-application.md) - Why Argo Workflows, what it represents

### For Solutions Engineers
- [Using Labs in Engagements](./docs/for-ses/using-in-engagements.md) - Adapt labs for real customers
- [Discovery Frameworks](./docs/for-ses/discovery-frameworks.md) - Technical discovery questions
- [Scoping POCs](./docs/for-ses/scoping-pocs.md) - How to scope and deliver POCs
- [Customer Handoff](./docs/for-ses/customer-handoff.md) - Transitioning to operations

### Technical Documentation
- [Testing Strategy](./docs/testing-strategy.md) - What's validated locally vs cloud
- [Cost Management](./docs/cost-management.md) - GCP cost estimates, optimization
- [Lab Specifications](./docs/lab-specifications.md) - Detailed lab requirements

### Project Management
- [Timeline](./docs/timeline.md) - Development phases and milestones
- [Quality Standards](./docs/quality-standards.md) - Code and documentation standards
- [Success Criteria](./docs/success-criteria.md) - Project and lab completion criteria

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

*Last Updated: December 2025*

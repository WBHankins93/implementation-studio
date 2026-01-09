# Implementation Studio

> **Battle-tested implementation patterns for cloud, infrastructure, and customer-facing engineering teams.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 🔨 Why I Built This

After 8+ enterprise implementations in healthcare and energy—industries with some of the strictest security and network constraints—I realized I was repeating the same patterns but documenting them differently each time.

**The problem:** Every air-gapped deployment had the same architecture patterns. Every RBAC implementation was solving the same isolation problem. But my Terraform wasn't consistent, my Kubernetes knowledge was fragmented across engagement notes, and I was constantly re-learning GCP quirks and AWS best practices between clients.

**Without this repo, I was:** Searching through old projects for "how did I handle bastion access last time?" Re-validating Terraform modules that should have been production-grade from day one. Forgetting critical integration patterns between engagements.

**With this repo, I now:** Deploy faster, with confidence that patterns are battle-tested across multiple clients. Scale consistently across GCP and AWS without reinventing the wheel. Prepare new clients by knowing exactly what labs and modules apply to their constraints.

**What you get:** Production-grade Terraform modules, 9 hands-on labs covering real constraints (air-gapped, private clusters, RBAC isolation), and frameworks that work whether you're an experienced SE or a first-year engineer learning what "restricted environments" actually means.

This isn't theoretical. It's refined through real healthcare and energy implementations where mistakes are expensive and constraints are non-negotiable.

---

## 🎯 Who This Is For

**If you are a Solutions Engineer**, this repo helps you **deploy software in real customer environments** with air-gapped networks, private clusters, and strict security constraints.

**If you are a Platform Engineer**, this repo helps you **build reusable infrastructure patterns** that work across GCP and AWS, with production-grade Terraform modules you can steal.

**If you are a DevOps Engineer**, this repo helps you **master the "last mile" of deployment** - the part where tutorials end but real customer work begins.

**If you are preparing for an SE role**, this repo helps you **understand customer implementation lifecycles** - from POC scoping to production handoff.

---

## 🧠 How to Use This Repo

- Need to **learn by doing**? Start with the labs.
- Need to **solve a real customer problem**? Steal a module.
- Need to **run a POC or handoff**? Use the templates.

---

## ⚡ Immediate Payoff: What You Can Steal Today

### 🎨 Templates & Frameworks

**POC Templates** (ready to use in customer engagements):
- [POC Scope Document](./labs/05-poc-sprint/templates/poc-scope-document.md) - Structure customer POCs
- [Daily Standup Format](./labs/05-poc-sprint/templates/daily-standup-format.md) - Keep stakeholders aligned
- [Final Report Template](./labs/05-poc-sprint/templates/final-report-template.md) - Professional POC deliverables
- [Success Criteria Template](./labs/05-poc-sprint/templates/success-criteria.md) - Define measurable outcomes

**Decision Frameworks**:
- [Provider Selection Guide](./docs/02-multi-cloud/provider-comparison.md) - GCP vs AWS technical comparison
- [Migration Decision Tree](./docs/02-multi-cloud/migration-guide.md) - When and how to migrate between clouds
- [Lab Selection Guide](./docs/01-getting-started/learning-paths.md) - Choose your learning path

**Architectural Decision Records**:
- [ADR Template](./docs/adr/TEMPLATE.md) - Document architectural decisions
- [ADR-001: Reference Application](./docs/adr/001-reference-application.md) - Why Argo Workflows
- [ADR-003: Multi-Cloud Strategy](./docs/adr/003-multi-cloud-strategy.md) - GCP + AWS approach

### 🏗️ Production-Grade Terraform Modules

**GCP Modules** (battle-tested):
- `modules/gcp/gke-cluster` - Production-ready GKE with private endpoints
- `modules/gcp/vpc-private` - Fully private VPC, no external IPs
- `modules/gcp/airgap-registry` - Offline container registry

**AWS Modules** (production-ready):
- `modules/aws/eks-cluster` - EKS with IRSA and private endpoints
- `modules/aws/vpc-private` - Private VPC with VPC endpoints
- `modules/aws/rds` - RDS with proxy and connection pooling

**Kubernetes Modules** (cloud-agnostic):
- `modules/kubernetes/argo-workflows-airgap` - Offline deployment patterns
- `modules/kubernetes/network-policies` - Multi-tenant isolation
- `modules/kubernetes/rbac-patterns` - Permission templates

[View all modules →](./modules/README.md)

### 📋 Real-World Patterns

**9 Hands-On Labs** covering actual customer scenarios:
- Air-gapped deployments (no internet)
- Private cluster patterns (bastion access)
- Firewall-restricted environments (egress control)
- Multi-tenant isolation (RBAC, quotas, network policies)
- Integration patterns (databases, auth, API gateways)
- POC sprint frameworks (scoping, delivery, handoff)

[View all labs →](#-labs-overview)

---

## 🏆 Built From Real Engagements

**Real Customer Implementation Work**

These patterns come from actual implementation work in enterprise and defense environments. The constraints you'll learn (air-gapped networks, private clusters, strict firewall rules) are the same ones you'll face in real customer deployments.

**Production-Grade Quality**

- ✅ Terraform validated and tested
- ✅ Kubernetes manifests verified
- ✅ Architecture patterns documented with ADRs
- ✅ Multi-cloud support (GCP + AWS)
- ✅ Transparent validation status (we document what's tested vs. what needs real deployment)

**Used in Real Implementations**

The modules and patterns in this repo are designed to be adapted for actual customer engagements. Each lab includes:
- Step-by-step deployment guides
- Troubleshooting documentation
- Validation status transparency
- Real-world constraint scenarios

---

## 🚀 Quick Start (30 Seconds)

**Option 1: Start with a Lab** (recommended)
```bash
git clone https://github.com/WBHankins93/implementation-studio.git
cd implementation-studio
# Choose your first lab:
# - Lab 01 (Standard Deployment) - GCP or AWS
# - Lab 02 (Air-Gapped) - Fully local, $0 cost
# - Lab 05 (POC Sprint) - Templates and frameworks
```

**Option 2: Steal a Module**
```bash
# Copy a Terraform module directly into your project
cp -r modules/gcp/gke-cluster /path/to/your/project
# Or browse: modules/gcp/ | modules/aws/ | modules/kubernetes/
```

**Option 3: Use a Template**
```bash
# Copy POC templates for customer engagements
cp labs/05-poc-sprint/templates/*.md /path/to/your/poc/
```

[📖 Full Getting Started Guide →](./docs/01-getting-started/getting-started.md)

---

## ⚠️ Real-World Deployment Note

> **The patterns are right, but production always has surprises.**

This repo provides **validated, production-grade patterns**. However, when using in actual customer engagements:

- ✅ **Validated:** Terraform syntax, Kubernetes manifests, architecture patterns
- ⚠️ **Requires testing:** IAM permissions, quota limits, regional API differences, customer-specific constraints

**Best Practice:** Always test in dev/staging first. The patterns are correct, but production environments have unique constraints (IAM, quotas, compliance) that can't be fully anticipated.

Each lab includes a `VALIDATION-STATUS.md` file that transparently documents what's tested vs. what requires real deployment. [Learn more →](#-real-world-deployment-note)

---

## 🧪 Labs Overview

| Lab | Name | Providers | Time | Cost | What You Learn |
|-----|------|-----------|------|------|----------------|
| 01 | Standard Deployment | GCP, AWS | 1-2h | $5-15 | Production Kubernetes baseline |
| 02 | Air-Gapped Deployment | Kind | 2-3h | $0 | Deploy without internet access |
| 03 | Private Network Deployment | GCP, AWS | 2-3h | $8-18 | Private clusters + bastion hosts |
| 04 | Firewall-Restricted Deployment | GCP, AWS | 2-3h | $5-15 | Work within strict egress rules |
| 05 | The POC Sprint | Kind, GCP, AWS | 1-2h | $0-5 | Scope and deliver POCs |
| 06 | Multi-Tenant Deployment | Kind, GCP, AWS | 2-3h | $0-10 | Namespace isolation + RBAC |
| 07 | Integration Patterns | GCP, AWS | 3-4h | $10-25 | Auth, databases, API gateways |
| 08 | Handoff and Runbooks | Cloud-Agnostic | 2-3h | $0-5 | Production documentation |
| 09 | Troubleshooting Scenarios | Cloud-Agnostic | 2-4h | $0 | Systematic debugging |

[View detailed lab specifications →](./docs/04-labs/lab-specifications.md)

---

## 🏗️ Architecture

### Repository Structure

```
implementation-studio/
├── docs/                    # Documentation + SE guides
│   ├── 01-getting-started/  # Start here
│   ├── 02-multi-cloud/      # GCP vs AWS guides
│   ├── 03-project-management/ # Roadmap, ADRs, quality standards
│   ├── 04-labs/             # Lab specifications
│   ├── 05-operations/       # Cost management, DR patterns
│   └── adr/                 # Architectural Decision Records
├── modules/                 # Reusable Terraform & K8s modules
│   ├── gcp/                 # GCP infrastructure modules
│   ├── aws/                 # AWS infrastructure modules
│   └── kubernetes/          # Cloud-agnostic K8s modules
├── labs/                    # 9 hands-on learning labs
├── reference-app/           # Argo Workflows sample workloads
└── tools/                   # Validation, setup, cleanup scripts
```

### Multi-Cloud Support

**GCP (GKE)** - Lower costs, simpler networking, faster setup  
**AWS (EKS)** - Larger ecosystem, connection pooling, enterprise features  
**Kind** - Zero cost, fastest iteration, perfect for learning

Most labs support multiple providers. [Compare providers →](./docs/02-multi-cloud/provider-comparison.md)

---

## 📚 Documentation

> **📖 Start Here:** [Documentation Guide](./docs/README.md) - Organized docs with reading order

**Essential Reading:**
- [Getting Started](./docs/01-getting-started/getting-started.md) - Prerequisites, installation, first steps
- [Learning Paths](./docs/01-getting-started/learning-paths.md) - Choose your path (SE, Platform, DevOps)
- [Reference Application](./docs/01-getting-started/reference-application.md) - Why Argo Workflows

**Multi-Cloud:**
- [Provider Comparison](./docs/02-multi-cloud/provider-comparison.md) - GCP vs AWS technical deep-dive
- [Migration Guide](./docs/02-multi-cloud/migration-guide.md) - How to migrate between providers
- [Feature Parity Matrix](./docs/02-multi-cloud/feature-parity-matrix.md) - Detailed feature comparison

**For Solutions Engineers:**
- [Using Labs in Engagements](./docs/for-ses/using-in-engagements.md) - Adapt labs for real customers
- [Discovery Frameworks](./docs/for-ses/discovery-frameworks.md) - Technical discovery questions
- [Scoping POCs](./docs/for-ses/scoping-pocs.md) - How to scope and deliver POCs
- [Customer Handoff](./docs/for-ses/customer-handoff.md) - Transitioning to operations

**Operations:**
- [Cost Management](./docs/05-operations/cost-management.md) - Cost estimates and optimization
- [Multi-Region Patterns](./docs/05-operations/multi-region-patterns.md) - High availability patterns
- [Disaster Recovery](./docs/05-operations/disaster-recovery.md) - DR strategies and patterns

---

## 🤝 How to Engage

**Star this repo** if you find it useful for your work.

**Open an issue** if you want a pattern added or have questions about implementation.

**Submit a PR** if you have real-world patterns from customer engagements that others can learn from.

**Share feedback** on what's working and what could be improved.

[Contributing Guidelines →](./CONTRIBUTING.md)

---

## 📞 Contact & Related Projects

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

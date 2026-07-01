# Implementation Studio Documentation

The documentation folder is the technical index for Implementation Studio. Use it when you need context, comparison, standards, or operational guidance before choosing a lab or module.

## Quick Start Reading Order

| Step | Read | Why |
| --- | --- | --- |
| 1 | [Getting Started](01-getting-started/getting-started.md) | Tooling, prerequisites, and first steps |
| 2 | [Learning Paths](01-getting-started/learning-paths.md) | Recommended lab sequences by role and constraint |
| 3 | [Reference Application](01-getting-started/reference-application.md) | Why Argo Workflows is the repo's sample workload |
| 4 | [Provider Comparison](02-multi-cloud/provider-comparison.md) | GCP vs AWS trade-offs before deploying cloud labs |
| 5 | [Testing Strategy](03-project-management/testing-strategy.md) | What is locally validated vs cloud-environment dependent |

## Documentation Map

| Section | Contents | Use it when |
| --- | --- | --- |
| [01-getting-started](01-getting-started/) | Setup, learning paths, reference app | You are new to the repo |
| [02-multi-cloud](02-multi-cloud/) | Provider comparison, migration, parity matrix | You are choosing or moving between GCP and AWS |
| [03-project-management](03-project-management/) | Roadmap, standards, testing, success criteria, module maintenance | You are contributing or assessing quality |
| [04-labs](04-labs/) | Lab specifications | You are comparing labs |
| [05-operations](05-operations/) | Cost, disaster recovery, multi-region patterns | You are planning production operations |
| [adr](adr/) | Architecture decision records | You want design rationale |
| [se-integration.md](se-integration.md) | Mapping between labs and customer scenarios | You are using the repo in SE work |

## Navigation By Role

| Role | Recommended route |
| --- | --- |
| New learner | [Getting Started](01-getting-started/getting-started.md) -> [Learning Paths](01-getting-started/learning-paths.md) -> [Lab Specifications](04-labs/lab-specifications.md) |
| Solutions Engineer | [SE Integration](se-integration.md) -> [POC Sprint](../labs/05-poc-sprint/README.md) -> [Handoff Runbooks](../labs/08-handoff-runbooks/README.md) |
| Platform Engineer | [Provider Comparison](02-multi-cloud/provider-comparison.md) -> [Modules](../modules/README.md) -> [Multi-Tenant Lab](../labs/06-multi-tenant-deployment/README.md) |
| Contributor | [Quality Standards](03-project-management/quality-standards.md) -> [Testing Strategy](03-project-management/testing-strategy.md) -> [Contributing](../CONTRIBUTING.md) |

## Finding What You Need

| Need | Go to |
| --- | --- |
| Choose a lab | [Lab Specifications](04-labs/lab-specifications.md) or [Labs README](../labs/README.md) |
| Choose GCP or AWS | [Provider Comparison](02-multi-cloud/provider-comparison.md) |
| Understand feature parity | [Feature Parity Matrix](02-multi-cloud/feature-parity-matrix.md) |
| Plan migration | [Migration Guide](02-multi-cloud/migration-guide.md) |
| Estimate cost | [Cost Management](05-operations/cost-management.md) |
| Plan resilience | [Disaster Recovery](05-operations/disaster-recovery.md) and [Multi-Region Patterns](05-operations/multi-region-patterns.md) |
| Add or maintain modules | [Module Maintenance](03-project-management/module-maintenance.md) |
| Understand project decisions | [ADR Index](adr/README.md) |

## Maintenance Standard

Documentation should link to the nearest authoritative page instead of duplicating long explanations. When adding a new guide, update the closest README so the content has an obvious home and can be found from the root README in two clicks or fewer.

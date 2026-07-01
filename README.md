# Implementation Studio

[![Validate Terraform](https://github.com/WBHankins93/implementation-studio/actions/workflows/validate-terraform.yml/badge.svg)](https://github.com/WBHankins93/implementation-studio/actions/workflows/validate-terraform.yml)
[![Validate Kubernetes Manifests](https://github.com/WBHankins93/implementation-studio/actions/workflows/validate-manifests.yml/badge.svg)](https://github.com/WBHankins93/implementation-studio/actions/workflows/validate-manifests.yml)
[![Markdown Lint](https://github.com/WBHankins93/implementation-studio/actions/workflows/markdown-lint.yml/badge.svg)](https://github.com/WBHankins93/implementation-studio/actions/workflows/markdown-lint.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A practical implementation library for deploying software in real customer environments: private clusters, air-gapped networks, firewall restrictions, multi-tenant platforms, integrations, POCs, handoffs, and troubleshooting.

The repo combines reusable Terraform modules, Kubernetes manifests, Argo Workflows examples, field templates, and hands-on labs. It is meant to be useful in two modes: learn the patterns end to end, or copy the specific module, lab, checklist, or template you need for an implementation.

## Quick Start

```bash
git clone https://github.com/WBHankins93/implementation-studio.git
cd implementation-studio

# Pick a path, then open the matching lab README.
open START-HERE.md
open labs/README.md
```

Run the local checks that match the files you changed:

```bash
tools/validate-terraform.sh
tools/validate-local.sh
tools/validate-modules.sh
npm run docs:build
```

## How To Navigate

| Entry point | Use it when |
| --- | --- |
| [Start Here](START-HERE.md) | You want the fastest route into the repo by scenario. |
| [Labs](labs/README.md) | You want hands-on deployment paths and lab comparisons. |
| [Documentation](docs/README.md) | You want the organized technical docs and reading order. |
| [Modules](modules/README.md) | You want reusable Terraform modules or Kubernetes patterns. |
| [Reference App](reference-app/README.md) | You want the Argo Workflows workloads used across labs. |
| [Learning Paths](LEARNING-PATHS.md) | You want a sequenced path by role, cost, or time available. |
| [Project Status](PROJECT-STATUS.md) | You want to know what exists, what is validated, and what is next. |

## Repository Structure

```text
docs/             Getting started, multi-cloud, quality, operations, ADRs
labs/             Nine implementation labs with scripts, Terraform, manifests, and guides
modules/          Reusable AWS, GCP, and Kubernetes building blocks
reference-app/    Argo Workflows examples used as the deployment target
engagements/      Customer/account coordination guides
pre-sales/        Account strategy and POC-facing field guidance
internal/         Product feedback and impact-tracking guidance
tools/            Local validation, setup, and cleanup scripts
.github/          CI checks for Markdown, Terraform, and Kubernetes manifests
```

## Labs

| Lab | Scenario | Providers | Best for |
| --- | --- | --- | --- |
| [01 Standard Deployment](labs/01-standard-deployment/README.md) | Baseline Kubernetes deployment | GCP, AWS | First production-style cluster |
| [02 Air-Gapped Deployment](labs/02-airgapped-deployment/README.md) | Offline deployment workflow | Kind | Disconnected environments |
| [03 Private Network Deployment](labs/03-private-network-deployment/README.md) | Private clusters and bastion access | GCP, AWS | Locked-down networks |
| [04 Firewall-Restricted Deployment](labs/04-firewall-restricted-deployment/README.md) | Egress allowlists and proxy patterns | GCP, AWS | Security-team constrained installs |
| [05 POC Sprint](labs/05-poc-sprint/README.md) | POC scoping, demo prep, and reports | Kind, GCP, AWS | Fast customer validation |
| [06 Multi-Tenant Deployment](labs/06-multi-tenant-deployment/README.md) | Namespace isolation, RBAC, quotas | Kind, GCP, AWS | Shared platform foundations |
| [07 Integration Patterns](labs/07-integration-patterns/README.md) | Auth, databases, gateways, service mesh | GCP, AWS | Enterprise integration planning |
| [08 Handoff and Runbooks](labs/08-handoff-runbooks/README.md) | Monitoring, runbooks, knowledge transfer | Cloud-agnostic | Production readiness |
| [09 Troubleshooting Scenarios](labs/09-troubleshooting-scenarios/README.md) | Common failure modes and diagnostics | Kind | Debugging practice |

See [lab specifications](docs/04-labs/lab-specifications.md) for the detailed comparison.

## Modules

Implementation Studio includes 11 tracked Terraform modules and 6 Kubernetes pattern bundles.

| Area | Available modules |
| --- | --- |
| GCP | `artifact-registry`, `firewall-rules`, `gke-cluster`, `vpc-private`, `vpc-standard` |
| AWS | `ecr`, `eks-cluster`, `rds`, `security-groups`, `vpc`, `vpc-private` |
| Kubernetes | `argo-workflows`, `argo-workflows-airgap`, `ingress-nginx`, `network-policies`, `rbac-patterns`, `resource-quotas` |

Start with [modules/README.md](modules/README.md) for usage examples, provider parity notes, and module standards.

## Field Content

The implementation content is supported by small, copy-ready field guides:

| Area | Current guides |
| --- | --- |
| [Engagements](engagements/README.md) | Multi-workstream coordination for complex accounts |
| [Pre-sales](pre-sales/README.md) | Account strategy and expansion planning |
| [Internal](internal/README.md) | Product feedback capture and impact tracking |
| [POC templates](labs/05-poc-sprint/templates/) | Scope document, success criteria, standup format, final report |
| [Runbook templates](labs/08-handoff-runbooks/runbook-templates/) | Deployment, incident response, scaling, backup/restore, upgrades |

## Continuous Integration

Every pull request and push to `main` runs focused checks based on changed files:

| Workflow | What it checks |
| --- | --- |
| `docs-build.yml` | VitePress documentation build and GitHub Pages deployment |
| `markdown-lint.yml` | Markdown formatting across project docs |
| `validate-terraform.yml` | `terraform fmt`, `terraform init -backend=false`, `terraform validate`, and tflint |
| `validate-manifests.yml` | Kubernetes YAML validation and kustomize builds |

Run the equivalent local scripts before opening a PR when possible.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for PR expectations. New implementation content should have a clear home, a direct entry point from the nearest README, validation notes, and links to the relevant lab, module, or field guide.

## Related Projects

- [Solutions Playbook](https://github.com/WBHankins93/solutions-playbook) - SE/SA operating manual and companion field playbook.
- [DevOps Studio](https://github.com/WBHankins93/DevOps-Studio) - DevOps learning labs and exercises.
- [terraform-infra-platform](https://github.com/WBHankins93/terraform-infra-platform) - Infrastructure platform patterns.

## License

MIT License. See [LICENSE](LICENSE) for details.

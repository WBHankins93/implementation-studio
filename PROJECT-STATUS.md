# Implementation Studio Project Status

This page tracks what currently exists in the repository and where the main improvement opportunities are.

## Current Inventory

| Area | Status |
| --- | --- |
| Labs | 9 labs with READMEs, scripts, manifests, Terraform where applicable, and validation notes |
| Terraform modules | 11 tracked modules across AWS and GCP |
| Kubernetes pattern bundles | 6 tracked bundles for Argo, ingress, RBAC, network policy, quotas, and air-gap packaging |
| Documentation | Getting started, multi-cloud, project standards, lab specs, operations, and ADRs |
| Reference app | 6 Argo Workflows examples |
| Field guides | Multi-workstream coordination, account strategy, product feedback, impact tracking |
| CI | Markdown lint, Terraform validation, and Kubernetes manifest validation workflows |

## Ready To Use

- [Lab 01: Standard Deployment](labs/01-standard-deployment/README.md)
- [Lab 02: Air-Gapped Deployment](labs/02-airgapped-deployment/README.md)
- [Lab 03: Private Network Deployment](labs/03-private-network-deployment/README.md)
- [Lab 04: Firewall-Restricted Deployment](labs/04-firewall-restricted-deployment/README.md)
- [Lab 05: POC Sprint](labs/05-poc-sprint/README.md)
- [Lab 06: Multi-Tenant Deployment](labs/06-multi-tenant-deployment/README.md)
- [Lab 07: Integration Patterns](labs/07-integration-patterns/README.md)
- [Lab 08: Handoff and Runbooks](labs/08-handoff-runbooks/README.md)
- [Lab 09: Troubleshooting Scenarios](labs/09-troubleshooting-scenarios/README.md)
- [Modules catalog](modules/README.md)
- [Reference application](reference-app/README.md)
- [Documentation index](docs/README.md)

## Validation Model

| Check | Local command | CI workflow |
| --- | --- | --- |
| Markdown | `markdownlint-cli2 "**/*.md" "#node_modules"` | `.github/workflows/markdown-lint.yml` |
| Terraform | `tools/validate-terraform.sh` | `.github/workflows/validate-terraform.yml` |
| Module completeness | `tools/validate-modules.sh` | Covered by Terraform workflow plus local script |
| Kubernetes manifests | `tools/validate-local.sh` | `.github/workflows/validate-manifests.yml` |
| Shell syntax | `find . -name '*.sh' ... bash -n` | Not currently a dedicated CI workflow |

## Known Gaps

- Several cloud labs are structurally complete but still depend on real cloud-account validation for IAM, quota, regional, and provider-specific behavior.
- Local developer setup is not fully captured in a single bootstrap command; contributors need to install Terraform, kubectl, markdownlint, tflint, kubeval, and cloud CLIs separately.
- Shell script linting is not yet represented in CI.
- Empty local directories that are not tracked by git should either become real modules/patterns or be removed from local worktrees to avoid confusion.
- Field-guide coverage is intentionally small right now; the repo has account strategy, multi-workstream, feedback, and impact guides, but not a full SE playbook.

## Suggested Next Improvements

1. Add a docs link-check workflow so broken relative links fail in CI.
2. Add shellcheck or an equivalent shell lint workflow for scripts under `tools/` and `labs/**/scripts/`.
3. Add a one-command bootstrap script or Makefile for common validation tasks.
4. Expand module examples with minimal complete root-module examples for each provider family.
5. Add cloud validation evidence to each lab's `VALIDATION-STATUS.md` as labs are exercised in real GCP/AWS accounts.

## Maintenance Standard

New content should update the nearest README, include validation expectations, avoid linking to planned-but-absent files, and state whether it is locally validated, cloud validated, or conceptual.

# Implementation Studio Labs

The labs are the main hands-on path through Implementation Studio. Each lab includes a README, supporting docs, validation status, and the Terraform, manifests, scripts, or templates needed for that scenario.

## Lab Catalog

| Lab | Scenario | Providers | Typical use |
| --- | --- | --- | --- |
| [01 Standard Deployment](01-standard-deployment/README.md) | Baseline Kubernetes deployment | GCP, AWS | Establish the production-style starting point |
| [02 Air-Gapped Deployment](02-airgapped-deployment/README.md) | Offline deployment | Kind | Practice disconnected image and Helm packaging |
| [03 Private Network Deployment](03-private-network-deployment/README.md) | Private cluster and bastion access | GCP, AWS | Deploy when public endpoints are not allowed |
| [04 Firewall-Restricted Deployment](04-firewall-restricted-deployment/README.md) | Strict egress and proxy configuration | GCP, AWS | Work with security allowlists and outbound controls |
| [05 POC Sprint](05-poc-sprint/README.md) | POC scoping and demo delivery | Kind, GCP, AWS | Time-box customer validation |
| [06 Multi-Tenant Deployment](06-multi-tenant-deployment/README.md) | Tenant isolation | Kind, GCP, AWS | Build namespace, RBAC, quota, and policy patterns |
| [07 Integration Patterns](07-integration-patterns/README.md) | Auth, database, gateway, and mesh integration | GCP, AWS | Plan enterprise application connectivity |
| [08 Handoff and Runbooks](08-handoff-runbooks/README.md) | Monitoring, runbooks, and knowledge transfer | Cloud-agnostic | Prepare production operations |
| [09 Troubleshooting Scenarios](09-troubleshooting-scenarios/README.md) | Failure diagnosis and repair | Kind | Build systematic debugging habits |

## Choose By Situation

| If you need to... | Start with |
| --- | --- |
| Learn the whole stack | Lab 01, then follow [Learning Paths](../LEARNING-PATHS.md) |
| Stay local and avoid cloud spend | Labs 02, 05, 06, and 09 |
| Prepare for a customer POC | Lab 05 |
| Handle locked-down networks | Labs 02, 03, and 04 |
| Build a shared platform | Labs 01, 06, 07, and 08 |
| Practice debugging | Lab 09 |

## Validation

Each lab has a `VALIDATION-STATUS.md` file that explains what can be checked locally and what requires real cloud deployment. Use those files before treating a lab as production-ready for a customer or internal platform.

Common local checks:

```bash
tools/validate-terraform.sh
tools/validate-local.sh
```

For detailed specifications, see [docs/04-labs/lab-specifications.md](../docs/04-labs/lab-specifications.md).

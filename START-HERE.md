# Implementation Studio - Start Here

Implementation Studio is organized for just-in-time use. Start from the situation you are in, then follow the nearest lab, module, or field guide.

## I Need To Learn The System

| Goal | Start with |
| --- | --- |
| Understand the repo | [README.md](README.md) |
| Pick a sequence | [LEARNING-PATHS.md](LEARNING-PATHS.md) |
| Compare every lab | [labs/README.md](labs/README.md) |
| Learn the reference workload | [reference-app/README.md](reference-app/README.md) |
| Understand validation boundaries | [testing strategy](docs/03-project-management/testing-strategy.md) |

## I Need A Deployment Pattern

| Scenario | Use |
| --- | --- |
| Standard cloud deployment | [Lab 01: Standard Deployment](labs/01-standard-deployment/README.md) |
| No internet or disconnected install | [Lab 02: Air-Gapped Deployment](labs/02-airgapped-deployment/README.md) |
| Private cluster or bastion access | [Lab 03: Private Network Deployment](labs/03-private-network-deployment/README.md) |
| Strict egress or firewall allowlists | [Lab 04: Firewall-Restricted Deployment](labs/04-firewall-restricted-deployment/README.md) |
| Tenant isolation | [Lab 06: Multi-Tenant Deployment](labs/06-multi-tenant-deployment/README.md) |
| Auth, database, API gateway, or mesh integration | [Lab 07: Integration Patterns](labs/07-integration-patterns/README.md) |

## I Need Customer-Facing Material

| Situation | Use |
| --- | --- |
| Scope or run a POC | [Lab 05: POC Sprint](labs/05-poc-sprint/README.md) |
| Coordinate several workstreams | [Multi-workstream engagement guide](engagements/multi-workstream.md) |
| Build account strategy | [Account strategy framework](pre-sales/account-strategy.md) |
| Prepare handoff/runbooks | [Lab 08: Handoff and Runbooks](labs/08-handoff-runbooks/README.md) |
| Capture roadmap-impacting product gaps | [Product feedback process](internal/product-feedback.md) |
| Show measurable SE/implementation impact | [Tracking impact](internal/tracking-impact.md) |

## I Need Reusable Building Blocks

| Need | Start with |
| --- | --- |
| Terraform module catalog | [modules/README.md](modules/README.md) |
| Provider comparison | [provider comparison](docs/02-multi-cloud/provider-comparison.md) |
| Migration between GCP and AWS | [migration guide](docs/02-multi-cloud/migration-guide.md) |
| Operational patterns | [operations docs](docs/05-operations/cost-management.md) |
| Architecture decisions | [ADR index](docs/adr/README.md) |

## I Need To Debug Something

| Problem type | Use |
| --- | --- |
| Practice common failures | [Lab 09: Troubleshooting Scenarios](labs/09-troubleshooting-scenarios/README.md) |
| Cluster health checks | [diagnostic tools](labs/09-troubleshooting-scenarios/diagnostic-tools/README.md) |
| Connectivity checks | [diagnostic tools](labs/09-troubleshooting-scenarios/diagnostic-tools/README.md) |
| Log collection | [diagnostic tools](labs/09-troubleshooting-scenarios/diagnostic-tools/README.md) |
| Resource inspection | [diagnostic tools](labs/09-troubleshooting-scenarios/diagnostic-tools/README.md) |

## Common Paths

1. First-time learner: [Learning Paths](LEARNING-PATHS.md) -> [Lab 01](labs/01-standard-deployment/README.md) -> [Lab 02](labs/02-airgapped-deployment/README.md).
2. Customer POC: [Account Strategy](pre-sales/account-strategy.md) -> [Lab 05](labs/05-poc-sprint/README.md) -> [Handoff Runbooks](labs/08-handoff-runbooks/README.md).
3. Locked-down enterprise install: [Provider Comparison](docs/02-multi-cloud/provider-comparison.md) -> [Lab 03](labs/03-private-network-deployment/README.md) -> [Lab 04](labs/04-firewall-restricted-deployment/README.md).
4. Platform foundation: [Modules](modules/README.md) -> [Lab 06](labs/06-multi-tenant-deployment/README.md) -> [Lab 07](labs/07-integration-patterns/README.md).

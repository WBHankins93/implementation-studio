# Implementation Studio Learning Paths

Use these paths to move through the repo without reading everything at once. Each path links to labs and docs that are already present in this repository.

## Complete Implementation Path

For a broad understanding of the deployment patterns:

1. [Lab 01: Standard Deployment](labs/01-standard-deployment/README.md)
2. [Lab 02: Air-Gapped Deployment](labs/02-airgapped-deployment/README.md)
3. [Lab 03: Private Network Deployment](labs/03-private-network-deployment/README.md)
4. [Lab 04: Firewall-Restricted Deployment](labs/04-firewall-restricted-deployment/README.md)
5. [Lab 05: POC Sprint](labs/05-poc-sprint/README.md)
6. [Lab 06: Multi-Tenant Deployment](labs/06-multi-tenant-deployment/README.md)
7. [Lab 07: Integration Patterns](labs/07-integration-patterns/README.md)
8. [Lab 08: Handoff and Runbooks](labs/08-handoff-runbooks/README.md)
9. [Lab 09: Troubleshooting Scenarios](labs/09-troubleshooting-scenarios/README.md)

## Fast Track: Customer Constraints

For the patterns most likely to appear in locked-down enterprise implementations:

1. [Lab 02: Air-Gapped Deployment](labs/02-airgapped-deployment/README.md)
2. [Lab 03: Private Network Deployment](labs/03-private-network-deployment/README.md)
3. [Lab 04: Firewall-Restricted Deployment](labs/04-firewall-restricted-deployment/README.md)
4. [Lab 09: Troubleshooting Scenarios](labs/09-troubleshooting-scenarios/README.md)

## Solutions Engineer Path

For POC, account, handoff, and customer-facing implementation work:

1. [SE Integration Guide](docs/se-integration.md)
2. [Lab 05: POC Sprint](labs/05-poc-sprint/README.md)
3. [Account Strategy](pre-sales/account-strategy.md)
4. [Multi-Workstream Engagements](engagements/multi-workstream.md)
5. [Lab 08: Handoff and Runbooks](labs/08-handoff-runbooks/README.md)
6. [Product Feedback](internal/product-feedback.md)
7. [Tracking Impact](internal/tracking-impact.md)

## Platform Engineer Path

For infrastructure, shared platforms, and operational patterns:

1. [Provider Comparison](docs/02-multi-cloud/provider-comparison.md)
2. [Modules Catalog](modules/README.md)
3. [Lab 01: Standard Deployment](labs/01-standard-deployment/README.md)
4. [Lab 03: Private Network Deployment](labs/03-private-network-deployment/README.md)
5. [Lab 06: Multi-Tenant Deployment](labs/06-multi-tenant-deployment/README.md)
6. [Lab 07: Integration Patterns](labs/07-integration-patterns/README.md)
7. [Lab 08: Handoff and Runbooks](labs/08-handoff-runbooks/README.md)

## Cost-Conscious Path

For local practice with little or no cloud spend:

1. [Lab 02: Air-Gapped Deployment](labs/02-airgapped-deployment/README.md)
2. [Lab 05: POC Sprint](labs/05-poc-sprint/README.md)
3. [Lab 06: Multi-Tenant Deployment](labs/06-multi-tenant-deployment/README.md)
4. [Lab 09: Troubleshooting Scenarios](labs/09-troubleshooting-scenarios/README.md)

## Prerequisites By Lab

| Lab | Primary prerequisites |
| --- | --- |
| Lab 01 | Terraform, kubectl, Helm, GCP or AWS account |
| Lab 02 | Docker, Kind, Helm, kubectl, about 10GB disk space |
| Lab 03 | Lab 01 baseline plus private networking concepts |
| Lab 04 | Lab 01 baseline plus network policy and egress concepts |
| Lab 05 | Kind for local mode, or minimal GCP/AWS setup |
| Lab 06 | Kind, GCP, or AWS plus namespace/RBAC basics |
| Lab 07 | GCP or AWS plus OAuth/OIDC and database concepts |
| Lab 08 | Existing cluster or Kind plus monitoring basics |
| Lab 09 | Kind and kubectl |

## Next Step

After choosing a path, open [labs/README.md](labs/README.md) for a side-by-side lab comparison and then follow the README inside the first lab.

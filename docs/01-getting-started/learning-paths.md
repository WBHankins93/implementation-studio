# Learning Paths

Implementation Studio offers multiple learning paths depending on your goals and experience level.

## Recommended Path: Complete Journey

For a comprehensive understanding of deployment patterns:

1. **Lab 01: Standard Deployment** - Establish baseline (GCP or AWS)
2. **Lab 02: Air-Gapped Deployment** - Learn offline deployment
3. **Lab 03: Private Network Deployment** - Private cluster patterns
4. **Lab 04: Firewall-Restricted Deployment** - Working with security constraints
5. **Lab 05: The POC Sprint** - Customer engagement patterns
6. **Lab 06: Multi-Tenant Deployment** - Isolation and resource management
7. **Lab 07: Integration Patterns** - External integrations
8. **Lab 08: Handoff and Runbooks** - Operational readiness
9. **Lab 09: Troubleshooting Scenarios** - Debugging skills

**Time Estimate:** 108-133 hours (~3-4 weeks at focused pace)

## Fast Track: Core Constraints

If you need to understand constraints quickly:

1. **Lab 02: Air-Gapped Deployment** - Most differentiated content
2. **Lab 03: Private Network Deployment** - Private cluster patterns
3. **Lab 04: Firewall-Restricted Deployment** - Security constraints
4. **Lab 09: Troubleshooting Scenarios** - Debugging skills

**Time Estimate:** 40-50 hours (~1 week)

## Solutions Engineer Path

Focused on customer engagement skills:

1. **Lab 01: Standard Deployment** - Baseline understanding (GCP or AWS)
2. **Lab 05: The POC Sprint** - POC frameworks and templates
3. **Lab 06: Multi-Tenant Deployment** - Customer isolation patterns
4. **Lab 08: Handoff and Runbooks** - Customer handoff process
5. **Lab 09: Troubleshooting Scenarios** - Customer support skills

Plus field guidance:
- [SE Integration Guide](../se-integration.md)
- [POC Sprint templates](../../labs/05-poc-sprint/templates/)
- [Account Strategy](../../pre-sales/account-strategy.md)
- [Multi-Workstream Engagements](../../engagements/multi-workstream.md)
- [Handoff and Runbooks](../../labs/08-handoff-runbooks/README.md)

**Time Estimate:** 50-60 hours (~1.5 weeks)

## Platform Engineer Path

Focused on infrastructure and operations:

1. **Lab 01: Standard Deployment** - Foundation (GCP or AWS)
2. **Lab 03: Private Network Deployment** - Network architecture
3. **Lab 04: Firewall-Restricted Deployment** - Security architecture
4. **Lab 06: Multi-Tenant Deployment** - Resource management
5. **Lab 07: Integration Patterns** - System integration
6. **Lab 08: Handoff and Runbooks** - Operational patterns
7. **Lab 09: Troubleshooting Scenarios** - Operations skills

**Time Estimate:** 70-85 hours (~2 weeks)

## Cost-Conscious Path

All local, no cloud costs:

1. **Lab 02: Air-Gapped Deployment** - Fully local
2. **Lab 05: The POC Sprint** - Can use Kind
3. **Lab 06: Multi-Tenant Deployment** - Fully local with Kind
4. **Lab 09: Troubleshooting Scenarios** - Fully local

**Time Estimate:** 30-40 hours (~1 week)
**Cost:** $0

## Prerequisites by Lab

### Lab 01: Standard Deployment
- **GCP:** GCP account with billing, gcloud CLI configured
- **AWS:** AWS account with permissions, aws CLI configured
- **Both:** Terraform, kubectl, Helm

### Lab 02: Air-Gapped Deployment
- Docker, Kind
- Helm 3
- ~10GB disk space
- **No cloud account needed**

### Lab 03: Private Network Deployment
- Same as Lab 01 (GCP or AWS)
- Understanding of Lab 01 baseline

### Lab 04: Firewall-Restricted Deployment
- Same as Lab 01 (GCP or AWS)
- Understanding of network policies

### Lab 05: The POC Sprint
- **Kind** (recommended, no cloud needed)
- **GCP:** Minimal GCP setup
- **AWS:** Minimal AWS setup

### Lab 06: Multi-Tenant Deployment
- **Kind** (recommended, no cloud needed)
- **GCP:** GCP account
- **AWS:** AWS account
- Understanding of namespaces and RBAC

### Lab 07: Integration Patterns
- **GCP:** GCP account (for Cloud SQL)
- **AWS:** AWS account (for RDS)
- Understanding of OAuth/OIDC basics

### Lab 08: Handoff and Runbooks
- **Kind, GCP, or AWS** (cloud-agnostic)
- Understanding of monitoring basics

### Lab 09: Troubleshooting Scenarios
- Kind cluster
- **No cloud account needed**

## Customizing Your Path

Feel free to:
- Skip labs that don't apply to your role
- Focus on specific constraint types
- Use labs as reference material
- Adapt patterns to your use case

The labs are designed to be modular - use what's relevant to you.

---

Choose the path that matches your goals and constraints!

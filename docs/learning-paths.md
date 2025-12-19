# Learning Paths

Implementation Studio offers multiple learning paths depending on your goals and experience level.

## Recommended Path: Complete Journey

For a comprehensive understanding of deployment patterns:

1. **Lab 01: Standard GKE Deployment** - Establish baseline
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

1. **Lab 01: Standard GKE Deployment** - Baseline understanding
2. **Lab 05: The POC Sprint** - POC frameworks and templates
3. **Lab 06: Multi-Tenant Deployment** - Customer isolation patterns
4. **Lab 08: Handoff and Runbooks** - Customer handoff process
5. **Lab 09: Troubleshooting Scenarios** - Customer support skills

Plus documentation in `docs/for-ses/`:
- Using labs in engagements
- Discovery frameworks
- Scoping POCs
- Customer handoff

**Time Estimate:** 50-60 hours (~1.5 weeks)

## Platform Engineer Path

Focused on infrastructure and operations:

1. **Lab 01: Standard GKE Deployment** - Foundation
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

### Lab 01: Standard GKE Deployment
- GCP account with billing
- gcloud CLI configured
- Terraform, kubectl, Helm

### Lab 02: Air-Gapped Deployment
- Docker, Kind
- Helm 3
- ~10GB disk space
- **No cloud account needed**

### Lab 03: Private Network Deployment
- Same as Lab 01
- Understanding of Lab 01 baseline

### Lab 04: Firewall-Restricted Deployment
- Same as Lab 01
- Understanding of network policies

### Lab 05: The POC Sprint
- Can use Kind (no cloud needed)
- Or minimal GCP setup

### Lab 06: Multi-Tenant Deployment
- Kind or GKE
- Understanding of namespaces and RBAC

### Lab 07: Integration Patterns
- GCP account (for Cloud SQL)
- Understanding of OAuth/OIDC basics

### Lab 08: Handoff and Runbooks
- Kind or GKE
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


# Lab 05: The POC Sprint

## Learning Objectives

By completing this lab, you will:

- Scope a time-boxed proof of concept effectively
- Define measurable success criteria
- Deploy minimal viable infrastructure quickly (Kind, GCP, or AWS)
- Prepare and deliver effective demos
- Document outcomes for stakeholders
- Handle common POC challenges and questions

## Prerequisites

### Common Prerequisites
- Terraform >= 1.5 (for cloud deployments)
- `kubectl` installed
- Helm 3.x installed
- Basic understanding of Kubernetes concepts

### GCP Prerequisites (if using GCP)
- GCP project with billing enabled
- `gcloud` CLI configured

### AWS Prerequisites (if using AWS)
- AWS account with appropriate permissions
- `aws` CLI configured

### Local Prerequisites (if using Kind)
- Docker installed
- Kind installed (`brew install kind`)

## What is a POC?

A **Proof of Concept (POC)** is a time-boxed demonstration that validates whether a solution works in a customer's environment. Unlike a full implementation, a POC:

- **Focuses on core functionality** - Not every feature
- **Uses minimal infrastructure** - Fast to deploy, easy to clean up
- **Has clear success criteria** - Everyone knows what "success" means
- **Is time-boxed** - Usually 1-4 weeks
- **Produces a decision** - Go/no-go for full implementation

## Deployment Options

This lab supports **three deployment options** for POCs:

### Option 1: Kind (Local, Zero Cost) ⭐ Recommended for Learning

**Best for:** Learning, testing, zero-cost POCs

**Pros:**
- ✅ Zero cost
- ✅ Fastest deployment (~2 minutes)
- ✅ No cloud account needed
- ✅ Perfect for local testing

**Cons:**
- ❌ Not representative of real cloud environment
- ❌ Limited to local machine resources

**Quick Start:**
```bash
# Just run the script - it will detect no terraform.tfvars and use Kind
./scripts/quick-deploy.sh
```

### Option 2: GCP (Cloud, Minimal Cost)

**Best for:** Real POCs in GCP environments

**Pros:**
- ✅ Real cloud environment
- ✅ Fast deployment (~5-10 minutes)
- ✅ Minimal cost (~$0-5/day)
- ✅ Easy cleanup

**Cons:**
- ❌ Requires GCP account
- ❌ Small cost

**Quick Start:**
```bash
cd minimal-deployment
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars: set cloud_provider = "gcp" and project_id
cd ..
./scripts/quick-deploy.sh
```

### Option 3: AWS (Cloud, Minimal Cost)

**Best for:** Real POCs in AWS environments

**Pros:**
- ✅ Real cloud environment
- ✅ Fast deployment (~10-15 minutes)
- ✅ Minimal cost (~$0-5/day)
- ✅ Easy cleanup

**Cons:**
- ❌ Requires AWS account
- ❌ Small cost

**Quick Start:**
```bash
cd minimal-deployment
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars: set cloud_provider = "aws" and region
cd ..
./scripts/quick-deploy.sh
```

## Quick Start

### Recommended: Use Quick Deploy Script

The `quick-deploy.sh` script automatically detects your deployment method:

```bash
cd labs/05-poc-sprint

# If no terraform.tfvars exists, it will use Kind (zero cost)
# If terraform.tfvars exists, it will use the cloud provider specified
./scripts/quick-deploy.sh
```

### Manual: Cloud Deployment

```bash
cd minimal-deployment
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your cloud provider settings

# Deploy
terraform init
terraform apply

# Get credentials
terraform output get_credentials_command
# Run the output command

# Deploy Argo Workflows
helm repo add argo https://argoproj.github.io/argo-helm
helm install argo-workflows argo/argo-workflows --namespace argo --create-namespace
```

### Prepare Demo

```bash
./scripts/prepare-demo.sh
```

## Lab Structure

```
labs/05-poc-sprint/
├── templates/              # POC planning templates
│   ├── poc-scope-document.md
│   ├── success-criteria.md
│   ├── daily-standup-format.md
│   └── final-report-template.md
├── minimal-deployment/     # Fast infrastructure deployment
│   ├── main.tf            # Supports GCP and AWS
│   ├── variables.tf
│   └── terraform.tfvars.example
├── manifests/              # Demo workflows
│   ├── demo-workflow-simple.yaml
│   ├── demo-workflow-multistep.yaml
│   └── demo-workflow-parallel.yaml
├── demo-prep/              # Demo preparation materials
│   ├── demo-script.md
│   ├── backup-demo.md
│   └── common-questions.md
└── scripts/                # Automation scripts
    ├── quick-deploy.sh     # Supports Kind, GCP, and AWS
    ├── prepare-demo.sh
    └── cleanup.sh
```

## Key Deliverables

### 1. POC Scope Document

Use `templates/poc-scope-document.md` to define:
- Objectives (primary and secondary)
- Scope (in and out of scope)
- Success criteria
- Timeline
- Resources needed

### 2. Success Criteria Framework

Use `templates/success-criteria.md` to define:
- Must-have criteria (POC fails without these)
- Should-have criteria (important but not blocking)
- Nice-to-have criteria (if time permits)

### 3. Demo Materials

- **Demo Script**: Step-by-step demo flow (`demo-prep/demo-script.md`)
- **Backup Demo**: Plan B if live demo fails (`demo-prep/backup-demo.md`)
- **Common Questions**: Prepared answers (`demo-prep/common-questions.md`)

### 4. Final Report

Use `templates/final-report-template.md` to document:
- What was accomplished
- Success criteria results
- Lessons learned
- Recommendations
- Next steps

## POC Best Practices

### Scoping

✅ **Start Small**: Focus on core functionality
✅ **Be Specific**: Clear objectives and success criteria
✅ **Time-Box**: Set a deadline and stick to it
✅ **Document Everything**: Scope, decisions, outcomes

### Execution

✅ **Deploy Quickly**: Use minimal infrastructure
✅ **Test Early**: Validate assumptions quickly
✅ **Communicate Often**: Daily standups, regular updates
✅ **Stay Focused**: Resist scope creep

### Demo

✅ **Prepare Thoroughly**: Test everything beforehand
✅ **Have Backup Plan**: Screenshots, videos, architecture discussion
✅ **Engage Audience**: Ask questions, check understanding
✅ **Be Honest**: Acknowledge limitations

### Documentation

✅ **Document Outcomes**: What worked, what didn't
✅ **Capture Lessons**: What would you do differently?
✅ **Provide Recommendations**: Clear next steps
✅ **Share Knowledge**: Help others learn

## Deployment Comparison

| Feature | Kind | GCP | AWS |
|---------|------|-----|-----|
| **Cost** | $0 | ~$0-5/day | ~$0-5/day |
| **Deployment Time** | ~2 min | ~5-10 min | ~10-15 min |
| **Setup Complexity** | Low | Medium | Medium |
| **Real Cloud Environment** | ❌ | ✅ | ✅ |
| **Best For** | Learning | GCP POCs | AWS POCs |

### When to Use Each

**Kind (Local):**
- Learning and testing
- Zero-cost requirement
- Fast iteration
- No cloud account needed

**GCP:**
- Customer uses GCP
- Need real cloud environment
- Quick POC deployment
- Minimal cost acceptable

**AWS:**
- Customer uses AWS
- Need real cloud environment
- Quick POC deployment
- Minimal cost acceptable

## Estimated Time

**Infrastructure Deployment:**
- Kind: ~2 minutes
- GCP: ~5-10 minutes
- AWS: ~10-15 minutes

**Demo Preparation**: 30-60 minutes
**POC Planning**: 1-2 hours (using templates)
**Total Lab Time**: 2-3 hours

## Estimated Cost

**Kind Option**: $0 (local deployment)
**GCP Option**: $0-5 per day (minimal resources, destroy quickly)
**AWS Option**: $0-5 per day (minimal resources, destroy quickly)

**Cost Breakdown (Cloud):**
- Cluster: ~$0.10/hour
- Nodes: ~$0.05-0.10/hour per node
- Load balancer: ~$0.025/hour
- **Total**: ~$0.20-0.30/hour = ~$5-7/day if running 24/7

**Tip:** Destroy resources immediately after POC to minimize costs.

## Documentation

- [Scoping Guide](./docs/scoping-guide.md) - How to scope a POC effectively
- [Demo Guide](./docs/demo-guide.md) - Comprehensive demo preparation and delivery
- [Troubleshooting](./docs/troubleshooting.md) - Common POC issues and solutions
- [Step-by-Step Guide](./docs/step-by-step.md) - Detailed walkthrough

## Templates

- [POC Scope Document](./templates/poc-scope-document.md)
- [Success Criteria Framework](./templates/success-criteria.md)
- [Daily Standup Format](./templates/daily-standup-format.md)
- [Final Report Template](./templates/final-report-template.md)

## Demo Materials

- [Demo Script](./demo-prep/demo-script.md)
- [Backup Demo Plan](./demo-prep/backup-demo.md)
- [Common Questions](./demo-prep/common-questions.md)

## Cleanup

### Kind
```bash
kind delete cluster --name poc-cluster
```

### Cloud (GCP or AWS)
```bash
./scripts/cleanup.sh
```

Or manually:
```bash
cd minimal-deployment
terraform destroy
```

**Important:** Always clean up POC resources immediately to minimize costs!

## Next Steps

After completing this lab:

1. Practice scoping a POC using the templates
2. Prepare a demo using the demo materials
3. Review the common questions and prepare answers
4. Try deploying with different providers (Kind, GCP, AWS)
5. Proceed to Lab 06: Multi-Tenant Deployment

## Additional Resources

- [POC Best Practices](https://www.atlassian.com/agile/project-management/epics-stories-themes/proof-of-concept)
- [Demo Best Practices](https://www.gartner.com/en/articles/demo-best-practices)
- [Stakeholder Communication](https://www.pmi.org/learning/library/effective-stakeholder-communication-7905)

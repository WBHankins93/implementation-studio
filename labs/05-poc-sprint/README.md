# Lab 05: The POC Sprint

## Learning Objectives

By completing this lab, you will:

- Scope a time-boxed proof of concept effectively
- Define measurable success criteria
- Deploy minimal viable infrastructure quickly
- Prepare and deliver effective demos
- Document outcomes for stakeholders
- Handle common POC challenges and questions

## Prerequisites

- GCP project with billing enabled (or use Kind for zero-cost option)
- `gcloud` CLI configured (if using GCP)
- Terraform >= 1.5
- `kubectl` installed
- Helm 3.x installed
- Basic understanding of Kubernetes concepts

## What is a POC?

A **Proof of Concept (POC)** is a time-boxed demonstration that validates whether a solution works in a customer's environment. Unlike a full implementation, a POC:

- **Focuses on core functionality** - Not every feature
- **Uses minimal infrastructure** - Fast to deploy, easy to clean up
- **Has clear success criteria** - Everyone knows what "success" means
- **Is time-boxed** - Usually 1-4 weeks
- **Produces a decision** - Go/no-go for full implementation

## Quick Start

### Option 1: GCP Deployment (Recommended for Real POC)

```bash
cd labs/05-poc-sprint/minimal-deployment
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your GCP project ID

# Quick deploy everything
cd ..
./scripts/quick-deploy.sh
```

### Option 2: Local Deployment (Zero Cost)

```bash
# Use Kind cluster (see Lab 02 for reference)
kind create cluster --name poc-cluster

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
│   ├── main.tf
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
    ├── quick-deploy.sh
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

## Estimated Time

**Infrastructure Deployment**: 10-15 minutes
**Demo Preparation**: 30-60 minutes
**POC Planning**: 1-2 hours (using templates)
**Total Lab Time**: 2-3 hours

## Estimated Cost

**GCP Option**: $0-5 per day (minimal resources, destroy quickly)
**Local Option**: $0 (using Kind)

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

To destroy all resources:

```bash
./scripts/cleanup.sh
```

Or manually:

```bash
cd minimal-deployment
terraform destroy
```

## Next Steps

After completing this lab:

1. Practice scoping a POC using the templates
2. Prepare a demo using the demo materials
3. Review the common questions and prepare answers
4. Proceed to Lab 06: Multi-Tenant Deployment

## Additional Resources

- [POC Best Practices](https://www.atlassian.com/agile/project-management/epics-stories-themes/proof-of-concept)
- [Demo Best Practices](https://www.gartner.com/en/articles/demo-best-practices)
- [Stakeholder Communication](https://www.pmi.org/learning/library/effective-stakeholder-communication-7905)


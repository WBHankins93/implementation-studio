# Lab 05: Step-by-Step Guide

## Overview

This guide walks you through completing Lab 05: The POC Sprint, from initial scoping to final demo.

## Phase 1: Planning (1-2 hours)

### Step 1: Scope the POC

1. **Review templates:**
   ```bash
   cd labs/05-poc-sprint
   ls templates/
   ```

2. **Fill out scope document:**
   - Open `templates/poc-scope-document.md`
   - Fill in all sections
   - Define objectives
   - Set scope boundaries

3. **Define success criteria:**
   - Open `templates/success-criteria.md`
   - Define must-have criteria
   - Define should-have criteria
   - Define nice-to-have criteria

4. **Get stakeholder approval:**
   - Share scope document
   - Get sign-off
   - Set expectations

### Step 2: Prepare Demo Materials

1. **Review demo script:**
   - Open `demo-prep/demo-script.md`
   - Customize for your POC
   - Practice the flow

2. **Prepare backup demo:**
   - Review `demo-prep/backup-demo.md`
   - Prepare screenshots
   - Prepare architecture diagrams

3. **Review common questions:**
   - Open `demo-prep/common-questions.md`
   - Prepare your answers
   - Practice responses

## Phase 2: Deployment (15-30 minutes)

### Step 3: Deploy Infrastructure

**Option A: GCP Deployment**

```bash
cd labs/05-poc-sprint/minimal-deployment
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your project ID

cd ..
./scripts/quick-deploy.sh
```

**Option B: Local Deployment (Kind)**

```bash
# Create Kind cluster
kind create cluster --name poc-cluster

# Deploy Argo Workflows
helm repo add argo https://argoproj.github.io/argo-helm
helm install argo-workflows argo/argo-workflows \
  --namespace argo \
  --create-namespace \
  --wait
```

### Step 4: Verify Deployment

```bash
# Check cluster
kubectl get nodes

# Check Argo Workflows
kubectl get pods -n argo

# Check services
kubectl get svc -n argo
```

### Step 5: Deploy Demo Workflows

```bash
# Deploy all demo workflows
kubectl apply -f manifests/

# Verify workflows
kubectl get workflows -n argo
```

## Phase 3: Preparation (30-60 minutes)

### Step 6: Prepare Demo Environment

```bash
./scripts/prepare-demo.sh
```

This will:
- Verify Argo Workflows is running
- Deploy demo workflows
- Set up demo namespace
- Provide access information

### Step 7: Test Demo Workflows

1. **Access Argo UI:**
   ```bash
   kubectl port-forward -n argo svc/argo-workflows-server 2746:2746
   ```
   Open: http://localhost:2746

2. **Test each workflow:**
   - Submit simple workflow
   - Submit multi-step workflow
   - Submit parallel workflow

3. **Verify everything works:**
   - All workflows execute
   - Logs are accessible
   - UI displays correctly

### Step 8: Prepare Backup Materials

1. **Take screenshots:**
   - Argo UI dashboard
   - Workflow executions
   - Architecture diagrams

2. **Prepare architecture discussion:**
   - Review architecture
   - Prepare talking points
   - Prepare diagrams

3. **Test backup demo:**
   - Practice with screenshots
   - Practice architecture discussion
   - Ensure materials are ready

## Phase 4: Execution (1-2 weeks)

### Step 9: Daily Standups

Use `templates/daily-standup-format.md`:

1. **What did you accomplish yesterday?**
2. **What will you do today?**
3. **Any blockers?**

### Step 10: Track Progress

1. **Update success criteria:**
   - Track must-have criteria
   - Track should-have criteria
   - Document nice-to-have

2. **Document issues:**
   - Track problems
   - Document solutions
   - Update stakeholders

3. **Adjust if needed:**
   - Scope adjustments
   - Timeline adjustments
   - Resource adjustments

## Phase 5: Demo (15-30 minutes)

### Step 11: Deliver Demo

Follow `demo-prep/demo-script.md`:

1. **Introduction** (2 min)
2. **Architecture Overview** (3 min)
3. **Simple Workflow** (3 min)
4. **Multi-Step Workflow** (4 min)
5. **Parallel Workflow** (4 min)
6. **Q&A** (3-5 min)

### Step 12: Handle Questions

Use `demo-prep/common-questions.md`:

- Answer technical questions
- Address business concerns
- Discuss next steps

### Step 13: Follow Up

1. **Send materials:**
   - Demo recording
   - Architecture diagrams
   - Documentation

2. **Answer questions:**
   - Respond to outstanding questions
   - Provide additional information

3. **Schedule next steps:**
   - Based on demo feedback
   - Address concerns
   - Plan implementation

## Phase 6: Documentation (1-2 hours)

### Step 14: Create Final Report

Use `templates/final-report-template.md`:

1. **Executive Summary**
2. **What Was Accomplished**
3. **Success Criteria Results**
4. **Lessons Learned**
5. **Recommendations**
6. **Next Steps**

### Step 15: Share Outcomes

1. **Distribute report:**
   - Send to stakeholders
   - Share with team
   - Archive for future reference

2. **Present findings:**
   - Present to decision makers
   - Answer questions
   - Discuss recommendations

3. **Plan next steps:**
   - Based on outcomes
   - Address recommendations
   - Plan implementation (if approved)

## Phase 7: Cleanup (5 minutes)

### Step 16: Clean Up Resources

```bash
./scripts/cleanup.sh
```

Or manually:

```bash
cd minimal-deployment
terraform destroy
```

## Tips for Success

### Planning

✅ Start with clear problem statement
✅ Define specific objectives
✅ Set realistic timeline
✅ Get stakeholder buy-in

### Execution

✅ Deploy quickly
✅ Test early and often
✅ Communicate regularly
✅ Stay focused on scope

### Demo

✅ Practice beforehand
✅ Have backup plan
✅ Engage audience
✅ Be honest about limitations

### Documentation

✅ Document everything
✅ Capture lessons learned
✅ Provide clear recommendations
✅ Share knowledge

## Common Pitfalls

### Pitfall 1: Scope Too Broad

**Problem:** Trying to prove everything
**Solution:** Focus on 2-3 core objectives

### Pitfall 2: No Success Criteria

**Problem:** Unclear what success means
**Solution:** Define measurable criteria upfront

### Pitfall 3: Poor Communication

**Problem:** Stakeholders don't know status
**Solution:** Regular updates, daily standups

### Pitfall 4: No Backup Plan

**Problem:** Demo fails, no recovery
**Solution:** Always have backup materials

### Pitfall 5: Incomplete Documentation

**Problem:** Can't remember what happened
**Solution:** Document as you go

## Additional Resources

- [Scoping Guide](./scoping-guide.md)
- [Demo Guide](./demo-guide.md)
- [Troubleshooting](./troubleshooting.md)
- [Templates](../templates/)


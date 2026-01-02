# POC Scoping Guide

## Overview

Proper scoping is critical for POC success. This guide helps you define a focused, achievable POC that delivers value and leads to a clear decision.

## Why Scope Matters

**Poor Scoping Leads To:**
- Scope creep
- Missed deadlines
- Unclear outcomes
- Wasted resources
- Unhappy stakeholders

**Good Scoping Leads To:**
- Clear objectives
- Achievable timeline
- Measurable outcomes
- Focused effort
- Clear decision point

## Scoping Process

### Step 1: Understand the Problem

**Questions to Ask:**
- What problem are we solving?
- Why is this important now?
- What happens if we don't solve it?
- Who is affected?

**Output:**
- Problem statement
- Business context
- Stakeholder list

### Step 2: Define Objectives

**Primary Objectives** (Must achieve):
- Core functionality to validate
- Key integration points
- Critical performance metrics

**Secondary Objectives** (Should achieve):
- Additional features
- Nice-to-have integrations
- Enhanced metrics

**Output:**
- Prioritized objective list
- Clear success criteria

### Step 3: Define Scope

**In Scope:**
- What will be included
- What will be demonstrated
- What will be tested

**Out of Scope:**
- What will NOT be included
- What's deferred to production
- What's explicitly excluded

**Output:**
- Clear scope boundaries
- Stakeholder alignment

### Step 4: Set Timeline

**Consider:**
- Complexity of objectives
- Resource availability
- Stakeholder schedules
- Decision deadlines

**Typical POC Timelines:**
- Simple: 1 week
- Medium: 2-3 weeks
- Complex: 4 weeks

**Output:**
- Start date
- End date
- Key milestones

### Step 5: Define Success Criteria

**Must-Have** (POC fails without these):
- Critical functionality
- Core integrations
- Minimum performance

**Should-Have** (Important but not blocking):
- Additional features
- Enhanced performance
- Extra integrations

**Nice-to-Have** (If time permits):
- Polish
- Extra features
- Future considerations

**Output:**
- Measurable success criteria
- Clear pass/fail conditions

## Common Scoping Mistakes

### Mistake 1: Too Broad

**Problem:** Trying to prove everything
**Solution:** Focus on 2-3 core objectives

### Mistake 2: Too Narrow

**Problem:** Not enough to make a decision
**Solution:** Ensure core value is demonstrated

### Mistake 3: Unclear Success Criteria

**Problem:** No one knows what "success" means
**Solution:** Define measurable, testable criteria

### Mistake 4: No Timeline

**Problem:** POC drags on indefinitely
**Solution:** Set firm start and end dates

### Mistake 5: Ignoring Constraints

**Problem:** POC fails due to overlooked constraints
**Solution:** Identify constraints early

## Scoping Template

Use the [POC Scope Document Template](../templates/poc-scope-document.md) which includes:

1. **Executive Summary** - High-level overview
2. **Objectives** - Primary and secondary
3. **Scope** - In and out of scope
4. **Success Criteria** - Measurable outcomes
5. **Timeline** - Key dates and milestones
6. **Resources** - People, infrastructure, tools
7. **Risks** - Potential issues and mitigation
8. **Assumptions** - What we're assuming
9. **Constraints** - Limitations and restrictions

## Example: Well-Scoped POC

### Problem
Customer needs to validate that Argo Workflows can run their simulation workloads on their Kubernetes cluster.

### Objectives
**Primary:**
1. Deploy Argo Workflows to customer's GKE cluster
2. Execute sample simulation workflow end-to-end
3. Demonstrate workflow orchestration capabilities

**Secondary:**
1. Show integration with customer's authentication
2. Demonstrate monitoring and logging

### Scope
**In Scope:**
- Argo Workflows deployment
- Sample workflow execution
- Basic authentication integration
- Monitoring setup

**Out of Scope:**
- Production hardening
- Full security audit
- Performance optimization
- Complete integration

### Timeline
- **Week 1**: Infrastructure setup, basic deployment
- **Week 2**: Workflow execution, integration testing
- **Week 3**: Demo preparation, documentation

### Success Criteria
**Must-Have:**
- ✅ Argo Workflows deploys successfully
- ✅ Sample workflow executes without errors
- ✅ Workflow completes in < 10 minutes

**Should-Have:**
- ✅ Authentication integration works
- ✅ Monitoring displays metrics

## Getting Stakeholder Buy-In

### Present the Scope

1. **Problem Statement** - Why this POC?
2. **Objectives** - What will we prove?
3. **Scope** - What's included/excluded?
4. **Timeline** - When will we know?
5. **Success Criteria** - How do we measure success?

### Address Concerns

- **"Why not do everything?"** - Focus leads to clear outcomes
- **"This seems too small"** - We're proving core value, not building production
- **"What if it doesn't work?"** - That's valuable information too
- **"How long will this take?"** - Time-boxed, clear timeline

### Get Sign-Off

- Document scope in writing
- Get stakeholder approval
- Set expectations clearly
- Establish communication cadence

## Adjusting Scope

### When to Expand

- Core objective is too easy
- Stakeholders need more to decide
- Time permits additional work

### When to Contract

- Running behind schedule
- Hitting unexpected blockers
- Core objectives are sufficient

### How to Adjust

1. **Assess Impact** - What changes?
2. **Communicate** - Inform stakeholders
3. **Update Documentation** - Revise scope document
4. **Get Approval** - Confirm changes

## Best Practices

✅ **Start with Problem** - Understand why before what
✅ **Focus on Core** - 2-3 primary objectives max
✅ **Be Specific** - Vague scope = vague outcomes
✅ **Set Boundaries** - Clear in/out of scope
✅ **Define Success** - Measurable criteria
✅ **Time-Box** - Firm start and end dates
✅ **Document Everything** - Written scope = alignment
✅ **Get Sign-Off** - Stakeholder approval
✅ **Stay Flexible** - Adjust if needed, but document

## Additional Resources

- [POC Scope Document Template](../templates/poc-scope-document.md)
- [Success Criteria Framework](../templates/success-criteria.md)
- [Agile Scoping Techniques](https://www.atlassian.com/agile/project-management/epics-stories-themes)


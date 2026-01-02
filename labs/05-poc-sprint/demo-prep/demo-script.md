# POC Demo Script

## Pre-Demo Checklist

- [ ] Cluster is running and accessible
- [ ] Argo Workflows UI is accessible
- [ ] Demo workflows are deployed
- [ ] Backup demo plan is ready
- [ ] Screen sharing is working
- [ ] All browser tabs are ready

## Demo Flow (15-20 minutes)

### 1. Introduction (2 minutes)

**What to say:**
"Today I'll demonstrate [application name] running on Kubernetes. This POC shows how we can deploy and run workflows in your environment."

**What to show:**
- Argo Workflows UI
- Cluster overview

### 2. Architecture Overview (3 minutes)

**What to say:**
"Let me show you the architecture we've deployed..."

**What to show:**
- Kubernetes cluster
- Namespaces
- Argo Workflows components
- Network configuration (if relevant)

**Key points:**
- Minimal infrastructure
- Production-ready patterns
- Scalable architecture

### 3. Simple Workflow Demo (3 minutes)

**What to say:**
"Let's start with a simple workflow to show the basics..."

**What to do:**
1. Navigate to Argo UI
2. Submit `demo-simple-workflow`
3. Show workflow execution
4. Show logs/output

**Key points:**
- Easy to submit workflows
- Real-time status
- Detailed logs

### 4. Multi-Step Workflow (4 minutes)

**What to say:**
"Now let's see a more complex workflow with multiple steps..."

**What to do:**
1. Submit `demo-multistep-workflow`
2. Show step-by-step execution
3. Show dependencies
4. Show final completion

**Key points:**
- Sequential execution
- Step dependencies
- Error handling (if applicable)

### 5. Parallel Workflow (4 minutes)

**What to say:**
"For compute-intensive tasks, we can run steps in parallel..."

**What to do:**
1. Submit `demo-parallel-workflow`
2. Show parallel execution
3. Show aggregation step
4. Compare execution time

**Key points:**
- Parallel execution
- Resource efficiency
- Scalability

### 6. Q&A and Next Steps (3-5 minutes)

**What to say:**
"Any questions? Let's discuss next steps..."

**Be ready to discuss:**
- Production deployment
- Integration points
- Performance considerations
- Security requirements
- Timeline

## Demo Tips

### Do's

✅ **Start with the simple example** - Build complexity gradually
✅ **Show the UI** - Visual demonstrations are powerful
✅ **Explain what you're doing** - Don't assume they understand
✅ **Handle errors gracefully** - If something fails, explain why
✅ **Keep it focused** - Stay within scope
✅ **Engage the audience** - Ask questions, check understanding

### Don'ts

❌ **Don't rush** - Take time to explain
❌ **Don't skip steps** - Show the full process
❌ **Don't assume knowledge** - Explain Kubernetes/Argo concepts
❌ **Don't ignore errors** - Address issues immediately
❌ **Don't go off-script** - Stay within POC scope
❌ **Don't oversell** - Be honest about limitations

## Common Demo Scenarios

### Scenario 1: Everything Works Perfectly

**Flow:**
1. Follow script as written
2. Show all workflows successfully
3. Highlight key features
4. Move to Q&A

### Scenario 2: Minor Issues

**If a workflow takes longer than expected:**
- "This is normal for first execution as images are being pulled"
- Show other workflows while waiting
- Explain what's happening

**If a workflow fails:**
- "Let me show you the error handling..."
- Check logs
- Explain the issue
- Show how to fix it

### Scenario 3: Major Issues

**If cluster is down:**
- Switch to backup demo (screenshots/video)
- Explain what would happen
- Discuss architecture instead

**If UI is inaccessible:**
- Use CLI to show workflows
- Explain what they'd see in UI
- Show logs directly

## Backup Demo Plan

If live demo fails:

1. **Screenshots/Videos**
   - Pre-recorded workflow executions
   - Architecture diagrams
   - UI screenshots

2. **Architecture Discussion**
   - Walk through architecture
   - Discuss deployment patterns
   - Answer technical questions

3. **Reschedule**
   - If critical issues
   - Offer to reschedule
   - Provide documentation

## Post-Demo

### Immediate Follow-up

- Send demo recording (if recorded)
- Share architecture diagrams
- Provide access to cluster (if appropriate)
- Answer any outstanding questions

### Documentation to Share

- Architecture overview
- Deployment guide
- Workflow examples
- Next steps document

## Notes Section

_Use this space to note customer-specific points, questions asked, or follow-up items:_

- 
- 
- 


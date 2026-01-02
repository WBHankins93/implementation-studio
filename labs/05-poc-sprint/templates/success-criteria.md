# Success Criteria Framework

## Overview

This framework helps you define clear, measurable success criteria for POCs. Use it to ensure everyone understands what "success" means before the POC begins.

---

## Framework Structure

### 1. Must-Have Criteria (POC Fails Without These)

These are non-negotiable. If any of these fail, the POC is considered unsuccessful.

**Characteristics:**
- Critical to core functionality
- Directly related to primary objectives
- Measurable and testable
- Cannot be worked around

**Example:**
- ✅ "Application deploys successfully to customer's Kubernetes cluster"
- ✅ "Workflow executes end-to-end without errors"
- ✅ "Integration with customer's authentication system works"
- ❌ "Application is fast" (too vague)
- ❌ "Users like it" (not measurable)

### 2. Should-Have Criteria (Important but Not Blocking)

These are important for a complete solution but won't cause POC failure if missing.

**Characteristics:**
- Enhances the solution
- Shows additional value
- Nice to demonstrate
- Can be deferred if needed

**Example:**
- "Dashboard displays real-time metrics"
- "Workflow completes in under 5 minutes"
- "Integration supports batch processing"

### 3. Nice-to-Have Criteria (If Time Permits)

These are bonus features that add polish but aren't essential.

**Characteristics:**
- Extra features
- Polish and refinement
- Future considerations
- Low priority

**Example:**
- "Custom branding applied"
- "Advanced filtering options"
- "Export functionality"

---

## Writing Good Success Criteria

### Use SMART Criteria

- **Specific**: Clear and unambiguous
- **Measurable**: Can be tested/verified
- **Achievable**: Realistic for POC timeline
- **Relevant**: Aligned with objectives
- **Time-bound**: Can be validated within POC duration

### Good Examples

✅ **Specific and Measurable:**
- "Workflow processes 1000 records in under 10 minutes"
- "Application authenticates users via customer's SAML provider"
- "Dashboard loads in under 2 seconds"

✅ **Testable:**
- "Integration successfully sends data to customer's API"
- "Workflow handles errors gracefully and retries failed steps"
- "Application scales to 10 concurrent users"

### Bad Examples

❌ **Too Vague:**
- "Application works well"
- "Integration is good"
- "Performance is acceptable"

❌ **Not Measurable:**
- "Users are happy"
- "It looks professional"
- "It's easy to use"

❌ **Too Ambitious:**
- "Application handles 1 million requests per second"
- "Zero downtime during deployment"
- "100% test coverage"

---

## Example: Argo Workflows POC

### Must-Have Criteria

- [ ] Argo Workflows deploys to customer's GKE cluster
- [ ] Sample workflow executes successfully
- [ ] Workflow can access customer's container registry
- [ ] Workflow logs are accessible via UI
- [ ] Workflow can be submitted via CLI

### Should-Have Criteria

- [ ] Workflow completes in under 5 minutes
- [ ] Dashboard displays workflow status in real-time
- [ ] Workflow can handle errors and retry
- [ ] Integration with customer's monitoring system works

### Nice-to-Have Criteria

- [ ] Custom workflow templates created
- [ ] Workflow scheduling configured
- [ ] Advanced workflow patterns demonstrated
- [ ] Performance optimization applied

---

## Validation Methods

### How to Validate Success Criteria

1. **Automated Tests**
   - Scripts that verify functionality
   - Performance benchmarks
   - Integration tests

2. **Manual Verification**
   - Step-by-step validation
   - User acceptance testing
   - Stakeholder review

3. **Metrics and Monitoring**
   - Performance metrics
   - Error rates
   - Resource utilization

4. **Documentation Review**
   - Architecture diagrams
   - Deployment guides
   - Known issues list

---

## Common Pitfalls

### 1. Too Many Must-Have Criteria

**Problem:** Everything becomes critical, nothing can be deferred.

**Solution:** Limit must-haves to 3-5 truly critical items.

### 2. Vague Criteria

**Problem:** "Works well" means different things to different people.

**Solution:** Use specific, measurable language.

### 3. Unrealistic Expectations

**Problem:** Criteria that require production-grade polish in a POC.

**Solution:** Focus on proving concepts, not perfect implementations.

### 4. No Validation Plan

**Problem:** Criteria defined but no way to test them.

**Solution:** Define validation method for each criterion.

---

## Template

```markdown
## Success Criteria for [POC Name]

### Must-Have (POC Fails Without These)

- [ ] [Criterion 1]
  - **Validation:** [How to test]
  - **Acceptance:** [What constitutes success]
  
- [ ] [Criterion 2]
  - **Validation:** [How to test]
  - **Acceptance:** [What constitutes success]

### Should-Have (Important but Not Blocking)

- [ ] [Criterion 1]
  - **Validation:** [How to test]
  - **Acceptance:** [What constitutes success]

### Nice-to-Have (If Time Permits)

- [ ] [Criterion 1]
  - **Validation:** [How to test]
  - **Acceptance:** [What constitutes success]
```

---

## Stakeholder Alignment

### Before POC Starts

1. **Review criteria with stakeholders**
2. **Get explicit agreement on must-haves**
3. **Clarify what "success" means**
4. **Document any disagreements**

### During POC

1. **Track progress against criteria**
2. **Communicate if criteria at risk**
3. **Adjust should-haves/nice-to-haves as needed**

### After POC

1. **Report on each criterion**
2. **Explain any unmet criteria**
3. **Recommend next steps based on results**

---

## Additional Resources

- [SMART Goals Framework](https://www.mindtools.com/pages/article/smart-goals.htm)
- [POC Best Practices](https://www.gartner.com/en/articles/how-to-run-a-successful-proof-of-concept)
- [Stakeholder Management](https://www.pmi.org/learning/library/stakeholder-management-critical-success-project-11705)


# Daily Standup Format

## Overview

Daily standups keep the POC on track and stakeholders informed. Use this format for consistent, effective communication.

---

## Standup Structure

### Format: 15 Minutes Maximum

1. **Yesterday** (5 min): What was accomplished
2. **Today** (5 min): What's planned
3. **Blockers** (5 min): What's blocking progress

---

## Template

### Date: [Date]
### Attendees: [Names]

---

## Yesterday's Accomplishments

**Completed:**
- [ ] [Task 1] - [Brief description]
- [ ] [Task 2] - [Brief description]
- [ ] [Task 3] - [Brief description]

**Progress:**
- [Metric/Status Update]
- [Key Achievement]

**Issues Encountered:**
- [Issue 1] - [Resolution or Status]
- [Issue 2] - [Resolution or Status]

---

## Today's Plan

**Planned Tasks:**
- [ ] [Task 1] - [Expected outcome]
- [ ] [Task 2] - [Expected outcome]
- [ ] [Task 3] - [Expected outcome]

**Goals:**
- [Primary goal for today]
- [Secondary goal if time permits]

**Dependencies:**
- [Waiting on: Customer access, data, etc.]

---

## Blockers and Risks

**Current Blockers:**
- [Blocker 1] - [Impact] - [Owner/Action]
- [Blocker 2] - [Impact] - [Owner/Action]

**Risks Identified:**
- [Risk 1] - [Mitigation plan]
- [Risk 2] - [Mitigation plan]

**Help Needed:**
- [What help is needed and from whom]

---

## Success Criteria Status

| Criterion | Status | Notes |
|-----------|--------|-------|
| [Must-Have 1] | ✅ Complete / 🚧 In Progress / ⏳ Pending | [Notes] |
| [Must-Have 2] | ✅ Complete / 🚧 In Progress / ⏳ Pending | [Notes] |
| [Should-Have 1] | ✅ Complete / 🚧 In Progress / ⏳ Pending | [Notes] |

---

## Timeline Check

**Days Remaining:** [X]  
**On Track:** ✅ Yes / ⚠️ At Risk / ❌ Behind

**Key Milestones:**
- [Milestone 1]: [Status] - [Due Date]
- [Milestone 2]: [Status] - [Due Date]

---

## Next Steps

1. [Action item 1] - [Owner] - [Due date]
2. [Action item 2] - [Owner] - [Due date]
3. [Action item 3] - [Owner] - [Due date]

---

## Notes

[Any additional notes, decisions, or clarifications]

---

## Quick Reference: Status Icons

- ✅ **Complete**: Task finished and validated
- 🚧 **In Progress**: Currently working on it
- ⏳ **Pending**: Not started yet
- ⚠️ **At Risk**: May not complete on time
- ❌ **Blocked**: Cannot proceed without resolution
- 🔄 **Deferred**: Moved to later phase

---

## Best Practices

### Do's

✅ Keep it brief (15 minutes max)  
✅ Focus on progress and blockers  
✅ Be specific about accomplishments  
✅ Identify owners for action items  
✅ Update success criteria status  
✅ Track timeline and milestones

### Don'ts

❌ Don't go into deep technical details  
❌ Don't solve problems during standup  
❌ Don't skip blockers (they won't resolve themselves)  
❌ Don't make it a status report (it's a planning meeting)  
❌ Don't let one person dominate  
❌ Don't forget to follow up on action items

---

## Remote Standup Tips

- Use video when possible
- Share screen for demos/status
- Use collaborative document (Google Docs, Notion)
- Record if stakeholders can't attend
- Send summary email after standup

---

## Example Standup

### Date: 2026-01-05
### Attendees: John (Lead), Sarah (SE), Mike (Customer)

---

## Yesterday's Accomplishments

**Completed:**
- [x] Deployed Argo Workflows to customer cluster
- [x] Created sample workflow for demo
- [x] Configured authentication integration

**Progress:**
- Infrastructure setup complete
- Core functionality working

**Issues Encountered:**
- Network policy blocking workflow execution - Fixed by updating policy
- Authentication timeout - Investigating with customer team

---

## Today's Plan

**Planned Tasks:**
- [ ] Fix authentication timeout issue
- [ ] Create additional demo workflows
- [ ] Prepare demo script

**Goals:**
- Complete all must-have success criteria
- Have working demo ready for stakeholder review

**Dependencies:**
- Waiting on customer to provide updated SAML configuration

---

## Blockers and Risks

**Current Blockers:**
- Authentication timeout - High impact - Owner: Sarah, Action: Debug with customer team

**Risks Identified:**
- Demo timeline at risk if auth issue not resolved today - Mitigation: Prepare backup demo without auth

**Help Needed:**
- Customer SAML team to review configuration

---

## Success Criteria Status

| Criterion | Status | Notes |
|-----------|--------|-------|
| Deploy to customer cluster | ✅ Complete | Working |
| Sample workflow executes | ✅ Complete | Tested |
| Auth integration works | 🚧 In Progress | Timeout issue |
| Dashboard accessible | ⏳ Pending | Planned for today |

---

## Timeline Check

**Days Remaining:** 2  
**On Track:** ⚠️ At Risk (due to auth issue)

**Key Milestones:**
- Infrastructure setup: ✅ Complete - Due: Yesterday
- Demo ready: 🚧 In Progress - Due: Tomorrow

---

## Next Steps

1. Debug auth timeout - Sarah - Today EOD
2. Update demo script - John - Tomorrow
3. Schedule stakeholder demo - Mike - Tomorrow


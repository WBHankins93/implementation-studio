# Managing Multiple Workstreams in One Account

## 📝 Context

You're working on a large enterprise account with multiple SEs engaged across different 
divisions, regions, or workstreams. This is common in Fortune 500 accounts where your 
product is being evaluated or deployed in multiple business units. Coordination and 
knowledge sharing become critical to avoid stepping on each other and maximize win rate.

## 📋 Initial Assessment Checklist

- [ ] Understand the account structure (divisions, regions, business units)
- [ ] Identify all active workstreams and their owners
- [ ] Map stakeholder relationships across workstreams
- [ ] Understand dependencies between workstreams
- [ ] Identify shared resources or constraints
- [ ] Determine coordination cadence needed
- [ ] Establish primary point of contact for account

## 🎯 Coordination Framework

**Map the Account Structure**

- What divisions/business units are in play?
- Who owns each workstream? (SE, sales, timeline)
- What stage is each workstream? (Discovery, POC, implementation)
- Are there dependencies between workstreams?
- Are there shared stakeholders across workstreams?

**Establish Coordination Mechanisms**

- Weekly SE sync for account ⏱️ 30 min
- Shared documentation repository (architecture, decisions, learnings)
- Communication channel (Slack, Teams) for real-time coordination
- Clear ownership boundaries (who owns what)
- Escalation path for conflicts or dependencies

**Knowledge Sharing**

- What's been learned in one workstream that helps others?
- What technical decisions affect multiple workstreams?
- What customer preferences or constraints are account-wide?
- What's working well that should be replicated?
- What failure modes have been discovered?

**Stakeholder Management**

- Map decision makers across workstreams
- Identify cross-workstream influencers
- Understand political dynamics between divisions
- Coordinate executive engagement
- Avoid contradictory messaging

## 🎯 Common Scenarios

**Parallel POCs in Different Divisions**

- Coordinate on technical approach (similar architecture patterns)
- Share learnings (what worked, what didn't)
- Avoid conflicting commitments or promises
- Leverage wins in one division for others
- Coordinate timeline to maximize momentum

**Sequential Rollout Across Regions**

- Document learnings from first region
- Create reusable frameworks and runbooks
- Identify region-specific constraints early
- Coordinate resources and support
- Build on early wins

**Multiple Use Cases in Same Division**

- Identify shared infrastructure requirements
- Coordinate deployment approach
- Avoid duplicate work
- Share success criteria patterns
- Coordinate stakeholder engagement

## 🎯 Workstream Coordination Template

**Account:** [Account Name]

**Workstreams:**

| Workstream | Owner | Stage | Timeline | Key Stakeholders | Dependencies |
|------------|-------|-------|----------|------------------|--------------|
| Division A - Use Case 1 | [SE Name] | POC | [Dates] | [Names] | None |
| Division B - Use Case 2 | [SE Name] | Discovery | [Dates] | [Names] | Depends on A for architecture |
| Region EMEA | [SE Name] | Implementation | [Dates] | [Names] | None |

**Shared Resources:**
- Architecture patterns: [Link]
- Technical decisions: [Link]
- Customer constraints: [Air-gapped, compliance requirements]

**Coordination Cadence:**
- Weekly SE sync: [Day/Time]
- Slack channel: [#account-name]
- Document repo: [Link]

**Cross-Workstream Stakeholders:**
- [Name, Title] - Influences [Workstreams A, B]
- [Name, Title] - Decision maker for [Workstream C]

**Key Learnings:**
- [Date]: [Workstream] - [Learning and implication for others]

## 🎯 Conflict Resolution

**If Workstreams Conflict:**

- Technical approach differs → Align on account-wide architecture
- Timeline competition → Prioritize based on business impact and sales input
- Resource constraints → Escalate to leadership with data
- Stakeholder confusion → Coordinate messaging, establish single point of contact
- Contradictory commitments → Align internally before engaging customer

**Decision Framework:**

1. Identify the conflict explicitly
2. Understand business impact of each option
3. Consult with sales leadership on account
4. Make decision with clear rationale
5. Document decision and communicate to all SEs
6. Adjust workstream plans accordingly

## ⚠️ Gotchas

- Not coordinating early - discover conflicts too late
- Working in silos - duplicate work, contradictory messaging
- Competing for resources - internal competition hurts overall account
- Not sharing learnings - everyone reinvents the wheel
- Unclear ownership - stakeholder confusion, dropped balls
- Political dynamics between divisions - navigate carefully
- Over-coordinating - too many meetings, slows everything down

## 🔗 Links

- [New customer engagement](new-customer.md)
- [Status updates](../internal/status-updates.md)
- [Handoff to SE](../internal/handoff-to-se.md)
- [Account strategy](../pre-sales/account-strategy.md)

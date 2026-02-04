# Product Feedback & Roadmap Influence

## 📝 Context

SEs are the bridge between customer reality and product capabilities. You encounter gaps, 
feature requests, and "we can't do that" scenarios regularly. Capturing this feedback 
systematically and influencing product direction is part of your value to the company - 
not just closing deals with what exists today.

## 📋 Feedback Capture Checklist

- [ ] Document the specific customer need (not just "they want feature X")
- [ ] Understand the business impact if unmet
- [ ] Identify how urgent/important this is
- [ ] Note frequency (is this one customer or pattern across many?)
- [ ] Capture workarounds attempted
- [ ] Record customer's exact words/pain points
- [ ] Assess competitive implications

## 🎯 Feedback Framework

**Capture the Right Context**

Don't just say: "Customer wants multi-cloud support"

Do say:
- Customer: [Name]
- Use case: "They need to deploy across AWS and GCP due to [regulatory/business reason]"
- Business impact: "$500K deal at risk, decision in 30 days"
- Current workaround: "Manual replication, operationally expensive"
- Frequency: "5th customer this quarter asking for this"
- Competitive angle: "[Competitor] offers this, using it as differentiator"

**Categorize the Feedback**

- **Feature gap:** Capability doesn't exist at all
- **Performance limitation:** Exists but doesn't meet requirements
- **Usability issue:** Exists but too complex/fragile to use
- **Documentation gap:** Exists but customers can't figure it out
- **Integration request:** Need to connect with specific system
- **Compliance/security requirement:** Regulatory or policy constraint

**Assess Priority**

- **Urgency:** How soon does this need to be resolved?
  - Blocking deal now
  - Needed in 30-90 days
  - Future expansion depends on it
  - Nice to have, no timeline

- **Impact:** What's at stake?
  - Revenue at risk: $[Amount]
  - Strategic account implications
  - Competitive displacement opportunity
  - Reference customer potential

- **Frequency:** How often does this come up?
  - One-off edge case
  - Specific vertical requirement
  - Common across multiple customers
  - Industry-wide trend

## 🎯 Communicating Product Gaps to Customers

**When You Can't Do Something:**

1. **Acknowledge the need**
   - "I understand why you need [X], it's important for [reason]"
   - Don't minimize their requirement

2. **Explain current state honestly**
   - "We don't support [X] today"
   - Don't say "we can't" - say "we don't currently"
   - Don't make excuses

3. **Offer alternatives if available**
   - "Here's how others have approached this: [workaround]"
   - "We can achieve [similar outcome] through [alternative approach]"
   - Be honest about limitations of workarounds

4. **Capture feedback for product team**
   - "I'm documenting this requirement for our product team"
   - "Can you help me understand the business impact?"
   - "What's your timeline for needing this?"

5. **Set expectations on roadmap**
   - If on roadmap: "This is planned for [timeframe]" (be honest about uncertainty)
   - If not on roadmap: "I can't commit to a timeline, but I'll advocate internally"
   - Don't promise what you can't deliver

**Example Scripts:**

**Feature gap blocking deal:**
"I understand you need [X] to move forward. We don't support that today, but I want to make sure your use case is heard. Can you walk me through the business impact and timeline? I'll document this for our product team and see if there's a path forward."

**Workaround exists:**
"We don't have native [X], but here's how [Customer Y] approached this: [workaround]. It's not perfect, but it's gotten them operational. Would that work for your timeline?"

**On roadmap:**
"This is on our roadmap, target is [quarter/timeframe]. I can't guarantee that date, but I can keep you updated on progress and advocate for your specific requirements."

## 🎯 Internal Product Feedback Process

**Document the Feedback**

Use this template:
```
## Product Feedback: [Feature/Capability Name]

**Customer:** [Name, Industry, Deal Size]
**Date:** [YYYY-MM-DD]
**Submitted by:** [Your Name]

**Customer Need:**
[Describe what they're trying to accomplish, not just the feature they asked for]

**Business Impact:**
- Revenue at risk: $[Amount]
- Timeline: [When they need this]
- Deal stage: [Discovery/POC/Negotiation]
- Competitive factor: [Yes/No - Details]

**Current State:**
- What we offer today: [Existing capabilities]
- Why it doesn't meet need: [Specific gaps]
- Workarounds attempted: [What was tried, why insufficient]

**Frequency:**
- [One-off / Multiple customers / Industry trend]
- Other customers affected: [List if known]

**Recommended Priority:**
- [P0: Blocking deal now / P1: High impact / P2: Important / P3: Nice to have]

**Supporting Materials:**
- Customer quote: "[Exact words]"
- Architecture diagrams: [Link if applicable]
- Competitive intel: [What competitors offer]
```

**Submit Through Proper Channels**

- Product feedback system (Jira, ProductBoard, etc.)
- Weekly product sync if urgent
- SE → Product meetings
- Written documentation in shared location

**Follow Up**

- Track status of high-priority feedback
- Update customer if status changes
- Share wins when features ship
- Close loop with product team on outcomes

## 🎯 Influencing Product Roadmap

**Build Credibility:**

- Submit high-quality feedback (context, impact, frequency)
- Don't cry wolf - prioritize honestly
- Share outcomes (did workaround work? did customer proceed?)
- Bring data, not just opinions

**Patterns That Get Attention:**

- Multiple customers asking for same thing (frequency)
- Large deal at risk (revenue impact)
- Competitive displacement opportunity (market pressure)
- Strategic account implications (relationship value)
- Clear ROI for product investment (build once, sell many times)

**How to Advocate:**

- Lead with business impact, not technical details
- Quantify when possible (X customers, $Y revenue, Z% of pipeline)
- Connect to strategic company goals
- Bring customer voice (quotes, specific pain points)
- Propose solution, don't just complain

**Example:**

Bad: "We need multi-cloud support, everyone is asking for it"

Good: "We've lost 3 deals worth $1.2M this quarter because we don't support GCP alongside AWS. Customers cite regulatory requirements to avoid single-cloud lock-in. [Competitor] has this and is using it as a wedge. I've documented specific requirements from 5 customers that would represent $2M+ in revenue if we shipped this."

## 🎯 Managing Customer Expectations

**When Feature Is Not Coming Soon:**

- Be honest: "This isn't currently on our roadmap"
- Explain why (if appropriate): "We're focused on [other priorities]"
- Offer alternatives: "Here's what we recommend instead..."
- Set clear expectations: "I can't commit to when/if this will be built"
- Keep door open: "If your requirements change or we can find a workaround, let's reconnect"

**When Feature Is On Roadmap:**

- Be realistic about timing: "Target is Q2, but roadmaps shift"
- Don't promise dates unless committed publicly
- Offer to keep them updated
- Consider early access/beta if appropriate
- Get their input on requirements

**When Workaround Exists:**

- Be honest about limitations
- Help them evaluate if it meets their needs
- Offer support during implementation
- Document gaps that remain
- Continue advocating for native support

## ⚠️ Gotchas

- Over-promising on roadmap - never commit to dates you don't control
- Not capturing context - "customer wants X" isn't actionable
- Crying wolf - everything is urgent loses credibility
- Not following up - feedback disappears into void
- Minimizing customer needs - validates their concern first
- Feature requests without business impact - product can't prioritize
- Not offering alternatives - left customer with "we can't help you"

## 🔗 Links

- [Discovery call](../pre-sales/discovery.md)
- [POC recovery](../recovery/poc-recovery.md)
- [Escalation](../recovery/escalation.md)
- [Requesting help](requesting-help.md)

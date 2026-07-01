## Tracking Your Impact

## 📝 Context

As an SE, your impact isn't always obvious. You're not directly closing deals, but you're critical to 
winning them. Tracking your impact helps you demonstrate value, identify improvement areas, and advocate 
for resources. This guide helps you measure what matters.

## 📋 Metrics That Matter

**Core Metrics:**
- POC win rate (POC → closed won)
- Deal close rate (your involvement → closed won)
- Revenue influenced (deals you worked on that closed)
- Time to value (discovery → POC success)
- Customer satisfaction scores

**Why these matter:**
- POC win rate shows execution quality
- Deal close rate shows your influence on outcomes
- Revenue influenced quantifies business impact
- Time to value shows efficiency
- Customer satisfaction shows relationship quality

## 🎯 Advanced Metrics & Analysis

### Leading vs. Lagging Indicators

**Lagging Indicators (What happened):**
- POC win rate
- Deal close rate
- Revenue influenced
- Time to value

**Leading Indicators (Predicting success):**
- Discovery quality scores (completeness, accuracy)
- POC scope adherence (staying within scope)
- Customer engagement levels (responsiveness, meeting attendance)
- Escalation frequency (fewer escalations = healthier process)
- Documentation completeness (correlates with successful handoffs)

**Why this matters:** Leading indicators help you course-correct before outcomes are determined.

### Cohort Analysis

Track metrics across different cohorts to identify patterns:

**By Environment Type:**
- Air-gapped POC success rate vs. cloud-native
- Time to value: Air-gapped vs. Private vs. Cloud
- Escalation rate by environment complexity

**By Deal Size:**
- POC success rate: <$100K vs. $100K-$500K vs. >$500K
- Time to close by deal size segment
- Resource intensity by deal size

**By Customer Industry:**
- Win rate by vertical (Healthcare, Financial Services, etc.)
- Time to value by industry
- Common failure modes by industry

**Example Analysis:**

"Our POC win rate is 75% overall, but breaks down to:
- Cloud-native: 85% (faster, fewer constraints)
- Private cluster: 70% (moderate complexity)
- Air-gapped: 60% (higher complexity, longer timelines)

Action: For air-gapped POCs, we now add 50% time buffer and require pre-transfer artifact validation, which has improved win rate to 72%."

### Efficiency Metrics

**Time Allocation:**
- % time in customer-facing activities vs. internal
- % time in pre-sales vs. post-sales
- % time in escalations vs. proactive work

**Velocity:**
- Average time from discovery to POC kickoff
- Average POC duration by environment type
- Average implementation timeline by complexity

**Capacity:**
- Concurrent engagements managed
- Average engagement duration
- Team utilization rate

### Quality Metrics

**Customer Satisfaction:**
- CSAT scores by engagement phase
- NPS from customers you've worked with
- Reference customer conversion rate

**Execution Quality:**
- On-time delivery rate
- Scope adherence rate
- Escalation resolution time
- Documentation completeness score

**Knowledge Sharing:**
- Playbook contributions
- Internal training sessions delivered
- Questions answered in team channels

### ROI Calculation Examples (Expanded)

**SE Time Investment ROI:**

Example: 
- SE time invested in POC: 40 hours
- POC → Close rate: 75%
- Average deal size: $200K
- Expected value: $200K × 0.75 = $150K
- ROI per SE hour: $150K / 40 hours = $3,750/hour

**Process Improvement ROI:**

Example:
- Created air-gapped deployment checklist
- Reduced air-gapped POC time from 3 weeks → 2 weeks
- Team executes 12 air-gapped POCs per year
- Time saved: 12 weeks (1 week per POC × 12)
- Value: 12 weeks of SE capacity unlocked for other work

**Recovery ROI:**

Example:
- POC was failing, $500K deal at risk
- Invested 20 hours in recovery (troubleshooting, escalation, customer communication)
- POC recovered, deal closed
- ROI: $500K saved / 20 hours = $25K per hour invested

### Benchmarking

**Internal Benchmarks:**
- Your metrics vs. team average
- Your metrics over time (trending up/down)
- By engagement type (POC vs. implementation)

**Industry Benchmarks (if available):**
- SE-to-sales ratio
- Average POC duration
- Average win rate
- Time to value

**Use benchmarks to:**
- Identify where you're excelling
- Identify improvement opportunities
- Set realistic goals
- Demonstrate performance

### Communicating Metrics to Leadership

**Monthly SE Summary (Expanded):**
```
## SE Performance Summary - [Month/Quarter]

### Engagement Overview
- POCs completed: 8 (target: 6)
- Win rate: 87% (team avg: 75%, industry benchmark: 70%)
- Revenue influenced: $2.4M (up 30% from last quarter)
- Average time-to-value: 6 weeks (down from 8 weeks)

### Efficiency Improvements
- Implemented air-gapped deployment checklist
- Reduced air-gapped POC time by 30% (3 weeks → 2 weeks)
- Team capacity unlocked: 12 weeks annually

### Strategic Impact
- 2 new reference customers secured
- Product feedback submitted resulted in 1 roadmap feature
- Mentored 2 junior SEs through their first POCs

### Key Wins
- [Customer A] POC → Closed won ($750K) - Complex air-gapped deployment
- [Customer B] Recovery → Salvaged failing POC, deal back on track ($400K)
- [Customer C] Expansion → Production deployment → 3 additional divisions evaluating

### Areas of Focus
- Increasing executive engagement (currently 20% of engagements, target 40%)
- Reducing escalation frequency (3 this quarter, target <2)
- Building expertise in [specific environment type]

### Support Needed
- [Training on X capability]
- [Resource for Y workstream]
- [Process improvement in Z area]
```

### Dashboard Examples

**SE Performance Dashboard:**

| Metric | This Month | Last Month | Target | Trend |
|--------|------------|------------|--------|-------|
| POCs Completed | 8 | 6 | 6 | ↑ |
| Win Rate | 87% | 75% | 75% | ↑ |
| Avg Time-to-Value | 6 weeks | 8 weeks | 7 weeks | ↑ |
| Escalations | 1 | 3 | <2 | ↑ |
| On-Time Delivery | 100% | 83% | 90% | ↑ |

**Pipeline Influence:**

| Deal | Stage | Amount | SE Involvement | Expected Close |
|------|-------|--------|----------------|----------------|
| Customer A | POC | $750K | Lead SE | Q1 2025 |
| Customer B | Discovery | $400K | Supporting | Q2 2025 |
| Customer C | Implementation | $200K | Lead SE | Closed |

## ⚠️ Gotchas

- Only tracking lagging indicators - can't course-correct early
- Not benchmarking - don't know if you're improving
- Ignoring leading indicators - miss early warning signs
- Not tracking time allocation - don't know where efficiency gains are
- Over-focusing on one metric - miss the bigger picture
- Not communicating metrics - leadership doesn't see your value
- Comparing apples to oranges - different deal types need different metrics

## 🔗 Links

- [Product feedback](product-feedback.md)
- [Learning paths](../LEARNING-PATHS.md)
- [Project status](../PROJECT-STATUS.md)

# ADR-004: Lab Environment Choices

## Status
Accepted

## Context

Implementation Studio teaches deployment patterns in constrained customer environments. A critical design decision is **what environments learners use** to complete labs:

1. **Cost constraints** - Not all learners have cloud accounts or budgets
2. **Learning objectives** - Some concepts require real cloud infrastructure
3. **Accessibility** - Labs should be accessible to as many learners as possible
4. **Real-world relevance** - Learners should experience real cloud environments
5. **Practicality** - Balance between cost, complexity, and learning value

The decision impacts:
- **Lab design** - Which labs require cloud vs. can use local
- **Learner experience** - Cost, setup complexity, learning value
- **Platform accessibility** - Who can use the platform
- **Maintenance burden** - Supporting multiple environments

## Decision

We will use a **hybrid approach** for lab environments:

- **Kind (Local)** - For labs that can be fully validated locally (Labs 02, 05, 06, 08, 09)
- **GCP + AWS (Cloud)** - For labs that require real cloud infrastructure (Labs 01, 03, 04, 07)
- **Kind + GCP + AWS (Hybrid)** - For labs that benefit from both local and cloud options (Labs 05, 06)

### Lab Environment Matrix

| Lab | Kind | GCP | AWS | Rationale |
|-----|------|-----|-----|-----------|
| **Lab 01: Standard Deployment** | ❌ | ✅ | ✅ | Requires real cloud infrastructure |
| **Lab 02: Air-Gapped** | ✅ | ❌ | ❌ | Air-gap IS the target (no cloud connectivity) |
| **Lab 03: Private Network** | ❌ | ✅ | ✅ | Requires private cloud networking |
| **Lab 04: Firewall-Restricted** | ❌ | ✅ | ✅ | Requires cloud firewall rules |
| **Lab 05: POC Sprint** | ✅ | ✅ | ✅ | Can use local for learning, cloud for real POCs |
| **Lab 06: Multi-Tenant** | ✅ | ✅ | ✅ | Kubernetes patterns work locally, cloud for scale |
| **Lab 07: Integration Patterns** | ❌ | ✅ | ✅ | Requires cloud databases (Cloud SQL/RDS) |
| **Lab 08: Handoff & Runbooks** | ✅ | ✅ | ✅ | Monitoring is cloud-agnostic |
| **Lab 09: Troubleshooting** | ✅ | ❌ | ❌ | Fully local, no cloud needed |

## Consequences

### Positive

- **Accessibility** - Many labs can be completed without cloud costs
- **Learning flexibility** - Learners can choose local or cloud based on needs
- **Cost-conscious path** - Complete path available for $0 (Labs 02, 05, 06, 08, 09)
- **Real-world experience** - Cloud labs provide actual cloud experience
- **Progressive learning** - Start local, move to cloud as needed
- **Broad applicability** - Works for learners with and without cloud access

### Negative

- **Complexity** - Supporting multiple environments increases maintenance
- **Documentation overhead** - Must document multiple deployment paths
- **Testing burden** - Must test Kind, GCP, and AWS paths
- **Potential confusion** - Learners may be unsure which option to choose
- **Feature gaps** - Some cloud features can't be simulated locally

### Neutral

- **Learning value** - Both local and cloud provide value (different aspects)
- **Time investment** - Local is faster, cloud is more realistic
- **Skill transfer** - Local teaches concepts, cloud teaches real-world patterns

## Alternatives Considered

### Option 1: All Cloud (GCP + AWS Only)

**Pros:**
- **Real-world experience** - All labs use real cloud infrastructure
- **Simpler** - One deployment model (cloud)
- **Consistent** - Same environment for all labs
- **Professional** - Matches real customer environments

**Cons:**
- **Cost barrier** - Requires cloud accounts and spending
- **Accessibility** - Excludes learners without cloud access
- **Setup complexity** - Cloud accounts, billing, credentials required
- **Learning barrier** - Cost concerns may prevent experimentation

**Why not chosen:** Cost and accessibility barriers exclude too many learners. Many concepts can be learned locally without cloud costs.

### Option 2: All Local (Kind Only)

**Pros:**
- **Zero cost** - Completely free for all learners
- **Accessible** - No cloud accounts needed
- **Fast** - Local deployment is faster
- **Simple** - One deployment model

**Cons:**
- **Not realistic** - Doesn't represent real cloud environments
- **Limited learning** - Can't learn cloud-specific patterns
- **Missing features** - Cloud features (VPC, IAM, load balancers) can't be simulated
- **Less valuable** - Skills less transferable to real-world scenarios

**Why not chosen:** While cost-effective, all-local approach misses critical learning objectives. Real cloud infrastructure is essential for understanding deployment constraints.

### Option 3: Cloud-Only with Free Tier

**Pros:**
- **Real cloud** - Uses actual cloud infrastructure
- **Free tier** - Leverages cloud provider free tiers
- **Realistic** - Matches real customer environments

**Cons:**
- **Free tier limits** - Limited resources, time restrictions
- **Complexity** - Still requires cloud accounts and setup
- **Provider lock-in** - Free tier varies by provider
- **Uncertainty** - Free tier terms can change

**Why not chosen:** Free tiers are unreliable and limited. Hybrid approach provides better accessibility while maintaining real-world learning.

### Option 4: Separate Tracks (Local Track vs Cloud Track)

**Pros:**
- **Clear separation** - Learners choose one track
- **Focused** - Each track optimized for its environment
- **No confusion** - Clear which labs to complete

**Cons:**
- **Duplicate content** - Labs duplicated for each track
- **Maintenance burden** - Must maintain two sets of labs
- **Harder to sync** - Difficult to keep tracks aligned
- **Less flexible** - Can't easily switch between local and cloud

**Why not chosen:** Duplicating labs creates significant maintenance burden. Conditional provider selection (single lab, choose environment) is more maintainable.

### Option 5: Cloud with Local Simulation

**Pros:**
- **Real cloud focus** - Primary focus on cloud
- **Local fallback** - Local simulation for concepts
- **Best of both** - Cloud for real, local for learning

**Cons:**
- **Complexity** - Must maintain simulation layer
- **Accuracy** - Simulations may not match reality
- **Maintenance** - Simulation layer requires maintenance
- **Confusion** - Differences between simulation and reality

**Why not chosen:** Simulations add complexity without clear benefit. Hybrid approach (real local + real cloud) is simpler and more accurate.

## Decision Rationale

The **hybrid approach** was chosen because it:

1. **Maximizes accessibility** - Many labs can be completed locally ($0 cost)
2. **Provides real-world experience** - Cloud labs use actual infrastructure
3. **Balances cost and value** - Learners can choose based on budget and needs
4. **Maintains learning objectives** - Each lab uses the environment that best teaches its concepts
5. **Supports progressive learning** - Start local, move to cloud as skills develop
6. **Reduces maintenance** - Single lab codebase with conditional provider selection

**Key Principles:**

- **Use local where possible** - If a concept can be learned locally, provide local option
- **Use cloud where necessary** - If a concept requires cloud infrastructure, require cloud
- **Provide choice where beneficial** - If both local and cloud add value, support both
- **Be transparent about costs** - Clearly document cost implications

## Implementation

### Lab Environment Selection

**Labs with Local Option (Kind):**
- Lab 02: Air-Gapped (Kind-only, no cloud option)
- Lab 05: POC Sprint (Kind + GCP + AWS)
- Lab 06: Multi-Tenant (Kind + GCP + AWS)
- Lab 08: Handoff & Runbooks (Kind + GCP + AWS)
- Lab 09: Troubleshooting (Kind-only)

**Labs Requiring Cloud:**
- Lab 01: Standard Deployment (GCP + AWS)
- Lab 03: Private Network (GCP + AWS)
- Lab 04: Firewall-Restricted (GCP + AWS)
- Lab 07: Integration Patterns (GCP + AWS)

### Conditional Provider Selection

Labs use conditional module selection:

```hcl
variable "cloud_provider" {
  description = "Cloud provider: kind, gcp, or aws"
  type        = string
  default     = "kind"
  validation {
    condition     = contains(["kind", "gcp", "aws"], var.cloud_provider)
    error_message = "Cloud provider must be 'kind', 'gcp', or 'aws'."
  }
}

# Conditional module selection
module "cluster" {
  count = var.cloud_provider != "kind" ? 1 : 0
  source = var.cloud_provider == "gcp"
    ? "../../modules/gcp/gke-cluster"
    : "../../modules/aws/eks-cluster"
  # ...
}
```

### Documentation Strategy

**Provider Selection Guides:**
- Each lab includes provider selection guide
- Cost comparison table (Kind vs GCP vs AWS)
- Use case recommendations
- Prerequisites for each option

**Example from Lab 05:**
```markdown
## Deployment Options

### Option 1: Kind (Local, Zero Cost) ⭐ Recommended for Learning
- Best for: Learning, testing, zero-cost POCs
- Cost: $0
- Time: ~2 minutes

### Option 2: GCP (Cloud, Minimal Cost)
- Best for: Real POCs in GCP environments
- Cost: $0-5 per day
- Time: ~5-10 minutes

### Option 3: AWS (Cloud, Minimal Cost)
- Best for: Real POCs in AWS environments
- Cost: $0-5 per day
- Time: ~10-15 minutes
```

### Cost Transparency

**Cost Documentation:**
- Each lab documents cost for each option
- Cost breakdown tables
- Cost optimization tips
- Cleanup instructions to minimize costs

**Example:**
```markdown
## Cost Estimates

| Option | Setup | Hourly | Daily (if left running) |
|--------|-------|--------|-------------------------|
| Kind | $0 | $0 | $0 |
| GCP | $0 | ~$0.20 | ~$5 |
| AWS | $0 | ~$0.25 | ~$6 |
```

## Learning Paths

### Cost-Conscious Path (All Local)

**Labs:** 02, 05, 06, 08, 09
**Cost:** $0
**Time:** 30-40 hours
**Value:** Learn core concepts without cloud costs

### Cloud Learning Path

**Labs:** 01, 03, 04, 07 (GCP or AWS)
**Cost:** $20-50 total (if destroyed quickly)
**Time:** 40-50 hours
**Value:** Real cloud experience, transferable skills

### Complete Path (Hybrid)

**Labs:** All 9 labs
**Cost:** $20-50 (cloud labs only)
**Time:** 108-133 hours
**Value:** Comprehensive learning with both local and cloud experience

## Future Considerations

### Cloud Provider Free Tiers

**Current Approach:** Don't rely on free tiers

**Rationale:**
- Free tiers are unreliable (terms change, limits vary)
- Hybrid approach provides better accessibility
- Free tiers don't cover all lab requirements

**Future Consideration:** Document free tier options as supplementary information, not primary path.

### Additional Local Options

**Current:** Kind for local Kubernetes

**Future Options:**
- Minikube (alternative local Kubernetes)
- K3s (lightweight Kubernetes)
- Docker Desktop (simpler local option)

**Decision:** Kind is sufficient for current needs. Additional options can be added if community requests.

## References

- [Lab Specifications](../04-labs/lab-specifications.md) - Detailed lab requirements
- [Learning Paths](../01-getting-started/learning-paths.md) - Recommended progression
- [Cost Management](../05-operations/cost-management.md) - Cost estimates and optimization
- [Testing Strategy](./testing-strategy.md) - What can be tested locally vs cloud

---

**Date:** January 5, 2026  
**Author:** Ben Hankins  
**Status:** Accepted


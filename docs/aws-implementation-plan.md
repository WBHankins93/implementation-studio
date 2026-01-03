# AWS Implementation Plan

**Goal:** Add AWS support while maintaining production-grade quality standards.

**Principles:**
- ✅ Production-grade quality (same standards as GCP)
- ✅ Cloud-agnostic where possible
- ✅ Clear, phased approach
- ✅ Checkpoints for commits
- ✅ No Azure support

## Lab Analysis

### Fully Cloud-Agnostic (No Changes Needed)
- ✅ **Lab 08: Handoff and Runbooks** - Monitoring is cloud-agnostic (Prometheus/Grafana work everywhere)
- ✅ **Lab 09: Troubleshooting Scenarios** - All scenarios are cloud-agnostic (Kind-based)

### Currently Local-Only (Could Benefit from Cloud Options)
- **Lab 02: Air-Gapped Deployment** - Uses Kind (local simulation)
  - **Cloud Option:** Could use private EKS/GKE clusters with network policies
  - **Complexity:** Medium (requires private cluster setup)
  - **Value:** High (real-world air-gapped often uses cloud)

- **Lab 05: POC Sprint** - Uses Kind or minimal GCP
  - **Cloud Option:** GCP or AWS (both are fine for POCs)
  - **Complexity:** Low (just infrastructure choice)
  - **Value:** Medium (POCs often use cloud)

- **Lab 06: Multi-Tenant Deployment** - Uses Kind or GKE
  - **Cloud Option:** Already supports both Kind and GKE, just needs EKS
  - **Complexity:** Low (just add EKS option)
  - **Value:** High (multi-tenant often uses cloud)

### Definitely Need Cloud Provider Options
- ✅ **Lab 01: Standard Deployment** - Currently GCP only
- ✅ **Lab 03: Private Network Deployment** - Currently GCP only (private GKE)
- ✅ **Lab 04: Firewall-Restricted Deployment** - Currently GCP only (firewall rules)
- ✅ **Lab 07: Integration Patterns** - Currently GCP only (Cloud SQL)

## Implementation Strategy

### Phase 1: Core AWS Modules (Checkpoint 1)

**Goal:** Create production-grade AWS modules matching GCP quality

**Modules to Create:**
1. `modules/aws/eks-cluster/` - Equivalent to `gke-cluster`
2. `modules/aws/vpc/` - Equivalent to `vpc-standard`
3. `modules/aws/vpc-private/` - Equivalent to `vpc-private`
4. `modules/aws/ecr/` - Equivalent to `artifact-registry`
5. `modules/aws/security-groups/` - Equivalent to `firewall-rules`

**Quality Standards:**
- ✅ Same structure as GCP modules
- ✅ Comprehensive README with examples
- ✅ All variables documented
- ✅ Outputs documented
- ✅ Terraform fmt and validate
- ✅ Production-ready defaults

**Deliverable:** 5 AWS modules ready for use

**Commit Checkpoint:** "Add core AWS infrastructure modules"

---

### Phase 2: Update Lab 01 (Checkpoint 2)

**Goal:** Make Lab 01 support both GCP and AWS

**Changes:**
- Add provider selection variable
- Conditionally use GCP or AWS modules
- Update documentation
- Update terraform.tfvars.example
- Test both paths

**Complexity:** Medium (first lab to update, sets pattern)

**Deliverable:** Lab 01 works with both GCP and AWS

**Commit Checkpoint:** "Update Lab 01 to support GCP and AWS"

---

### Phase 3: Update Lab 06 (Checkpoint 3)

**Goal:** Add AWS/EKS option to Lab 06 (already supports Kind and GKE)

**Changes:**
- Add EKS option to setup script
- Update terraform.tfvars.example
- Update documentation
- Test EKS path

**Complexity:** Low (already has cloud support, just adding option)

**Deliverable:** Lab 06 works with Kind, GKE, or EKS

**Commit Checkpoint:** "Add AWS/EKS support to Lab 06"

---

### Phase 4: Update Lab 03 (Checkpoint 4)

**Goal:** Add AWS private EKS option to Lab 03

**Changes:**
- Create AWS private VPC/EKS pattern
- Add provider selection
- Update bastion access (AWS uses different method)
- Update documentation

**Complexity:** Medium (private clusters different between GCP/AWS)

**Deliverable:** Lab 03 works with both GCP and AWS private clusters

**Commit Checkpoint:** "Add AWS private EKS support to Lab 03"

---

### Phase 5: Update Lab 04 (Checkpoint 5)

**Goal:** Add AWS security groups option to Lab 04

**Changes:**
- Create AWS security groups module usage
- Add provider selection
- Update proxy configuration (AWS uses security groups differently)
- Update documentation

**Complexity:** Medium (security groups vs firewall rules - different model)

**Deliverable:** Lab 04 works with both GCP firewall rules and AWS security groups

**Commit Checkpoint:** "Add AWS security groups support to Lab 04"

---

### Phase 6: Update Lab 07 (Checkpoint 6)

**Goal:** Add AWS RDS option to Lab 07

**Changes:**
- Add RDS module (or use existing pattern)
- Add provider selection for database
- Update Cloud SQL Proxy → RDS Proxy comparison
- Update documentation

**Complexity:** Medium (RDS vs Cloud SQL - different patterns)

**Deliverable:** Lab 07 works with both Cloud SQL and RDS

**Commit Checkpoint:** "Add AWS RDS support to Lab 07"

---

### Phase 7: Optional Cloud Options for Labs 02 & 05 (Checkpoint 7)

**Goal:** Add cloud options to labs that currently only use Kind

**Lab 02 Changes:**
- Add option for private GKE/EKS clusters
- Use network policies to simulate air-gap
- Update documentation

**Lab 05 Changes:**
- Add AWS quick-deploy option
- Update minimal deployment scripts
- Update documentation

**Complexity:** Medium (adds optional complexity)

**Deliverable:** Labs 02 and 05 have cloud options (Kind still default)

**Commit Checkpoint:** "Add optional cloud options to Labs 02 and 05"

---

### Phase 8: Documentation and Polish (Checkpoint 8)

**Goal:** Complete multi-cloud documentation

**Changes:**
- Update main README with AWS support
- Create provider comparison guide
- Update module README
- Create migration guide (GCP ↔ AWS)
- Update lab specifications

**Deliverable:** Complete multi-cloud documentation

**Commit Checkpoint:** "Complete multi-cloud documentation"

---

## Detailed Phase Breakdown

### Phase 1: Core AWS Modules

**Modules to Create (in priority order):**

1. **eks-cluster/** (Highest Priority)
   - Structure: Same as `gke-cluster`
   - Features: VPC CNI, IRSA, node groups, auto-scaling
   - Time: ~2-3 hours

2. **vpc/** (Foundation)
   - Structure: Same as `vpc-standard`
   - Features: Public/private subnets, NAT gateway, internet gateway
   - Time: ~1-2 hours

3. **vpc-private/** (For Lab 03)
   - Structure: Same as `vpc-private`
   - Features: Private subnets, VPC endpoints
   - Time: ~1-2 hours

4. **ecr/** (Container Registry)
   - Structure: Same as `artifact-registry`
   - Features: ECR repository, lifecycle policies
   - Time: ~1 hour

5. **security-groups/** (For Lab 04)
   - Structure: Similar to `firewall-rules`
   - Features: Security groups, rules
   - Time: ~1-2 hours

**Total Phase 1 Time:** ~6-10 hours

---

### Phase 2: Update Lab 01

**Changes Needed:**

1. **Add Provider Variable:**
   ```hcl
   variable "cloud_provider" {
     description = "Cloud provider: gcp or aws"
     type        = string
     default     = "gcp"
     validation {
       condition     = contains(["gcp", "aws"], var.cloud_provider)
       error_message = "Cloud provider must be gcp or aws"
     }
   }
   ```

2. **Conditional Module Usage:**
   ```hcl
   # VPC
   module "vpc" {
     source = var.cloud_provider == "gcp"
       ? "../../modules/gcp/vpc-standard"
       : "../../modules/aws/vpc"
     # ...
   }
   
   # Cluster
   module "cluster" {
     source = var.cloud_provider == "gcp"
       ? "../../modules/gcp/gke-cluster"
       : "../../modules/aws/eks-cluster"
     # ...
   }
   ```

3. **Update Documentation:**
   - Add AWS option to README
   - Update prerequisites
   - Add AWS-specific notes

**Total Phase 2 Time:** ~2-3 hours

---

### Phase 3: Update Lab 06

**Changes Needed:**

1. **Update setup.sh:**
   - Add EKS option
   - Update provider detection

2. **Update terraform.tfvars.example:**
   - Add AWS options
   - Document provider choice

3. **Update main.tf:**
   - Add conditional EKS support
   - Keep Kind and GKE options

**Total Phase 3 Time:** ~1-2 hours

---

### Phase 4: Update Lab 03

**Changes Needed:**

1. **Private VPC Module:**
   - Use AWS vpc-private module
   - Configure VPC endpoints

2. **Private EKS:**
   - Configure private endpoint
   - Set up VPC endpoints for EKS API

3. **Bastion Access:**
   - AWS uses Systems Manager Session Manager or SSH
   - Update bastion-access.sh

**Total Phase 4 Time:** ~2-3 hours

---

### Phase 5: Update Lab 04

**Changes Needed:**

1. **Security Groups:**
   - Use AWS security-groups module
   - Different model than firewall rules

2. **Proxy Configuration:**
   - Same Squid proxy
   - Different egress rules (security groups)

**Total Phase 5 Time:** ~2 hours

---

### Phase 6: Update Lab 07

**Changes Needed:**

1. **Database Module:**
   - Create RDS module or use existing pattern
   - Different from Cloud SQL

2. **Database Proxy:**
   - AWS uses RDS Proxy (different from Cloud SQL Proxy)
   - Update connection patterns

**Total Phase 6 Time:** ~2-3 hours

---

### Phase 7: Optional Cloud Options

**Lab 02:**
- Add private cluster option
- Use network policies to simulate air-gap
- Keep Kind as default (easiest)

**Lab 05:**
- Add AWS quick-deploy
- Minimal EKS setup
- Keep Kind as default

**Total Phase 7 Time:** ~2-3 hours (optional)

---

### Phase 8: Documentation

**New Documentation:**
- Provider comparison guide
- Migration guide
- Feature parity matrix
- Update all READMEs

**Total Phase 8 Time:** ~2-3 hours

---

## Total Estimated Time

**Core Implementation (Phases 1-6):** ~15-23 hours
**Optional (Phases 7-8):** ~4-6 hours
**Total:** ~19-29 hours

---

## Quality Standards Checklist

For each AWS module, ensure:

- [ ] Same file structure as GCP equivalent
- [ ] Comprehensive README.md with:
  - [ ] What it is and when to use
  - [ ] What it creates (diagram)
  - [ ] Usage examples
  - [ ] All variables documented
  - [ ] All outputs documented
  - [ ] Requirements and dependencies
- [ ] Variables file:
  - [ ] All variables have descriptions
  - [ ] Appropriate types and defaults
  - [ ] Validation where needed
- [ ] Outputs file:
  - [ ] All outputs documented
  - [ ] Useful outputs for integration
- [ ] Main.tf:
  - [ ] Production-ready defaults
  - [ ] Security best practices
  - [ ] Proper resource configuration
- [ ] Terraform validation:
  - [ ] `terraform fmt` passes
  - [ ] `terraform validate` passes
  - [ ] No linter warnings

---

## Success Criteria

**Phase 1 Success:**
- All 5 AWS modules created
- Modules match GCP quality standards
- Modules documented comprehensively
- Terraform validation passes

**Overall Success:**
- Labs 01, 03, 04, 06, 07 support both GCP and AWS
- Quality maintained throughout
- Documentation complete
- Both providers tested

---

## Risk Mitigation

**Risk: Quality Degradation**
- **Mitigation:** Use GCP modules as templates
- **Mitigation:** Review each module against GCP equivalent
- **Mitigation:** Follow quality checklist strictly

**Risk: Maintenance Burden**
- **Mitigation:** Keep modules functionally equivalent
- **Mitigation:** Document differences clearly
- **Mitigation:** Use consistent patterns

**Risk: Getting Lost in Content**
- **Mitigation:** Clear checkpoints after each phase
- **Mitigation:** Commit and push after each phase
- **Mitigation:** Focus on one phase at a time

---

## Next Steps

**Immediate Action:**
1. Review this plan
2. Start Phase 1 (Core AWS Modules)
3. Create first module (eks-cluster) as proof of concept
4. Review quality before continuing

**Decision Points:**
- After Phase 1: Review quality, decide if approach works
- After Phase 2: Review Lab 01 pattern, decide if scalable
- After Phase 6: Evaluate if Phase 7 (optional) is needed

---

**Remember:** Quality over speed. Each module must match GCP production standards.


# Real-World Air-Gap Deployment Patterns

How to apply Lab 02 patterns to actual customer air-gapped deployments.

## When You'll Encounter Air-Gapped Environments

### Common Scenarios

1. **Defense Contractors**
   - Classified systems (IL4, IL5, IL6)
   - Secure facilities with no external connectivity
   - STIG-compliant deployments
   - FedRAMP requirements

2. **Government Agencies**
   - Federal systems requiring air-gap
   - State/local government secure systems
   - Law enforcement systems
   - Intelligence community systems

3. **Financial Institutions**
   - High-security trading systems
   - Compliance requirements (PCI-DSS, etc.)
   - Internal-only networks
   - Regulatory isolation

4. **Healthcare Organizations**
   - HIPAA-compliant systems
   - Protected health information (PHI)
   - Research facilities
   - Clinical trial systems

5. **Industrial Control Systems**
   - SCADA systems
   - Critical infrastructure
   - Manufacturing control systems
   - Power grid systems

## Key Differences from Lab

### Registry Choice

**Lab:** Simple Docker registry  
**Production:** Enterprise registry (Harbor, Artifactory, Nexus)

**Why:**
- Vulnerability scanning
- Image replication
- RBAC and access control
- Audit logging
- Web UI for management

### Transfer Methods

**Lab:** USB drive or local simulation  
**Production:** Customer-approved transfer procedures

**Common Methods:**
- **USB Drives** - Encrypted, approved media
- **Secure Network** - Isolated network segment
- **Physical Media** - DVD, Blu-ray, tape
- **Approved File Transfer** - Customer's secure transfer system

### Security Requirements

**Lab:** Basic network policies  
**Production:** Comprehensive security controls

**Additional Requirements:**
- Image scanning and approval
- Signed images (cosign, Notary)
- Change management approval
- Security review process
- Audit logging
- Compliance documentation

### Update Procedures

**Lab:** Simple update process  
**Production:** Formal change management

**Production Process:**
1. Request update approval
2. Security review
3. Prepare update bundle
4. Test in staging air-gap
5. Get deployment approval
6. Schedule maintenance window
7. Deploy updates
8. Verify and document

## Adapting Lab Patterns

### Step 1: Discovery

**Questions to Ask:**

1. **Registry:**
   - What registry do you use? (Harbor, Artifactory, etc.)
   - Where is it located? (on-prem, separate air-gap)
   - How do you manage images?
   - What's your image approval process?

2. **Transfer:**
   - What's your approved transfer method?
   - Are there size limits?
   - What's the approval process?
   - How long does transfer take?

3. **Network:**
   - How is air-gap enforced? (physical, network policies, both)
   - Are there any allowed external connections?
   - What's the network architecture?
   - Are there proxy requirements?

4. **Updates:**
   - How often do you update?
   - What's your change management process?
   - Do you have staging air-gap?
   - What's your rollback procedure?

5. **Security:**
   - Do you scan images? (what tool?)
   - Do you sign images?
   - What's your approval process?
   - What compliance requirements?

### Step 2: Preparation

**Identify All Components:**

```bash
# Your application images
kubectl get deployments --all-namespaces -o jsonpath='{range .items[*]}{.spec.template.spec.containers[*].image}{"\n"}{end}' | sort -u

# Helm chart dependencies
helm dependency list

# Init containers
kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{.spec.initContainers[*].image}{"\n"}{end}' | sort -u

# Sidecar containers
kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{.spec.containers[*].image}{"\n"}{end}' | sort -u
```

**Create Complete Image List:**

Document every image with:
- Image name and tag
- Purpose (what uses it)
- Size
- Source registry
- Version

### Step 3: Image Preparation

**For Production:**

1. **Scan Images** (before saving)
   ```bash
   # Using Trivy
   trivy image quay.io/argoproj/workflow-controller:v3.5.5
   
   # Review vulnerabilities
   # Update if critical issues found
   ```

2. **Sign Images** (optional but recommended)
   ```bash
   # Using cosign
   cosign sign quay.io/argoproj/workflow-controller:v3.5.5
   ```

3. **Save Images**
   ```bash
   docker save image:tag -o image.tar
   ```

4. **Document Everything**
   - Image versions
   - Scan results
   - Signatures
   - Dependencies

### Step 4: Chart Preparation

**For Production:**

1. **Review Charts**
   ```bash
   helm show chart chart-name
   helm show values chart-name
   ```

2. **Customize for Customer**
   - Update image references
   - Configure for customer environment
   - Document all changes

3. **Package Charts**
   ```bash
   helm package .
   ```

4. **Document Versions**
   - Chart versions
   - Values used
   - Customizations

### Step 5: Bundle Creation

**For Production:**

1. **Include Everything**
   - All images
   - All charts
   - Deployment scripts
   - Documentation
   - Checksums
   - Version manifest

2. **Create Documentation**
   - Deployment instructions
   - Configuration guide
   - Troubleshooting guide
   - Rollback procedures

3. **Verify Bundle**
   - Check all files present
   - Verify checksums
   - Test in staging

### Step 6: Transfer

**Follow Customer Procedures:**

1. **Get Approval** - Follow customer's approval process
2. **Prepare Media** - Use approved transfer method
3. **Document Transfer** - Record what was transferred, when, by whom
4. **Verify Integrity** - Check checksums on receiving end

### Step 7: Deployment

**In Customer Environment:**

1. **Verify Bundle** - Check checksums, verify contents
2. **Load Images** - Load into customer's registry
3. **Deploy Application** - Install using customer's procedures
4. **Verify Deployment** - Test functionality
5. **Document** - Record versions, configurations, issues

## Production Considerations

### Registry Management

**Harbor Setup:**
- Create projects for organization
- Configure replication if multiple sites
- Set up vulnerability scanning
- Configure RBAC
- Enable audit logging

**Image Organization:**
```
harbor.example.com/
  ├── platform/          # Platform components
  │   ├── argo-workflows
  │   └── ingress-nginx
  ├── applications/      # Application images
  └── base/             # Base images
```

### Security Scanning

**Before Deployment:**
1. Scan all images
2. Review vulnerabilities
3. Update if critical issues
4. Document scan results
5. Get approval

**Tools:**
- Trivy
- Clair
- Harbor built-in scanning
- Twistlock
- Aqua Security

### Change Management

**Documentation Required:**
- Change request
- Impact analysis
- Test results
- Rollback plan
- Approval signatures

**Process:**
1. Submit change request
2. Security review
3. Test in staging
4. Get approvals
5. Schedule deployment
6. Execute deployment
7. Verify and document

### Update Planning

**Regular Updates:**
- Schedule quarterly updates
- Plan for security patches
- Coordinate with customer
- Test thoroughly

**Emergency Updates:**
- Fast-track critical security
- Minimal change set
- Quick testing
- Rapid deployment

## Customer Engagement Checklist

### Pre-Engagement

- [ ] Understand customer's air-gap requirements
- [ ] Identify registry type and location
- [ ] Understand transfer procedures
- [ ] Review security requirements
- [ ] Understand change management process

### Preparation

- [ ] Identify all required images
- [ ] Scan images for vulnerabilities
- [ ] Package all charts
- [ ] Create deployment bundle
- [ ] Document everything
- [ ] Test in staging air-gap

### Deployment

- [ ] Follow customer transfer procedures
- [ ] Verify bundle integrity
- [ ] Load images into customer registry
- [ ] Deploy using customer procedures
- [ ] Verify deployment
- [ ] Document versions and configuration

### Post-Deployment

- [ ] Provide runbooks
- [ ] Document update procedures
- [ ] Hand off to customer team
- [ ] Schedule follow-up

## Lessons Learned

### Common Mistakes

1. **Missing Images** - Forgetting dependencies
2. **Version Mismatches** - Charts and images don't match
3. **Incomplete Testing** - Not testing in staging first
4. **Poor Documentation** - Not documenting versions/configs
5. **Transfer Issues** - Bundle too large, transfer fails

### Best Practices

1. **Start Early** - Begin preparation well in advance
2. **Test Thoroughly** - Test in staging air-gap first
3. **Document Everything** - Versions, configs, procedures
4. **Plan Rollback** - Always have rollback plan
5. **Communicate** - Keep customer informed throughout

## Templates and Checklists

### Image Manifest Template

```yaml
# image-manifest.yaml
bundle-version: "2026-01-05"
prepared-by: "Your Name"
prepared-date: "2026-01-05"

images:
  - name: quay.io/argoproj/workflow-controller
    tag: v3.5.5
    size: 245MB
    purpose: "Argo Workflows controller"
    scanned: true
    vulnerabilities: 0
    source: "Quay.io"
```

### Deployment Checklist

- [ ] Bundle transferred and verified
- [ ] Images loaded into registry
- [ ] Charts packaged and ready
- [ ] Values files configured
- [ ] Network policies reviewed
- [ ] Security scans passed
- [ ] Change request approved
- [ ] Rollback plan ready
- [ ] Customer team notified
- [ ] Maintenance window scheduled

## Next Steps

After understanding these patterns:

1. Practice with Lab 02
2. Review customer requirements
3. Adapt patterns to customer environment
4. Test in customer staging
5. Execute production deployment

Remember: Every customer is different. Adapt these patterns to their specific requirements and procedures.


# POC Troubleshooting

## Common Issues and Solutions

### Deployment Issues

#### Cluster Creation Fails

**Problem:** Terraform fails to create cluster

**Solutions:**
1. **Check quotas:**
   ```bash
   gcloud compute project-info describe --project=$PROJECT_ID
   ```

2. **Verify APIs enabled:**
   ```bash
   gcloud services enable container.googleapis.com compute.googleapis.com
   ```

3. **Check permissions:**
   ```bash
   gcloud projects get-iam-policy $PROJECT_ID
   ```

#### Cluster Takes Too Long

**Problem:** Cluster creation exceeds expected time

**Solutions:**
- This is normal (5-10 minutes)
- Use smaller cluster (1 node, e2-small)
- Consider using Kind for local POC

### Application Issues

#### Argo Workflows Not Starting

**Problem:** Argo Workflows pods not running

**Solutions:**
1. **Check pod status:**
   ```bash
   kubectl get pods -n argo
   kubectl describe pod <pod-name> -n argo
   ```

2. **Check logs:**
   ```bash
   kubectl logs <pod-name> -n argo
   ```

3. **Verify Helm installation:**
   ```bash
   helm list -n argo
   helm status argo-workflows -n argo
   ```

#### Workflows Fail to Execute

**Problem:** Workflows submit but don't run

**Solutions:**
1. **Check workflow status:**
   ```bash
   kubectl get workflows -n argo
   kubectl describe workflow <workflow-name> -n argo
   ```

2. **Check node resources:**
   ```bash
   kubectl top nodes
   kubectl describe node <node-name>
   ```

3. **Check image pull:**
   ```bash
   kubectl describe pod <workflow-pod> -n argo | grep -i image
   ```

### Demo Issues

#### UI Not Accessible

**Problem:** Can't access Argo Workflows UI

**Solutions:**
1. **Check service:**
   ```bash
   kubectl get svc -n argo
   ```

2. **Port forward:**
   ```bash
   kubectl port-forward -n argo svc/argo-workflows-server 2746:2746
   ```

3. **Check firewall rules:**
   ```bash
   gcloud compute firewall-rules list
   ```

#### Demo Workflows Not Working

**Problem:** Demo workflows fail or don't appear

**Solutions:**
1. **Verify workflows deployed:**
   ```bash
   kubectl get workflows -n argo
   ```

2. **Check workflow YAML:**
   ```bash
   kubectl get workflow <name> -n argo -o yaml
   ```

3. **Submit manually:**
   ```bash
   kubectl apply -f manifests/demo-workflow-simple.yaml
   ```

### Time Management Issues

#### POC Running Behind Schedule

**Problem:** Not meeting timeline

**Solutions:**
1. **Assess scope:**
   - Can anything be deferred?
   - Are all objectives critical?

2. **Communicate early:**
   - Inform stakeholders
   - Discuss options
   - Adjust if needed

3. **Focus on core:**
   - Prioritize must-have criteria
   - Defer nice-to-have

#### Scope Creep

**Problem:** POC expanding beyond original scope

**Solutions:**
1. **Refer to scope document:**
   - Remind stakeholders of agreed scope
   - Document new requests separately

2. **Assess impact:**
   - Will it affect timeline?
   - Is it critical for decision?

3. **Get approval:**
   - Document scope change
   - Get stakeholder sign-off
   - Adjust timeline if needed

### Communication Issues

#### Stakeholder Misalignment

**Problem:** Different expectations

**Solutions:**
1. **Review scope document:**
   - Ensure everyone has same understanding
   - Clarify any confusion

2. **Regular updates:**
   - Daily standups
   - Weekly status reports
   - Immediate issue communication

3. **Document decisions:**
   - Write down all decisions
   - Share with stakeholders

## Getting Help

### Internal Resources

- Team members
- Technical leads
- Project managers
- Documentation

### External Resources

- Vendor support
- Community forums
- Documentation sites
- Stack Overflow

### When to Escalate

- Critical blockers
- Timeline at risk
- Scope significantly changing
- Stakeholder concerns

## Prevention Tips

1. **Test Everything First** - Don't demo untested workflows
2. **Have Backup Plan** - Always ready for failures
3. **Document Issues** - Track problems and solutions
4. **Communicate Early** - Don't wait for problems to escalate
5. **Stay Focused** - Resist scope creep
6. **Manage Time** - Regular check-ins on progress

## Additional Resources

- [Scoping Guide](./scoping-guide.md)
- [Demo Guide](./demo-guide.md)
- [Common Questions](../demo-prep/common-questions.md)


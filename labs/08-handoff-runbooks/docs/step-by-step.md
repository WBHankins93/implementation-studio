# Step-by-Step Guide: Handoff and Runbooks

This guide walks through setting up monitoring, creating runbooks, conducting training, and executing a successful handoff.

## Prerequisites

- Kubernetes cluster (Kind or GKE)
- `kubectl` configured
- `helm` 3.x installed
- Access to cluster

## Step 1: Deploy Monitoring Stack

### 1.1 Setup Monitoring

```bash
cd labs/08-handoff-runbooks

# Deploy monitoring stack
./scripts/setup-monitoring.sh
```

**What This Does:**
- Creates monitoring namespace
- Installs Prometheus Operator
- Installs Grafana
- Configures alerting
- Sets up basic dashboards

**Verification:**
```bash
# Check pods
kubectl get pods -n monitoring

# Check services
kubectl get svc -n monitoring
```

### 1.2 Import Dashboards

```bash
# Import pre-built dashboards
./scripts/import-dashboards.sh
```

**What This Does:**
- Imports Cluster Overview dashboard
- Imports Argo Workflows dashboard
- Imports Application Health dashboard

**Verification:**
- Access Grafana (port-forward)
- Verify dashboards are visible
- Check dashboard data

### 1.3 Access Monitoring

```bash
# Port forward Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80

# Access at http://localhost:3000
# Username: admin
# Password: prom-operator
```

## Step 2: Configure Alerting

### 2.1 Review Alert Rules

```bash
# View alert rules
kubectl get prometheusrule -n monitoring

# View alert rule details
kubectl get prometheusrule application-alerts -n monitoring -o yaml
```

### 2.2 Customize Alerts

Edit `monitoring-setup/alerting-rules/application-alerts.yaml`:
- Adjust thresholds
- Add custom alerts
- Configure notification channels

### 2.3 Apply Alert Rules

```bash
# Apply alert rules
kubectl apply -f monitoring-setup/alerting-rules/application-alerts.yaml
```

**Verification:**
- Check alerts in Prometheus
- Verify alert conditions
- Test alert notifications

## Step 3: Create Runbooks

### 3.1 Customize Runbook Templates

**Deployment Runbook:**
- Edit `runbook-templates/deployment-runbook.md`
- Add application-specific steps
- Include your deployment procedures
- Add verification steps

**Incident Response:**
- Edit `runbook-templates/incident-response.md`
- Add common incidents
- Include escalation procedures
- Add customer-specific contacts

**Scaling Guide:**
- Edit `runbook-templates/scaling-guide.md`
- Add scaling thresholds
- Include autoscaling config
- Add performance baselines

**Backup and Restore:**
- Edit `runbook-templates/backup-restore.md`
- Add backup procedures
- Include restore procedures
- Add disaster recovery plan

**Upgrade Procedure:**
- Edit `runbook-templates/upgrade-procedure.md`
- Add upgrade steps
- Include rollback procedures
- Add testing procedures

### 3.2 Test Runbooks

**For Each Runbook:**
1. Follow procedures step-by-step
2. Verify all commands work
3. Check verification steps
4. Test rollback procedures
5. Update based on findings

## Step 4: Prepare Training Materials

### 4.1 Customize Training Agenda

Edit `knowledge-transfer/training-agenda.md`:
- Adjust duration based on needs
- Customize sessions for your application
- Add application-specific topics
- Include customer-specific scenarios

### 4.2 Prepare Hands-On Exercises

Edit `knowledge-transfer/hands-on-exercises.md`:
- Customize exercises for your application
- Add application-specific scenarios
- Include real-world examples
- Test all exercises

### 4.3 Prepare Certification Checklist

Edit `knowledge-transfer/certification-checklist.md`:
- Define certification levels
- Set competency requirements
- Create assessment criteria
- Define success criteria

## Step 5: Conduct Training

### 5.1 Pre-Training Preparation

**Customer Team:**
- [ ] Team members identified
- [ ] Prerequisites communicated
- [ ] Schedule confirmed
- [ ] Access prepared

**Trainer:**
- [ ] Materials prepared
- [ ] Exercises tested
- [ ] Demo environment ready
- [ ] Support contacts ready

### 5.2 Execute Training

**Follow Training Agenda:**
- Day 1: Foundation and Architecture
- Day 2: Operations and Monitoring
- Day 3: Operations and Maintenance
- Day 4: Advanced Operations
- Day 5: Certification and Handoff

**For Each Day:**
- Present material
- Conduct hands-on exercises
- Answer questions
- Collect feedback

### 5.3 Certification Assessment

**Conduct Assessment:**
- Written assessment (optional)
- Practical exercises
- Skills validation
- Certification decision

## Step 6: Execute Handoff

### 6.1 Pre-Handoff Verification

**Complete Handoff Checklist:**
- [ ] Documentation complete
- [ ] Monitoring configured
- [ ] Training completed
- [ ] Access granted
- [ ] Support model defined

### 6.2 Handoff Meeting

**Agenda:**
1. Review handoff checklist
2. Verify all items complete
3. Review support model
4. Address questions
5. Sign-off handoff

### 6.3 Post-Handoff Support

**First 30 Days:**
- Daily check-ins
- Immediate support
- Issue tracking
- Feedback collection

**Ongoing:**
- Standard support model
- Regular check-ins
- Continuous improvement

## Step 7: Validate Success

### 7.1 Technical Validation

**Verify:**
- [ ] Monitoring functional
- [ ] Alerts working
- [ ] Dashboards accessible
- [ ] Runbooks tested
- [ ] Documentation complete

### 7.2 Operational Validation

**Verify:**
- [ ] Customer team can operate
- [ ] Customer team can monitor
- [ ] Customer team can troubleshoot
- [ ] Customer team knows procedures
- [ ] Customer team knows when to escalate

### 7.3 Customer Validation

**Verify:**
- [ ] Customer team feels confident
- [ ] Customer team feels empowered
- [ ] Customer team has support
- [ ] Customer team ready for operations
- [ ] Customer satisfied

## Troubleshooting

### Monitoring Issues

**Problem:** Grafana not accessible

**Solution:**
```bash
# Check pod status
kubectl get pods -n monitoring

# Check service
kubectl get svc -n monitoring

# Check port-forward
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```

### Alert Issues

**Problem:** Alerts not firing

**Solution:**
```bash
# Check alert rules
kubectl get prometheusrule -n monitoring

# Check Prometheus
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
# Check alerts in Prometheus UI
```

### Training Issues

**Problem:** Customer team struggling

**Solution:**
- Provide additional practice time
- Review fundamentals
- Offer additional training sessions
- Adjust training pace

## Best Practices

### Monitoring

1. **Start Simple:** Begin with basic dashboards
2. **Iterate:** Add dashboards based on needs
3. **Document:** Document what each metric means
4. **Review:** Regularly review and update dashboards

### Runbooks

1. **Test First:** Test all runbooks before handoff
2. **Keep Updated:** Update when procedures change
3. **Make Accessible:** Ensure easy access
4. **Review Regularly:** Review and improve regularly

### Training

1. **Hands-On:** Emphasize hands-on practice
2. **Real-World:** Use real-world scenarios
3. **Gradual:** Build confidence gradually
4. **Support:** Provide ongoing support

### Handoff

1. **Complete:** Ensure everything is complete
2. **Confident:** Ensure customer team is confident
3. **Supported:** Ensure support is available
4. **Empowered:** Ensure customer feels empowered

## Related Documentation

- [Architecture](./architecture.md)
- [What Production-Ready Means](./what-production-ready-means.md)
- [Handoff Checklist](./handoff-checklist.md)
- [Support Model Options](./support-model-options.md)
- [Troubleshooting](./troubleshooting.md)

---

**Remember:** A successful handoff is not just about technical completeness—it's about empowering your customer to succeed independently.


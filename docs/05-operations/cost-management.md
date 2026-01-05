# Cost Management

## GCP Cost Estimates

### Lab 01: Standard GKE Deployment
**Estimated Cost:** $5-10 if destroyed within a few hours

**Cost Breakdown:**
- GKE cluster: ~$0.10/hour per node (e2-medium)
- Load balancer: ~$0.025/hour
- NAT gateway: ~$0.045/hour
- Storage: Minimal (Artifact Registry)

**Cost Optimization:**
- Use preemptible nodes for development
- Destroy resources promptly after completion
- Use smallest node size that meets requirements

### Lab 03: Private Network Deployment
**Estimated Cost:** $8-15 if destroyed within a few hours

**Additional Costs:**
- Bastion host: ~$0.01/hour (f1-micro)
- Additional NAT gateway if needed

### Lab 04: Firewall-Restricted Deployment
**Estimated Cost:** $5-10 if destroyed within a few hours

Similar to Lab 01 with proxy server overhead.

### Lab 07: Integration Patterns
**Estimated Cost:** $10-20 if using cloud database

**Additional Costs:**
- Cloud SQL: ~$0.10-0.50/hour depending on tier
- API Gateway: Pay-per-use pricing

## Cost Optimization Strategies

1. **Use Preemptible Nodes:** 80% cost savings for development
2. **Destroy Promptly:** Most costs are hourly, destroy when done
3. **Local Testing:** Use Kind for labs that support it (Labs 02, 06, 09)
4. **Minimal Configurations:** Use smallest node sizes for learning
5. **Free Tier:** Leverage GCP free tier where possible

## Free/Local Labs

- **Lab 02:** Fully local (Kind) - $0
- **Lab 05:** Can use Kind - $0
- **Lab 06:** Can use Kind - $0
- **Lab 09:** Fully local (Kind) - $0

## Monitoring Costs

```bash
# Check current costs
gcloud billing accounts list
gcloud billing projects list --billing-account=BILLING_ACCOUNT_ID

# Set up billing alerts in GCP Console
```

## Best Practices

1. Always destroy resources after completing a lab
2. Use cleanup scripts provided in each lab
3. Set up billing alerts for your GCP project
4. Use separate projects for learning vs. production
5. Review costs regularly in GCP Console


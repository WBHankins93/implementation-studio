# Resource Management in Multi-Tenant Deployments

## Overview

Effective resource management is critical for multi-tenant deployments. This guide covers resource quotas, limit ranges, and best practices.

## Resource Quotas

### What Are Resource Quotas?

Resource quotas limit the total resource consumption within a namespace, preventing one tenant from consuming all cluster resources.

### Types of Resource Quotas

**Compute Resources:**
- `requests.cpu`: Total CPU requests
- `requests.memory`: Total memory requests
- `limits.cpu`: Total CPU limits
- `limits.memory`: Total memory limits

**Storage Resources:**
- `persistentvolumeclaims`: Number of PVCs
- `requests.storage`: Total storage requests

**Object Count:**
- `count/deployments.apps`: Number of deployments
- `count/statefulsets.apps`: Number of statefulsets
- `count/services`: Number of services
- `count/pods`: Number of pods

**Service Resources:**
- `services.loadbalancers`: Number of load balancers
- `services.nodeports`: Number of node ports

### Example Quota

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: tenant-quota
  namespace: tenant-a
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
    persistentvolumeclaims: "10"
    services.loadbalancers: "2"
    count/deployments.apps: "10"
```

### Checking Quota Usage

```bash
# View quota
kubectl get resourcequota -n tenant-a

# Detailed view
kubectl describe resourcequota -n tenant-a
```

## Limit Ranges

### What Are Limit Ranges?

Limit ranges set default resource requests/limits and constraints for containers within a namespace.

### Limit Range Components

**Default Requests/Limits:**
- Applied when container doesn't specify resources
- Ensures all containers have resources

**Min/Max Constraints:**
- Enforce minimum resource requests
- Enforce maximum resource limits
- Prevent resource abuse

### Example Limit Range

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: tenant-limits
  namespace: tenant-a
spec:
  limits:
  - default:
      cpu: "500m"
      memory: "512Mi"
    defaultRequest:
      cpu: "100m"
      memory: "128Mi"
    type: Container
  - max:
      cpu: "2"
      memory: "4Gi"
    min:
      cpu: "100m"
      memory: "128Mi"
    type: Container
```

## Quota Strategies

### Strategy 1: Fixed Quota

**Approach:** Same quota for all tenants

**Pros:**
- Simple to manage
- Fair allocation
- Easy to understand

**Cons:**
- May be too much for some
- May be too little for others
- Doesn't scale with needs

**Use Case:** Similar tenant sizes

### Strategy 2: Tiered Quotas

**Approach:** Different quota levels (standard, limited, premium)

**Pros:**
- Matches tenant needs
- Flexible pricing
- Scalable

**Cons:**
- More complex to manage
- Requires quota selection process
- Need to track tiers

**Use Case:** SaaS platforms, varied tenant sizes

### Strategy 3: Dynamic Quotas

**Approach:** Adjust quotas based on usage

**Pros:**
- Optimal resource utilization
- Scales with tenant growth
- Cost-effective

**Cons:**
- Complex to implement
- Requires monitoring
- May need automation

**Use Case:** Large-scale platforms, auto-scaling

## Setting Appropriate Quotas

### Factors to Consider

1. **Cluster Capacity**
   - Total cluster resources
   - Number of tenants
   - Reserve for system

2. **Tenant Requirements**
   - Expected workload
   - Growth projections
   - Performance needs

3. **Cost Model**
   - Pricing tiers
   - Resource costs
   - Profit margins

### Calculation Example

**Cluster:**
- 10 nodes, 4 CPU, 16Gi each
- Total: 40 CPU, 160Gi
- Reserve 20% for system: 32 CPU, 128Gi available

**10 Tenants:**
- Per tenant: ~3 CPU, ~12Gi
- Standard quota: 4 CPU, 8Gi (allows some headroom)

## Monitoring Resource Usage

### Check Quota Usage

```bash
# View all quotas
kubectl get resourcequota --all-namespaces

# Detailed view
kubectl describe resourcequota -n tenant-a
```

### Check Actual Usage

```bash
# Pod resource usage
kubectl top pods -n tenant-a

# Node resource usage
kubectl top nodes
```

### Set Up Alerts

**Monitor:**
- Quota usage > 80%
- Quota usage > 90%
- Quota exceeded errors

**Tools:**
- Prometheus
- Grafana
- Cloud monitoring

## Adjusting Quotas

### When to Increase

- Tenant consistently near quota limit
- Tenant requests more resources
- Tenant workload growing
- Performance issues due to quota

### When to Decrease

- Tenant consistently under-utilizing
- Cost optimization
- Reallocation to other tenants
- Tenant downgrade

### How to Adjust

```bash
# Edit quota
kubectl edit resourcequota tenant-quota -n tenant-a

# Or apply updated quota
kubectl apply -f updated-quota.yaml -n tenant-a
```

**Important:** Ensure current usage is below new limits before decreasing!

## Best Practices

### Quota Design

✅ **Start Conservative**: Begin with lower quotas, increase as needed
✅ **Monitor Usage**: Track quota utilization regularly
✅ **Set Realistic Limits**: Based on actual needs, not theoretical max
✅ **Reserve Headroom**: Don't allocate 100% of cluster
✅ **Document Rationale**: Explain why quotas are set

### Limit Range Design

✅ **Set Defaults**: Ensure all containers have resources
✅ **Enforce Minimums**: Prevent resource starvation
✅ **Enforce Maximums**: Prevent resource abuse
✅ **Match Quota**: LimitRange max should align with quota

### Management

✅ **Regular Reviews**: Quarterly quota reviews
✅ **Automated Monitoring**: Alert on high usage
✅ **Documentation**: Keep quota records
✅ **Communication**: Notify tenants of changes
✅ **Testing**: Test quota changes in non-production

## Common Issues

### Issue 1: Quota Too Restrictive

**Symptoms:**
- Frequent quota exceeded errors
- Applications can't scale
- Performance issues

**Solution:**
- Increase quota
- Review actual usage
- Adjust based on needs

### Issue 2: Quota Too Permissive

**Symptoms:**
- Tenant using very little
- Wasted resources
- Cost inefficiency

**Solution:**
- Decrease quota
- Reallocate resources
- Optimize allocation

### Issue 3: Missing Limit Range

**Symptoms:**
- Containers without resource requests
- Unpredictable scheduling
- Resource contention

**Solution:**
- Create LimitRange
- Set appropriate defaults
- Enforce minimums

## Additional Resources

- [Resource Quotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/)
- [Limit Ranges](https://kubernetes.io/docs/concepts/policy/limit-range/)
- [Resource Management](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)


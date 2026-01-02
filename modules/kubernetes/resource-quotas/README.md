# Resource Quotas Module

Kubernetes ResourceQuota and LimitRange patterns for multi-tenant resource management.

## Patterns

### standard-quota.yaml

Standard resource quota for typical tenant workloads.

**Resources:**
- CPU: 4 requests, 8 limits
- Memory: 8Gi requests, 16Gi limits
- PVCs: 10
- LoadBalancers: 2
- NodePorts: 5
- Deployments: 10
- StatefulSets: 5

**Use Case:** Standard tenant workloads

### limited-quota.yaml

Limited resource quota for smaller tenants or trial accounts.

**Resources:**
- CPU: 1 requests, 2 limits
- Memory: 2Gi requests, 4Gi limits
- PVCs: 3
- LoadBalancers: 1
- NodePorts: 2
- Deployments: 5
- StatefulSets: 2

**Use Case:** Small tenants, trials, development

## Usage

### Apply Resource Quota

```bash
# Replace template variable
sed "s/{{NAMESPACE}}/tenant-a/g" standard-quota.yaml | kubectl apply -f -
```

### Template Variables

- `{{NAMESPACE}}`: Namespace name

## Resource Quota vs LimitRange

**ResourceQuota:**
- Sets total limits for namespace
- Prevents resource exhaustion
- Applied at namespace level

**LimitRange:**
- Sets defaults and constraints per container
- Provides defaults if not specified
- Applied at container level

## Best Practices

1. **Set Realistic Limits**: Based on actual needs
2. **Monitor Usage**: Track quota utilization
3. **Adjust as Needed**: Scale quotas with tenant growth
4. **Document Limits**: Explain quota choices
5. **Set Defaults**: Use LimitRange for container defaults

## Multi-Tenant Considerations

- Each tenant gets their own quota
- Quotas prevent one tenant from consuming all resources
- LimitRange ensures containers have reasonable defaults
- Regular review and adjustment

## Additional Resources

- [Kubernetes Resource Quotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/)
- [Limit Ranges](https://kubernetes.io/docs/concepts/policy/limit-range/)


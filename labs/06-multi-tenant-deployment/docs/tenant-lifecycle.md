# Tenant Lifecycle Management

## Overview

This guide covers the complete lifecycle of tenant management in multi-tenant Kubernetes deployments, from onboarding to offboarding.

## Tenant Onboarding

### Step 1: Gather Requirements

**Information Needed:**
- Tenant name/identifier
- Resource requirements (CPU, memory)
- User access requirements
- Integration needs
- Compliance requirements

### Step 2: Create Tenant Namespace

**Using Script:**
```bash
./tenant-onboarding/create-tenant.sh tenant-a standard user@example.com
```

**Manually:**
```bash
# Create namespace
kubectl create namespace tenant-a

# Label namespace
kubectl label namespace tenant-a tenant=tenant-a name=tenant-a
```

### Step 3: Apply Isolation

**Resource Quota:**
```bash
kubectl apply -f tenant-onboarding/tenant-quotas.yaml
# Replace {{TENANT_NAME}} with actual tenant name
```

**Network Policy:**
```bash
kubectl apply -f tenant-onboarding/tenant-network-policy.yaml
# Replace {{TENANT_NAME}} with actual tenant name
```

**RBAC:**
```bash
kubectl apply -f tenant-onboarding/tenant-rbac.yaml
# Replace {{TENANT_NAME}} with actual tenant name
```

### Step 4: Configure Access

**Grant User Access:**
```bash
# Create RoleBinding for user
kubectl create rolebinding tenant-a-admin \
  --role=tenant-admin \
  --user=user@example.com \
  -n tenant-a
```

**Create Service Account:**
```bash
kubectl create serviceaccount tenant-a-app -n tenant-a
```

### Step 5: Deploy Applications

**Deploy to Tenant Namespace:**
```bash
kubectl apply -f app.yaml -n tenant-a
```

### Step 6: Verify

**Check Resources:**
```bash
kubectl get all -n tenant-a
kubectl get resourcequota -n tenant-a
kubectl get networkpolicy -n tenant-a
kubectl get role -n tenant-a
```

## Tenant Management

### Monitoring Tenant Resources

**Check Quota Usage:**
```bash
kubectl describe resourcequota -n tenant-a
```

**Check Resource Consumption:**
```bash
kubectl top pods -n tenant-a
kubectl top nodes
```

**Check Network Policy:**
```bash
kubectl get networkpolicy -n tenant-a
kubectl describe networkpolicy -n tenant-a
```

### Adjusting Quotas

**Increase Quota:**
```bash
# Edit ResourceQuota
kubectl edit resourcequota tenant-quota -n tenant-a

# Or apply updated quota
kubectl apply -f updated-quota.yaml -n tenant-a
```

**Decrease Quota:**
- Ensure current usage is below new limits
- Update ResourceQuota
- Monitor for issues

### Managing Access

**Add User:**
```bash
kubectl create rolebinding tenant-a-user \
  --role=tenant-admin \
  --user=newuser@example.com \
  -n tenant-a
```

**Remove User:**
```bash
kubectl delete rolebinding tenant-a-user -n tenant-a
```

**Change Permissions:**
```bash
# Edit Role
kubectl edit role tenant-admin -n tenant-a
```

## Tenant Offboarding

### Step 1: Notify Tenant

**Communication:**
- Provide advance notice
- Explain offboarding process
- Set timeline
- Request data backup confirmation

### Step 2: Backup Data

**Critical Data:**
- Persistent volumes
- ConfigMaps with important config
- Secrets
- Application data

**Backup Process:**
```bash
# List PVCs
kubectl get pvc -n tenant-a

# Backup PVCs (example)
kubectl get pvc -n tenant-a -o yaml > tenant-a-pvcs-backup.yaml

# Export ConfigMaps
kubectl get configmap -n tenant-a -o yaml > tenant-a-configmaps.yaml

# Export Secrets (be careful!)
kubectl get secret -n tenant-a -o yaml > tenant-a-secrets.yaml
```

### Step 3: Stop Applications

**Graceful Shutdown:**
```bash
# Scale down deployments
kubectl scale deployment --replicas=0 --all -n tenant-a

# Wait for pods to terminate
kubectl wait --for=delete pod --all -n tenant-a --timeout=300s
```

### Step 4: Delete Resources

**Delete Applications:**
```bash
# Delete all resources in namespace
kubectl delete all --all -n tenant-a
```

**Delete Persistent Volumes:**
```bash
# Delete PVCs (this deletes associated PVs)
kubectl delete pvc --all -n tenant-a
```

### Step 5: Delete Namespace

**Final Cleanup:**
```bash
# Delete namespace (deletes all resources)
kubectl delete namespace tenant-a
```

**Verify Deletion:**
```bash
kubectl get namespace tenant-a
# Should return "not found"
```

## Automation

### Automated Onboarding

**Script:**
```bash
./tenant-onboarding/create-tenant.sh <tenant-name> [quota-type] [user-email]
```

**What It Does:**
1. Creates namespace
2. Applies labels
3. Creates resource quota
4. Creates network policy
5. Creates RBAC
6. Creates service account

### Automated Offboarding

**Script (to be created):**
```bash
./tenant-onboarding/delete-tenant.sh <tenant-name> [backup-dir]
```

**What It Should Do:**
1. Backup data
2. Scale down applications
3. Delete resources
4. Delete namespace
5. Clean up external resources

## Best Practices

### Onboarding

✅ **Document Everything**: Keep records of tenant configuration
✅ **Set Appropriate Quotas**: Based on actual needs
✅ **Test Isolation**: Verify isolation works
✅ **Provide Documentation**: Give tenant their namespace details
✅ **Monitor Initially**: Watch for issues in first days

### Management

✅ **Regular Reviews**: Review quotas and usage quarterly
✅ **Monitor Usage**: Track resource consumption
✅ **Update Quotas**: Adjust as tenant grows
✅ **Audit Access**: Review RBAC regularly
✅ **Document Changes**: Track all modifications

### Offboarding

✅ **Plan Ahead**: Give adequate notice
✅ **Backup Everything**: Don't lose data
✅ **Verify Backups**: Test backup restoration
✅ **Clean Thoroughly**: Remove all resources
✅ **Document Process**: Record what was done

## Common Scenarios

### Scenario 1: Tenant Needs More Resources

**Process:**
1. Check current usage
2. Determine new quota
3. Update ResourceQuota
4. Monitor for issues
5. Document change

### Scenario 2: Tenant Violates Policy

**Process:**
1. Identify violation
2. Notify tenant
3. Provide remediation steps
4. Monitor compliance
5. Escalate if needed

### Scenario 3: Tenant Merges with Another

**Process:**
1. Plan migration
2. Backup both tenants
3. Migrate resources
4. Update access
5. Delete old tenant

## Troubleshooting

### Tenant Can't Access Resources

**Check:**
- RBAC permissions
- Namespace exists
- Service account configured
- Network policies allow access

### Tenant Exceeding Quota

**Check:**
- Current quota limits
- Actual resource usage
- Unused resources
- Need for quota increase

### Cross-Tenant Access Issues

**Check:**
- Network policies
- Shared services configuration
- DNS resolution
- Service discovery

## Additional Resources

- [Namespace Management](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
- [RBAC Best Practices](https://kubernetes.io/docs/concepts/security/rbac-good-practices/)
- [Resource Quota Management](https://kubernetes.io/docs/concepts/policy/resource-quotas/)


# Resolving Permission Denied Errors

## Solution: Create RBAC Configuration

### Step 1: Create Role

**Create a Role with required permissions:**
```bash
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: permission-test
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
EOF
```

### Step 2: Create RoleBinding

**Bind Role to Service Account:**
```bash
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader-binding
  namespace: permission-test
subjects:
- kind: ServiceAccount
  name: no-permissions
  namespace: permission-test
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io/v1
EOF
```

### Step 3: Restart Pod

**Delete and recreate pod (or let it restart):**
```bash
kubectl delete pod permission-test-pod -n permission-test

# Pod will be recreated automatically if part of a Deployment
# Or recreate manually
```

### Step 4: Verify Fix

**Check Pod Status:**
```bash
kubectl get pods -n permission-test
```

**Check Pod Logs:**
```bash
kubectl logs permission-test-pod -n permission-test
```

**Expected:** Should now successfully list pods

**Test Permissions:**
```bash
kubectl auth can-i list pods --namespace=permission-test --as=system:serviceaccount:permission-test:no-permissions
```

**Expected Output:**
```
yes
```

## Alternative Solutions

### Option 1: Use Default Service Account

**If default service account has permissions:**
```bash
# Update pod to use default service account
kubectl patch pod permission-test-pod -n permission-test -p '{"spec":{"serviceAccountName":"default"}}'
```

### Option 2: Use ClusterRole (For Cluster-Wide Access)

**If cluster-wide access needed:**
```bash
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pod-reader-cluster
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: pod-reader-cluster-binding
subjects:
- kind: ServiceAccount
  name: no-permissions
  namespace: permission-test
roleRef:
  kind: ClusterRole
  name: pod-reader-cluster
  apiGroup: rbac.authorization.k8s.io/v1
EOF
```

## Verification Steps

### 1. Verify RBAC Configuration

```bash
# Check Role
kubectl get role pod-reader -n permission-test -o yaml

# Check RoleBinding
kubectl get rolebinding pod-reader-binding -n permission-test -o yaml
```

### 2. Test Permissions

```bash
kubectl auth can-i list pods --namespace=permission-test --as=system:serviceaccount:permission-test:no-permissions
```

**Expected:** `yes`

### 3. Verify Pod Functionality

```bash
kubectl logs permission-test-pod -n permission-test
```

**Expected:** Should show pod list or no errors

## Prevention

### Best Practices

1. **Use Service Accounts:**
   - Create dedicated service accounts for applications
   - Don't use default service account for production
   - Document service account permissions

2. **Follow Least Privilege:**
   - Grant minimum required permissions
   - Use namespaced Roles when possible
   - Review permissions regularly

3. **Document RBAC:**
   - Document why each permission is needed
   - Review RBAC configuration
   - Test permissions before deployment

4. **Test Permissions:**
   - Use `kubectl auth can-i` to test
   - Test in non-production first
   - Verify permissions work as expected

## Common Mistakes

### Mistake 1: No Service Account

**Problem:** Using default service account without checking permissions

**Solution:** Create dedicated service account with proper permissions

### Mistake 2: Wrong Namespace

**Problem:** RoleBinding in wrong namespace

**Solution:** Ensure RoleBinding is in same namespace as service account

### Mistake 3: Missing Verbs

**Problem:** Role doesn't include required verbs

**Solution:** Include all required verbs (get, list, create, update, delete)

## Resolution Summary

| Issue | Solution | Result |
|-------|----------|--------|
| No RBAC | Create Role and RoleBinding | Service account has permissions |
| Permission denied | Grant required permissions | Pod can access resources |
| Service account | Configure proper service account | Pod uses correct account |

## Key Learnings

1. **Permission denied = RBAC issue** - Check Roles and RoleBindings
2. **Service accounts need permissions** - Create Roles and bind them
3. **Test permissions** - Use `kubectl auth can-i` to verify
4. **Follow least privilege** - Grant minimum required permissions
5. **Document RBAC** - Understand why permissions exist

## Related Documentation

- [RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Service Accounts](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)


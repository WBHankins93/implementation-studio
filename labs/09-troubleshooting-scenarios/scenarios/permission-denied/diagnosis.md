# Diagnosing Permission Denied Errors

## Step 1: Observe the Symptoms

**Check Pod Status:**
```bash
kubectl get pods -n permission-test
```

**Expected Output:**
```
NAME                  READY   STATUS    RESTARTS   AGE
permission-test-pod   0/1     Error     0          30s
```

**Observation:** Pod is in Error state.

## Step 2: Check Pod Logs

**View Pod Logs:**
```bash
kubectl logs permission-test-pod -n permission-test
```

**Expected Output:**
```
Error from server (Forbidden): pods is forbidden: User "system:serviceaccount:permission-test:no-permissions" cannot list resource "pods" in API group "" in the namespace "permission-test"
```

**Key Observation:** Clear permission denied error - service account cannot list pods.

## Step 3: Check Service Account

**List Service Accounts:**
```bash
kubectl get serviceaccount -n permission-test
```

**Expected Output:**
```
NAME             SECRETS   AGE
default          1         1m
no-permissions   1         1m
```

**Check Pod's Service Account:**
```bash
kubectl get pod permission-test-pod -n permission-test -o jsonpath='{.spec.serviceAccountName}'
```

**Expected Output:**
```
no-permissions
```

**Observation:** Pod is using `no-permissions` service account.

## Step 4: Check RBAC Configuration

**Check for Roles:**
```bash
kubectl get role -n permission-test
```

**Expected Output:**
```
No resources found in permission-test namespace.
```

**Check for RoleBindings:**
```bash
kubectl get rolebinding -n permission-test
```

**Expected Output:**
```
No resources found in permission-test namespace.
```

**Key Observation:** No RBAC configuration exists for the service account.

## Step 5: Verify the Hypothesis

**Test Permissions:**
```bash
kubectl auth can-i list pods --namespace=permission-test --as=system:serviceaccount:permission-test:no-permissions
```

**Expected Output:**
```
no
```

**Observation:** Service account indeed has no permissions.

## Step 6: Confirm Root Cause

**Root Cause Identified:**
The service account `no-permissions` has no RBAC permissions. When the pod tries to list pods using `kubectl get pods`, it fails because:
- Service account has no Role or ClusterRole bound
- No RoleBinding or ClusterRoleBinding exists
- API server denies the request

## Diagnosis Summary

| Symptom | Observation | Root Cause |
|---------|------------|------------|
| Pod in Error state | Pod failing | Permission denied |
| Error in logs | "Forbidden" error | Service account has no permissions |
| Service account | no-permissions exists | But no RBAC configured |
| RBAC | No roles/bindings | **Root cause identified** |

## Next Steps

Proceed to [resolution.md](./resolution.md) to fix the issue.


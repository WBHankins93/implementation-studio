# Scenario 3: Permission Denied Errors

## Problem Description

Applications are failing with permission denied errors. Pods cannot access required resources due to RBAC or file system permission issues.

## Symptoms

**What You'll Observe:**
- Pods failing with "permission denied" errors
- RBAC errors in logs
- File system permission errors
- Service account authentication failures
- API server access denied

**Example Errors:**
```
permission denied
Forbidden
Access denied
Unauthorized
```

## Initial Observations

**Check Pod Status:**
```bash
kubectl get pods -A
```

**Check Pod Logs:**
```bash
kubectl logs [pod-name] -n [namespace]
```

**Check Events:**
```bash
kubectl get events --sort-by='.lastTimestamp'
```

## Common Causes

1. **RBAC Issues:** Missing or incorrect Role/RoleBinding
2. **Service Account:** Wrong or missing service account
3. **File Permissions:** Incorrect file system permissions
4. **Security Context:** Missing or incorrect security context
5. **API Permissions:** Insufficient API server permissions

## Investigation Checklist

- [ ] Check pod status and logs
- [ ] Check RBAC configuration (Roles, RoleBindings)
- [ ] Check service account configuration
- [ ] Check security context
- [ ] Verify file permissions
- [ ] Check API server permissions
- [ ] Review error messages for specific permissions

## Expected Learning Outcomes

After completing this scenario, you will:
- Know how to diagnose RBAC issues
- Understand service account permissions
- Be able to check and fix file permissions
- Know how to verify security contexts
- Understand API server permissions
- Know how to resolve permission issues

## Next Steps

1. Run the simulation: `./simulate.sh`
2. Follow the diagnosis guide: `./diagnosis.md`
3. Apply the resolution: `./resolution.md`
4. Verify the fix works


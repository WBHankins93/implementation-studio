# Scenario 4: Image Pull Failures

## Problem Description

Pods cannot start because they cannot pull container images from the registry. This is one of the most common deployment issues.

## Symptoms

**What You'll Observe:**
- Pods in `ImagePullBackOff` state
- Pods in `ErrImagePull` state
- Image pull errors in events
- Authentication errors

**Example Errors:**
```
ImagePullBackOff
ErrImagePull
Failed to pull image
unauthorized
pull access denied
```

## Initial Observations

**Check Pod Status:**
```bash
kubectl get pods -A
```

**Check Pod Events:**
```bash
kubectl describe pod [pod-name] -n [namespace]
```

**Check Events:**
```bash
kubectl get events --sort-by='.lastTimestamp'
```

## Common Causes

1. **Image Doesn't Exist:** Image name or tag incorrect
2. **Registry Authentication:** Missing or incorrect image pull secrets
3. **Network Issues:** Cannot reach registry
4. **Registry Access:** Registry requires authentication
5. **Image Pull Policy:** Wrong pull policy configuration

## Investigation Checklist

- [ ] Check pod status and events
- [ ] Verify image name and tag
- [ ] Check image pull secrets
- [ ] Test registry connectivity
- [ ] Verify registry authentication
- [ ] Check image pull policy
- [ ] Review error messages

## Expected Learning Outcomes

After completing this scenario, you will:
- Know how to diagnose image pull failures
- Understand image pull secrets
- Be able to verify image existence
- Know how to configure registry authentication
- Understand image pull policies
- Know how to resolve image pull issues

## Next Steps

1. Run the simulation: `./simulate.sh`
2. Follow the diagnosis guide: `./diagnosis.md`
3. Apply the resolution: `./resolution.md`
4. Verify the fix works


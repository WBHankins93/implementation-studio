# Diagnosing Image Pull Failures

## Step 1: Observe the Symptoms

**Check Pod Status:**
```bash
kubectl get pods -n image-test
```

**Expected Output:**
```
NAME                  READY   STATUS             RESTARTS   AGE
image-pull-fail-pod   0/1     ImagePullBackOff   0          1m
```

**Key Observation:** Pod is in `ImagePullBackOff` state.

## Step 2: Check Pod Events

**Describe Pod to See Events:**
```bash
kubectl describe pod image-pull-fail-pod -n image-test
```

**Expected Output:**
```
Events:
  Type     Reason          Age   From               Message
  ----     ------          ----  ----               -------
  Normal   Scheduled       1m    default-scheduler  Successfully assigned image-test/image-pull-fail-pod to node
  Warning  Failed          1m    kubelet            Failed to pull image "nonexistent-registry.example.com/nonexistent-image:latest": rpc error: code = Unknown desc = failed to resolve image "nonexistent-registry.example.com/nonexistent-image:latest": pull access denied, repository does not exist or may require authorization: server message: insufficient_scope: authorization failed
  Warning  Failed          1m    kubelet            Error: ErrImagePull
  Normal   BackOff         1m    kubelet            Back-off pulling image "nonexistent-registry.example.com/nonexistent-image:latest"
  Warning  Failed          1m    kubelet            Error: ImagePullBackOff
```

**Key Observations:**
- "pull access denied" - authentication or access issue
- "repository does not exist" - image doesn't exist
- "authorization failed" - authentication problem

## Step 3: Check Image Configuration

**Check Pod Image:**
```bash
kubectl get pod image-pull-fail-pod -n image-test -o jsonpath='{.spec.containers[0].image}'
```

**Expected Output:**
```
nonexistent-registry.example.com/nonexistent-image:latest
```

**Observation:** Image points to non-existent registry/image.

## Step 4: Check Image Pull Secrets

**List Secrets:**
```bash
kubectl get secrets -n image-test
```

**Check Pod's Image Pull Secrets:**
```bash
kubectl get pod image-pull-fail-pod -n image-test -o jsonpath='{.spec.imagePullSecrets[*].name}'
```

**Expected Output:**
```
(empty)
```

**Observation:** No image pull secrets configured.

## Step 5: Test Image Existence

**Try to Pull Image Locally (if registry accessible):**
```bash
docker pull nonexistent-registry.example.com/nonexistent-image:latest
```

**Expected:** Will fail with same error

**Check Registry Connectivity:**
```bash
# If registry is accessible, test connectivity
ping nonexistent-registry.example.com || echo "Registry not reachable"
```

## Step 6: Analyze Root Cause

**Root Cause Identified:**
The image `nonexistent-registry.example.com/nonexistent-image:latest` doesn't exist or is not accessible because:
- Registry doesn't exist or is unreachable
- Image doesn't exist in registry
- No authentication configured (if registry requires it)
- Network connectivity issues

## Diagnosis Summary

| Symptom | Observation | Root Cause |
|---------|------------|------------|
| ImagePullBackOff | Pod can't start | Image pull failed |
| Error message | "repository does not exist" | Image doesn't exist |
| Image pull secrets | None configured | May need authentication |
| Registry | nonexistent-registry.example.com | **Root cause: Invalid registry/image** |

## Next Steps

Proceed to [resolution.md](./resolution.md) to fix the issue.


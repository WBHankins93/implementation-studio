# Resolving Image Pull Failures

## Solution Options

### Option 1: Fix Image Name (If Image Exists Elsewhere)

**Update Pod with Correct Image:**
```bash
kubectl delete pod image-pull-fail-pod -n image-test

kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: image-pull-fail-pod
  namespace: image-test
spec:
  containers:
  - name: app
    image: nginx:latest  # Use a valid public image
    imagePullPolicy: Always
EOF
```

**Verify Fix:**
```bash
kubectl get pods -n image-test
```

**Expected:** Pod should start successfully

### Option 2: Configure Image Pull Secrets (If Registry Requires Auth)

**Create Image Pull Secret:**
```bash
kubectl create secret docker-registry regcred \
  --docker-server=nonexistent-registry.example.com \
  --docker-username=<username> \
  --docker-password=<password> \
  --docker-email=<email> \
  -n image-test
```

**Update Pod to Use Secret:**
```bash
kubectl patch pod image-pull-fail-pod -n image-test -p '{"spec":{"imagePullSecrets":[{"name":"regcred"}]}}'
```

**Note:** Pods can't be patched directly. Delete and recreate with imagePullSecrets.

### Option 3: Use Public Registry

**If using private registry, switch to public:**
```bash
kubectl delete pod image-pull-fail-pod -n image-test

kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: image-pull-fail-pod
  namespace: image-test
spec:
  containers:
  - name: app
    image: nginx:latest  # Public image
    imagePullPolicy: IfNotPresent
EOF
```

## Verification Steps

### 1. Check Pod Status

```bash
kubectl get pods -n image-test
```

**Expected:** Pod should be Running

### 2. Check Pod Events

```bash
kubectl describe pod image-pull-fail-pod -n image-test
```

**Expected:** No image pull errors

### 3. Verify Image

```bash
kubectl get pod image-pull-fail-pod -n image-test -o jsonpath='{.spec.containers[0].image}'
```

**Expected:** Should show correct image

## Prevention

### Best Practices

1. **Use Valid Images:**
   - Verify image exists before deployment
   - Use specific tags (not just `latest`)
   - Test image pull locally first

2. **Configure Image Pull Secrets:**
   - Create secrets for private registries
   - Reference secrets in pod spec
   - Test authentication before deployment

3. **Use Image Pull Policies:**
   - `IfNotPresent` - Use local if available
   - `Always` - Always pull (for latest tags)
   - `Never` - Never pull (use local only)

4. **Monitor Image Pull Failures:**
   - Set up alerts for ImagePullBackOff
   - Monitor registry availability
   - Review image pull policies

## Common Mistakes

### Mistake 1: Wrong Image Name

**Problem:** Typo in image name or tag

**Solution:** Verify image name and tag before deployment

### Mistake 2: Missing Image Pull Secret

**Problem:** Private registry requires auth but secret not configured

**Solution:** Create and reference image pull secret

### Mistake 3: Wrong Registry

**Problem:** Pointing to wrong registry

**Solution:** Verify registry URL and connectivity

### Mistake 4: Image Doesn't Exist

**Problem:** Image was deleted or never pushed

**Solution:** Verify image exists in registry

## Resolution Summary

| Issue | Solution | Result |
|-------|----------|--------|
| Invalid image | Use correct image name | Image pulls successfully |
| Missing auth | Configure image pull secret | Authenticated pull works |
| Wrong registry | Use correct registry | Image accessible |
| Network issue | Fix connectivity | Registry reachable |

## Key Learnings

1. **ImagePullBackOff = image pull failed** - Check image name, registry, auth
2. **Check events for details** - Events show specific error
3. **Image pull secrets needed** - For private registries
4. **Verify image exists** - Before deployment
5. **Test locally first** - Pull image with docker to verify

## Related Documentation

- [Images](https://kubernetes.io/docs/concepts/containers/images/)
- [Image Pull Secrets](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod)


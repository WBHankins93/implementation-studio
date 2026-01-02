# Diagnosing Network Connectivity Issues

## Step 1: Observe the Symptoms

**Check Pod Status:**
```bash
kubectl get pods -n network-test
```

**Expected Output:**
```
NAME          READY   STATUS    RESTARTS   AGE
client-pod    1/1     Running   0          1m
server-pod    1/1     Running   0          1m
```

**Observation:** Pods are running, so the issue is not with pod startup.

## Step 2: Test Connectivity

**Try to Connect from Client Pod:**
```bash
kubectl exec -it client-pod -n network-test -- wget -O- http://test-service
```

**Expected Error:**
```
wget: can't connect to remote host (10.96.x.x): Connection timed out
```

**Observation:** Connection is timing out, indicating network policy blocking.

## Step 3: Check Service Endpoints

**Verify Service Has Endpoints:**
```bash
kubectl get endpoints test-service -n network-test
```

**Expected Output:**
```
NAME           ENDPOINTS        AGE
test-service   10.244.x.x:80    1m
```

**Observation:** Service has endpoints, so the issue is not with service discovery.

## Step 4: Check Network Policies

**List Network Policies:**
```bash
kubectl get networkpolicies -n network-test
```

**Expected Output:**
```
NAME        POD-SELECTOR   AGE
deny-all    <none>         1m
```

**Observation:** There's a network policy named "deny-all" - this is likely the culprit!

**Inspect Network Policy:**
```bash
kubectl describe networkpolicy deny-all -n network-test
```

**Expected Output:**
```
Name:         deny-all
Namespace:    network-test
Created:      1 minute ago
Labels:       <none>
Annotations:  <none>
Spec:
  Pod Selector:     <none> (matches all pods)
  Allowing ingress traffic:
    <none> (traffic not allowed by this NetworkPolicy)
  Allowing egress traffic:
    To Namespaces:
      NamespaceSelector:
        MatchLabels:
          name: kube-system
    To Ports:
      Port:         53/UDP
  Policy Types: Ingress, Egress
```

**Key Observation:**
- Pod selector is empty (`<none>`), meaning it applies to ALL pods
- Only allows egress to kube-system namespace on port 53 (DNS)
- Blocks all other traffic

## Step 5: Verify the Hypothesis

**Test DNS (Should Work):**
```bash
kubectl exec -it client-pod -n network-test -- nslookup kubernetes.default
```

**Expected:** Should resolve (DNS is allowed)

**Test Service Connection (Should Fail):**
```bash
kubectl exec -it client-pod -n network-test -- wget -O- http://test-service --timeout=5
```

**Expected:** Should timeout (service connection is blocked)

## Step 6: Confirm Root Cause

**Root Cause Identified:**
The `deny-all` NetworkPolicy is blocking all traffic except DNS to kube-system. This prevents:
- Pod-to-pod communication
- Pod-to-service communication
- Any external connectivity

## Diagnosis Summary

| Symptom | Observation | Root Cause |
|---------|------------|------------|
| Pods running | ✅ All pods healthy | Not a pod issue |
| Service exists | ✅ Service has endpoints | Not a service issue |
| Connection timeout | ❌ Cannot connect | Network policy blocking |
| Network policy | ⚠️ deny-all exists | **Root cause identified** |

## Next Steps

Proceed to [resolution.md](./resolution.md) to fix the issue.


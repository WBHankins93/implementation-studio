# Diagnosing DNS Resolution Issues

## Step 1: Observe the Symptoms

**Check Pod Status:**
```bash
kubectl get pods -n dns-test
```

**Expected Output:**
```
NAME           READY   STATUS    RESTARTS   AGE
dns-test-pod   1/1     Running   0          30s
```

**Observation:** Pod is running, but DNS resolution may be failing.

## Step 2: Test DNS Resolution

**Test Service DNS:**
```bash
kubectl exec dns-test-pod -n dns-test -- nslookup test-service.dns-test.svc.cluster.local
```

**Expected Error:**
```
Server:    1.1.1.1
Address 1: 1.1.1.1

nslookup: can't resolve 'test-service.dns-test.svc.cluster.local'
```

**Observation:** DNS resolution is failing.

## Step 3: Check DNS Configuration

**Check Pod DNS Config:**
```bash
kubectl get pod dns-test-pod -n dns-test -o jsonpath='{.spec.dnsConfig}' | jq '.'
```

**Expected Output:**
```json
{
  "nameservers": [
    "1.1.1.1"
  ]
}
```

**Key Observation:** Pod is using custom DNS server (1.1.1.1) instead of cluster DNS.

**Check DNS Policy:**
```bash
kubectl get pod dns-test-pod -n dns-test -o jsonpath='{.spec.dnsPolicy}'
```

**Expected Output:**
```
None
```

**Observation:** DNS policy is `None`, meaning custom DNS config is used.

## Step 4: Check CoreDNS

**Check CoreDNS Pods:**
```bash
kubectl get pods -n kube-system | grep coredns
```

**Expected Output:**
```
coredns-xxxxx-xxxxx   1/1     Running   0          10m
coredns-xxxxx-xxxxx   1/1     Running   0          10m
```

**Observation:** CoreDNS is running (but pod isn't using it).

**Get CoreDNS Service IP:**
```bash
kubectl get svc kube-dns -n kube-system
```

**Expected Output:**
```
NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)         AGE
kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP   10m
```

**Observation:** Cluster DNS service exists at 10.96.0.10.

## Step 5: Test with Correct DNS

**Test DNS Resolution with Cluster DNS:**
```bash
# Get cluster DNS IP
CLUSTER_DNS=$(kubectl get svc kube-dns -n kube-system -o jsonpath='{.spec.clusterIP}')

# Test from another pod with default DNS
kubectl run test-dns --image=busybox --rm -it --restart=Never -n dns-test -- nslookup test-service.dns-test.svc.cluster.local
```

**Expected:** Should resolve correctly

**Observation:** DNS works with cluster DNS, confirming the issue is with pod's DNS config.

## Step 6: Confirm Root Cause

**Root Cause Identified:**
The pod has `dnsPolicy: None` with custom DNS server `1.1.1.1`. This means:
- Pod doesn't use cluster DNS (CoreDNS)
- Custom DNS server doesn't know about cluster services
- Service discovery fails
- External DNS may work, but cluster DNS doesn't

## Diagnosis Summary

| Symptom | Observation | Root Cause |
|---------|------------|------------|
| DNS resolution fails | Can't resolve service names | Custom DNS config |
| DNS policy | Set to "None" | Not using cluster DNS |
| DNS server | Using 1.1.1.1 | Doesn't know cluster services |
| CoreDNS | Running and healthy | But pod not using it |

## Next Steps

Proceed to [resolution.md](./resolution.md) to fix the issue.


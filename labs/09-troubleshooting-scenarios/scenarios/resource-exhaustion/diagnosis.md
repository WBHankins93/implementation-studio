# Diagnosing Resource Exhaustion

## Step 1: Observe the Symptoms

**Check Pod Status:**
```bash
kubectl get pods -n resource-test
```

**Expected Output:**
```
NAME                READY   STATUS      RESTARTS   AGE
memory-hungry-pod   0/1     Pending     0          30s
oom-pod             0/1     OOMKilled   1          30s
pending-pod         0/1     Pending     0          30s
```

**Key Observations:**
- `OOMKilled` status indicates out-of-memory
- `Pending` status indicates scheduling issues
- Multiple pods affected suggests resource constraints

## Step 2: Check Pod Details

**Inspect OOMKilled Pod:**
```bash
kubectl describe pod oom-pod -n resource-test
```

**Expected Output:**
```
Name:         oom-pod
Namespace:    resource-test
Status:       Failed
Reason:       OOMKilled
...
Containers:
  oom-container:
    State:          Terminated
      Reason:       OOMKilled
      Exit Code:    137
...
Limits:
  memory:  400Mi
Requests:
  memory:  400Mi
```

**Key Observation:** Pod was killed because it exceeded its 400Mi memory limit.

**Inspect Pending Pod:**
```bash
kubectl describe pod pending-pod -n resource-test
```

**Expected Output:**
```
Events:
  Type     Reason            Age   From               Message
  ----     ------            ----  ----               -------
  Warning  FailedScheduling  1m    default-scheduler  0/1 nodes are available: 1 Insufficient memory.
```

**Or:**
```
Events:
  Type     Reason            Age   From               Message
  ----     ------            ----  ----               -------
  Warning  FailedScheduling  1m    default-scheduler  0/1 nodes are available: 1 pod has unbound immediate PersistentVolumeClaims.
```

**Key Observation:** Pod can't be scheduled due to insufficient resources.

## Step 3: Check Resource Quotas

**List Resource Quotas:**
```bash
kubectl get resourcequota -n resource-test
```

**Expected Output:**
```
NAME               AGE   REQUEST   LIMIT
restrictive-quota  2m   cpu: 400m/500m, memory: 400Mi/512Mi   cpu: 400m/1, memory: 400Mi/1Gi
```

**Key Observation:** Quota is nearly exhausted (400Mi used of 512Mi available).

**Describe Resource Quota:**
```bash
kubectl describe resourcequota restrictive-quota -n resource-test
```

**Expected Output:**
```
Name:            restrictive-quota
Namespace:       resource-test
Resource         Used    Hard
--------         ----    ----
limits.cpu       400m    1
limits.memory    400Mi   1Gi
pods              1       2
requests.cpu     400m    500m
requests.memory  400Mi   512Mi
```

**Key Observation:** 
- Memory requests: 400Mi used of 512Mi (78% used)
- Memory limits: 400Mi used of 1Gi
- Only 1 pod can be scheduled (quota allows 2, but memory requests limit it)

## Step 4: Check Resource Usage

**Check Current Resource Usage:**
```bash
kubectl top pods -n resource-test
```

**Expected Output:**
```
NAME                CPU(cores)   MEMORY(bytes)
oom-pod             0m           0Mi  (pod was killed)
```

**Check Node Capacity:**
```bash
kubectl top nodes
kubectl describe nodes
```

**Key Observation:** Check if nodes have available resources.

## Step 5: Check Events

**Review Recent Events:**
```bash
kubectl get events -n resource-test --sort-by='.lastTimestamp'
```

**Expected Output:**
```
LAST SEEN   TYPE     REASON      OBJECT           MESSAGE
1m          Warning  OOMKilling  pod/oom-pod      Memory cgroup out of memory
2m          Warning  FailedScheduling pod/pending-pod  0/1 nodes are available: 1 Insufficient memory
```

**Key Observation:** Events confirm OOMKilling and scheduling failures.

## Step 6: Analyze Root Causes

### Root Cause 1: OOMKilled Pod

**Problem:** Pod exceeded its memory limit (400Mi)
- Pod tried to use 800M
- Limit was 400Mi
- Kubernetes killed the pod

### Root Cause 2: Resource Quota

**Problem:** Namespace quota too restrictive
- Only 512Mi memory requests allowed
- Only 1Gi memory limits allowed
- Only 2 pods allowed
- Multiple pods competing for limited resources

### Root Cause 3: Pending Pods

**Problem:** Can't schedule due to quota exhaustion
- Quota doesn't have enough resources
- Or node doesn't have capacity

## Diagnosis Summary

| Symptom | Observation | Root Cause |
|---------|------------|------------|
| OOMKilled | Pod killed | Memory limit exceeded |
| Pending pods | Can't schedule | Resource quota exhausted |
| Resource quota | 78% used | Quota too restrictive |
| Multiple failures | Multiple pods affected | Insufficient resources |

## Next Steps

Proceed to [resolution.md](./resolution.md) to fix the issues.


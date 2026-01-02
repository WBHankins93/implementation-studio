# Scaling Guide

**Application:** [Application Name]  
**Last Updated:** [Date]  
**Owner:** [Team/Contact]

## Overview

This guide explains how to scale [Application Name] to handle increased load.

## Scaling Types

### Horizontal Scaling (Recommended)

**What it is:** Adding more pod replicas

**When to use:**
- Increased traffic
- Need for high availability
- Stateless applications

**How to scale:**
```bash
# Scale deployment
kubectl scale deployment/[deployment-name] --replicas=[count] -n [namespace-name]

# Or use Helm
helm upgrade [release-name] [chart-path] \
  --set replicaCount=[count] \
  --namespace [namespace-name]
```

### Vertical Scaling

**What it is:** Increasing pod resource limits

**When to use:**
- Application needs more CPU/memory
- Horizontal scaling not possible
- Resource-intensive workloads

**How to scale:**
```bash
# Update deployment with new resource limits
kubectl set resources deployment/[deployment-name] \
  --limits=cpu=[cpu],memory=[memory] \
  --requests=cpu=[cpu],memory=[memory] \
  -n [namespace-name]
```

### Cluster Scaling

**What it is:** Adding more nodes to cluster

**When to use:**
- Cluster resources exhausted
- Need for more capacity
- High availability requirements

**How to scale:**
- GKE: Use node pools and autoscaling
- Kind: Not applicable (local only)

## Autoscaling

### Horizontal Pod Autoscaler (HPA)

**Setup:**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: [deployment-name]-hpa
  namespace: [namespace-name]
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: [deployment-name]
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

**Apply:**
```bash
kubectl apply -f hpa.yaml
```

**Verify:**
```bash
kubectl get hpa -n [namespace-name]
kubectl describe hpa [deployment-name]-hpa -n [namespace-name]
```

### Vertical Pod Autoscaler (VPA)

**Note:** VPA requires VPA controller installed

**Setup:**
```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: [deployment-name]-vpa
  namespace: [namespace-name]
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: [deployment-name]
  updatePolicy:
    updateMode: "Auto"
```

## Scaling Decision Matrix

| Scenario | Action | Method |
|----------|--------|--------|
| Increased traffic | Scale horizontally | Increase replicas or enable HPA |
| High CPU usage | Scale horizontally | Add more pods |
| High memory usage | Scale vertically | Increase memory limits |
| Slow response times | Scale horizontally | Add more pods |
| Cluster resource exhaustion | Scale cluster | Add more nodes |
| Predictable load spikes | Pre-scale | Increase replicas before event |

## Monitoring Scaling

### Key Metrics

**Before Scaling:**
- Current pod count
- CPU/memory usage
- Request rate
- Response times
- Error rates

**After Scaling:**
- New pod count
- CPU/memory usage per pod
- Request distribution
- Response times
- Error rates

### Grafana Dashboards

Monitor scaling effectiveness:
- Cluster Overview dashboard
- Application Health dashboard
- Pod Metrics dashboard

## Scaling Procedures

### Manual Scaling

**Step 1: Assess Current State**
```bash
# Check current replicas
kubectl get deployment [deployment-name] -n [namespace-name]

# Check resource usage
kubectl top pods -n [namespace-name]

# Check metrics in Grafana
```

**Step 2: Determine Target Replicas**
- Based on current load
- Based on expected load
- Based on resource availability

**Step 3: Scale**
```bash
kubectl scale deployment/[deployment-name] --replicas=[count] -n [namespace-name]
```

**Step 4: Monitor**
```bash
# Watch rollout
kubectl rollout status deployment/[deployment-name] -n [namespace-name]

# Check new pods
kubectl get pods -n [namespace-name] -w

# Monitor metrics
# Check Grafana dashboards
```

**Step 5: Verify**
- [ ] All pods running
- [ ] Load distributed
- [ ] Response times improved
- [ ] No errors

### Autoscaling Setup

**Step 1: Enable Metrics Server**
```bash
# Verify metrics server
kubectl get deployment metrics-server -n kube-system
```

**Step 2: Create HPA**
```bash
kubectl apply -f hpa.yaml
```

**Step 3: Test Autoscaling**
```bash
# Generate load (example)
kubectl run -it --rm load-generator --image=busybox --restart=Never -- \
  /bin/sh -c "while true; do wget -q -O- http://[service-name].[namespace-name].svc.cluster.local; done"

# Watch HPA
kubectl get hpa -n [namespace-name] -w

# Watch pods
kubectl get pods -n [namespace-name] -w
```

## Scaling Best Practices

1. **Start Small:** Begin with minimum viable replicas
2. **Monitor First:** Understand baseline before scaling
3. **Use Autoscaling:** Enable HPA for dynamic scaling
4. **Test Scaling:** Verify scaling works before production
5. **Document Thresholds:** Document when to scale
6. **Plan for Scale-Down:** Ensure scale-down works too

## Troubleshooting

### Pods Not Scaling Up

**Check:**
- HPA configuration
- Resource availability
- Pod resource requests
- Cluster capacity

### Pods Scaling Too Aggressively

**Adjust:**
- HPA thresholds
- Min/max replicas
- Scaling policies

### Resource Exhaustion

**Solutions:**
- Scale cluster (add nodes)
- Optimize application
- Reduce resource requests
- Scale down other workloads

## Related Documentation

- [Deployment Runbook](./deployment-runbook.md)
- [Incident Response Playbook](./incident-response.md)
- [Architecture Documentation](../docs/architecture.md)

---

**Remember:** Scale proactively based on metrics, not reactively after issues occur.


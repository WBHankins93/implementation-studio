# Lab 01 Troubleshooting

## Common Issues and Solutions

### Terraform Issues

#### Error: "API not enabled"

**Problem:** Required GCP APIs are not enabled.

**Solution:**
```bash
gcloud services enable \
  container.googleapis.com \
  compute.googleapis.com \
  artifactregistry.googleapis.com
```

#### Error: "Insufficient permissions"

**Problem:** Service account lacks required permissions.

**Solution:** Ensure your account has:
- Compute Admin
- Kubernetes Engine Admin
- Service Account User

```bash
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="user:$(gcloud config get-value account)" \
  --role="roles/container.admin"
```

#### Error: "Quota exceeded"

**Problem:** GCP project has quota limits.

**Solution:**
```bash
# Check quotas
gcloud compute project-info describe --project=$PROJECT_ID

# Request quota increase in GCP Console
```

### Kubernetes Issues

#### kubectl: "Unable to connect to the server"

**Problem:** Cluster credentials not configured.

**Solution:**
```bash
gcloud container clusters get-credentials implementation-studio \
  --region us-central1 \
  --project $PROJECT_ID
```

#### Pods stuck in "Pending"

**Problem:** Insufficient resources or node issues.

**Solution:**
```bash
# Check node status
kubectl get nodes
kubectl describe node <node-name>

# Check pod events
kubectl describe pod <pod-name> -n <namespace>
```

#### Image pull errors

**Problem:** Cannot pull container images.

**Solution:**
- Check internet connectivity from nodes
- Verify image names are correct
- Check if using private registry (requires authentication)

### Argo Workflows Issues

#### Workflow stuck in "Pending"

**Problem:** Workflow controller not running or resource constraints.

**Solution:**
```bash
# Check controller status
kubectl get pods -n argo

# Check workflow events
kubectl describe workflow <workflow-name> -n argo

# Check resource quotas
kubectl get resourcequota -n argo
```

#### Cannot access Argo UI

**Problem:** Ingress not configured or service not exposed.

**Solution:**
```bash
# Check service
kubectl get svc argo-workflows-server -n argo

# Check ingress
kubectl get ingress -n argo

# Port forward as workaround
kubectl port-forward svc/argo-workflows-server 2746:2746 -n argo
# Then access http://localhost:2746
```

### Ingress Issues

#### Ingress IP not assigned

**Problem:** Load balancer provisioning takes time.

**Solution:**
```bash
# Wait 2-5 minutes
kubectl get service ingress-nginx-controller -n ingress-nginx -w

# Check events
kubectl describe service ingress-nginx-controller -n ingress-nginx
```

#### 502 Bad Gateway

**Problem:** Backend service not ready or misconfigured.

**Solution:**
```bash
# Check backend pods
kubectl get pods -n argo

# Check ingress configuration
kubectl describe ingress <ingress-name> -n argo

# Check nginx logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller
```

## Debugging Commands

### Check cluster status
```bash
gcloud container clusters describe implementation-studio \
  --region us-central1 \
  --project $PROJECT_ID
```

### Check node status
```bash
kubectl get nodes -o wide
kubectl describe nodes
```

### Check all resources
```bash
kubectl get all -n argo
kubectl get all -n ingress-nginx
```

### View logs
```bash
# Argo Workflows
kubectl logs -n argo -l app=argo-workflows-server
kubectl logs -n argo -l app=workflow-controller

# Ingress NGINX
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller
```

### Check events
```bash
kubectl get events -n argo --sort-by='.lastTimestamp'
kubectl get events -n ingress-nginx --sort-by='.lastTimestamp'
```

## Getting Help

1. Check the [VALIDATION-STATUS.md](../VALIDATION-STATUS.md)
2. Review GCP logs in Cloud Console
3. Check Kubernetes events: `kubectl get events --all-namespaces`
4. Open an issue on GitHub with:
   - Error messages
   - Relevant logs
   - GCP region and zone
   - Terraform and Kubernetes versions


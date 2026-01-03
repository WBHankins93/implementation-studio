# Lab 06 Troubleshooting

## Common Issues and Solutions

## Provider-Specific Cluster Issues

### Kind Cluster Not Starting

**Problem:** Kind cluster creation fails

**Solutions:**
1. **Check Docker is running:**
   ```bash
   docker ps
   ```

2. **Check available resources:**
   ```bash
   docker info | grep -i memory
   ```

3. **Delete and recreate:**
   ```bash
   kind delete cluster --name multi-tenant-cluster
   kind create cluster --name multi-tenant-cluster
   ```

### GKE Cluster Creation Fails

**Problem:** Terraform fails to create GKE cluster

**Solutions:**
1. **Check APIs enabled:**
   ```bash
   gcloud services enable container.googleapis.com compute.googleapis.com
   ```

2. **Check quotas:**
   ```bash
   gcloud compute project-info describe --project=$PROJECT_ID
   ```

3. **Check permissions:**
   ```bash
   gcloud projects get-iam-policy $PROJECT_ID
   ```

### EKS Cluster Creation Fails

**Problem:** Terraform fails to create EKS cluster

**Solutions:**
1. **Check service-linked role exists:**
   ```bash
   aws iam get-role --role-name AWSServiceRoleForAmazonEKS || \
     aws iam create-service-linked-role --aws-service-name eks.amazonaws.com
   ```

2. **Check IAM permissions:**
   ```bash
   aws sts get-caller-identity
   # Verify you have eks:CreateCluster, eks:DescribeCluster permissions
   ```

3. **Check service quotas:**
   ```bash
   aws service-quotas get-service-quota \
     --service-code eks \
     --quota-code L-1194A341
   ```

### Cannot Access Cluster (kubectl)

**Problem:** `kubectl cluster-info` fails

**GCP Solution:**
```bash
CLUSTER_NAME=$(terraform output -raw cluster_name)
REGION=$(grep region terraform.tfvars | cut -d'"' -f2)
PROJECT_ID=$(grep project_id terraform.tfvars | cut -d'"' -f2)

gcloud container clusters get-credentials $CLUSTER_NAME \
  --region $REGION \
  --project $PROJECT_ID
```

**AWS Solution:**
```bash
CLUSTER_NAME=$(terraform output -raw cluster_name)
REGION=$(grep -E '^region\s*=' terraform.tfvars | sed 's/.*=\s*"\(.*\)".*/\1/' | tr -d ' ')

aws eks update-kubeconfig \
  --region $REGION \
  --name $CLUSTER_NAME
```

---

## Tenant Creation Issues

### Tenant Script Fails

**Problem:** `create-tenant.sh` script fails

**Solutions:**
1. **Check kubectl access:**
   ```bash
   kubectl cluster-info
   ```

2. **Check script permissions:**
   ```bash
   chmod +x tenant-onboarding/create-tenant.sh
   ```

3. **Run manually:**
   ```bash
   # Create namespace
   kubectl create namespace tenant-a
   
   # Apply resources manually
   kubectl apply -f tenant-onboarding/tenant-namespace.yaml
   # (replace {{TENANT_NAME}} first)
   ```

### Namespace Already Exists

**Problem:** Namespace already exists error

**Solutions:**
1. **Delete existing namespace:**
   ```bash
   kubectl delete namespace tenant-a
   ```

2. **Or use existing namespace:**
   ```bash
   # Apply resources to existing namespace
   kubectl apply -f tenant-onboarding/tenant-quotas.yaml -n tenant-a
   ```

---

## RBAC Issues

### User Can't Access Namespace

**Problem:** User gets "forbidden" errors

**Solutions:**
1. **Check RoleBinding:**
   ```bash
   kubectl get rolebinding -n tenant-a
   kubectl describe rolebinding -n tenant-a
   ```

2. **Verify user in RoleBinding:**
   ```bash
   kubectl get rolebinding tenant-admin -n tenant-a -o yaml
   # Check subjects section
   ```

3. **Create/update RoleBinding:**
   ```bash
   kubectl create rolebinding tenant-a-user \
     --role=tenant-admin \
     --user=user@example.com \
     -n tenant-a
   ```

### Service Account Can't Create Resources

**Problem:** Service account gets permission denied

**Solutions:**
1. **Check service account:**
   ```bash
   kubectl get serviceaccount -n tenant-a
   ```

2. **Check RoleBinding for service account:**
   ```bash
   kubectl get rolebinding -n tenant-a
   # Should have binding for service account
   ```

3. **Create RoleBinding:**
   ```bash
   kubectl create rolebinding tenant-sa-binding \
     --role=tenant-admin \
     --serviceaccount=tenant-a:tenant-app \
     -n tenant-a
   ```

---

## Resource Quota Issues

### Pod Creation Fails: Quota Exceeded

**Problem:** Can't create pod, quota exceeded

**Solutions:**
1. **Check quota usage:**
   ```bash
   kubectl describe resourcequota -n tenant-a
   ```

2. **Check current usage:**
   ```bash
   kubectl get pods -n tenant-a
   kubectl top pods -n tenant-a
   ```

3. **Increase quota:**
   ```bash
   kubectl edit resourcequota tenant-quota -n tenant-a
   # Increase limits
   ```

4. **Or delete unused resources:**
   ```bash
   kubectl delete pod <unused-pod> -n tenant-a
   ```

### Quota Not Enforced

**Problem:** Pods created despite exceeding quota

**Solutions:**
1. **Verify ResourceQuota exists:**
   ```bash
   kubectl get resourcequota -n tenant-a
   ```

2. **Check quota status:**
   ```bash
   kubectl describe resourcequota -n tenant-a
   # Should show "Used" and "Hard" limits
   ```

3. **Verify namespace:**
   ```bash
   kubectl get namespace tenant-a
   # Ensure namespace exists and quota is applied
   ```

---

## Network Policy Issues

### Pods Can't Communicate Within Namespace

**Problem:** Pods in same namespace can't reach each other

**Solutions:**
1. **Check network policy:**
   ```bash
   kubectl get networkpolicy -n tenant-a
   kubectl describe networkpolicy -n tenant-a
   ```

2. **Verify policy allows same-namespace traffic:**
   ```yaml
   # Should have:
   ingress:
   - from:
     - namespaceSelector:
         matchLabels:
           name: tenant-a
   ```

3. **Temporarily remove network policy to test:**
   ```bash
   kubectl delete networkpolicy -n tenant-a
   # Test connectivity
   # Recreate policy with correct rules
   ```

### Can't Access Shared Services

**Problem:** Tenant pods can't reach shared services

**Solutions:**
1. **Check shared services network policy:**
   ```bash
   kubectl get networkpolicy -n shared-services
   kubectl describe networkpolicy -n shared-services
   ```

2. **Verify tenant namespace has tenant label:**
   ```bash
   kubectl get namespace tenant-a --show-labels
   # Should have tenant=tenant-a label
   ```

3. **Check shared services policy allows tenant namespaces:**
   ```yaml
   # Should have:
   ingress:
   - from:
     - namespaceSelector:
         matchExpressions:
           - key: tenant
             operator: Exists
   ```

### Cross-Tenant Communication Works (Shouldn't)

**Problem:** Tenants can communicate (isolation not working)

**Solutions:**
1. **Check network policies exist:**
   ```bash
   kubectl get networkpolicy --all-namespaces
   ```

2. **Verify policies block cross-tenant traffic:**
   ```bash
   kubectl describe networkpolicy -n tenant-a
   # Should NOT allow tenant-b namespace
   ```

3. **Check CNI supports NetworkPolicy:**

   **GCP:**
   ```bash
   gcloud container clusters describe <cluster> --region <region> \
     --format="get(networkPolicy.enabled)"
   # Should be True
   ```

   **AWS:**
   ```bash
   # EKS uses VPC CNI which supports NetworkPolicy by default
   # Verify VPC CNI addon is installed
   aws eks describe-addon \
     --cluster-name <cluster-name> \
     --addon-name vpc-cni \
     --region <region>
   ```

   **Kind:**
   ```bash
   # Kind supports NetworkPolicy by default (Calico or Cilium)
   kubectl get nodes
   # Network policies work out of the box
   ```

---

## General Debugging

### Check Tenant Resources

```bash
# List all tenant namespaces
kubectl get namespaces -l tenant

# Check resources in tenant
kubectl get all -n tenant-a

# Check quotas
kubectl get resourcequota -n tenant-a

# Check network policies
kubectl get networkpolicy -n tenant-a

# Check RBAC
kubectl get role,rolebinding -n tenant-a
```

### Test Isolation

```bash
# Test RBAC
kubectl auth can-i get pods -n tenant-b --as=system:serviceaccount:tenant-a:default

# Test network (from tenant-a pod)
kubectl run test --image=busybox -n tenant-a --rm -it --restart=Never -- \
  wget -O- --timeout=5 http://<tenant-b-service>.tenant-b.svc.cluster.local

# Test quota
kubectl run test --image=nginx -n tenant-a \
  --requests=cpu=10,memory=20Gi
```

### View Logs

```bash
# Pod logs
kubectl logs <pod-name> -n tenant-a

# Events
kubectl get events -n tenant-a --sort-by='.lastTimestamp'

# Describe resources
kubectl describe pod <pod-name> -n tenant-a
```

### Provider-Specific Debugging

**GCP:**
```bash
# Check cluster status
gcloud container clusters describe <cluster-name> --region <region> --project <project-id>

# Check node pools
gcloud container node-pools list --cluster <cluster-name> --region <region> --project <project-id>
```

**AWS:**
```bash
# Check cluster status
aws eks describe-cluster --name <cluster-name> --region <region>

# Check node groups
aws eks list-nodegroups --cluster-name <cluster-name> --region <region>

# Check node group details
aws eks describe-nodegroup \
  --cluster-name <cluster-name> \
  --nodegroup-name <nodegroup-name> \
  --region <region>
```

---

## Getting Help

If you're still experiencing issues:

1. **Check Documentation:**
   - [Isolation Strategies](./isolation-strategies.md)
   - [Tenant Lifecycle](./tenant-lifecycle.md)
   - [Resource Management](./resource-management.md)

2. **Review Kubernetes Documentation:**
   - [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
   - [RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
   - [Resource Quotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/)

3. **Open an Issue:** Include:
   - Error messages
   - `kubectl` command results
   - Network policy configurations
   - RBAC configurations
   - Provider (Kind, GCP, or AWS)
   - Cluster region/zone

## Prevention Tips

1. **Test Isolation** - Verify each layer works
2. **Document Configuration** - Keep records of tenant setup
3. **Monitor Quotas** - Watch quota usage regularly
4. **Review RBAC** - Audit permissions periodically
5. **Test Network Policies** - Verify isolation works
6. **Use Scripts** - Automated tenant creation reduces errors
7. **Start with Kind** - Test locally before deploying to cloud

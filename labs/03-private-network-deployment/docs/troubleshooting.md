# Lab 03 Troubleshooting

## Common Issues and Solutions

### Terraform Issues

#### Error: "API not enabled"

**Problem:** Required GCP APIs are not enabled.

**Solution:**
```bash
gcloud services enable \
  container.googleapis.com \
  compute.googleapis.com \
  artifactregistry.googleapis.com \
  servicenetworking.googleapis.com
```

#### Error: "Insufficient permissions"

**Problem:** Service account lacks required permissions.

**Solution:** Ensure your account has:
- Compute Admin
- Kubernetes Engine Admin
- Service Account User
- IAM Admin (for service account creation)

```bash
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="user:$(gcloud config get-value account)" \
  --role="roles/container.admin"
```

#### Error: "Master IP range overlaps with subnets"

**Problem:** `master_ipv4_cidr_block` overlaps with subnet CIDRs.

**Solution:** Use a CIDR that doesn't overlap:
- Private subnet: 10.0.1.0/24
- Management subnet: 10.0.2.0/24
- Master CIDR: 172.16.0.0/28 (recommended)

#### Error: "Quota exceeded"

**Problem:** GCP project has quota limits.

**Solution:**
```bash
# Check quotas
gcloud compute project-info describe --project=$PROJECT_ID

# Request quota increase in GCP Console
# Common quotas: In-use IP addresses, Forwarding rules
```

### Bastion Host Issues

#### Cannot SSH to bastion

**Problem:** Connection timeout or refused.

**Solutions:**
1. **Check firewall rules:**
   ```bash
   gcloud compute firewall-rules list --filter="name~bastion"
   ```

2. **Verify your IP is authorized:**
   ```bash
   # Check terraform.tfvars
   bastion_authorized_networks = ["YOUR.IP.ADDRESS/32"]
   ```

3. **Check bastion status:**
   ```bash
   gcloud compute instances describe <bastion-name> \
     --zone <zone> \
     --project $PROJECT_ID
   ```

4. **Verify external IP:**
   ```bash
   gcloud compute instances describe <bastion-name> \
     --zone <zone> \
     --format="get(networkInterfaces[0].accessConfigs[0].natIP)"
   ```

#### Bastion cannot access cluster

**Problem:** `kubectl` commands fail from bastion.

**Solutions:**
1. **Verify you used `--internal-ip` flag:**
   ```bash
   gcloud container clusters get-credentials <cluster-name> \
     --region <region> \
     --project $PROJECT_ID \
     --internal-ip  # This is critical!
   ```

2. **Check master authorized networks:**
   ```bash
   gcloud container clusters describe <cluster-name> \
     --region <region> \
     --format="get(privateClusterConfig.masterIpv4CidrBlock)"
   ```

3. **Verify bastion subnet is authorized:**
   ```bash
   gcloud container clusters describe <cluster-name> \
     --region <region> \
     --format="get(masterAuthorizedNetworksConfig.cidrBlocks)"
   ```

4. **Check firewall rules:**
   ```bash
   gcloud compute firewall-rules list \
     --filter="name~bastion-to-gke"
   ```

#### kubectl not found on bastion

**Problem:** `kubectl: command not found` on bastion.

**Solution:** The startup script should install it, but if missing:
```bash
# On bastion
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Also install gke-gcloud-auth-plugin
gcloud components install gke-gcloud-auth-plugin -q
```

### Kubernetes Issues

#### kubectl: "Unable to connect to the server"

**Problem:** Cluster credentials not configured or wrong endpoint.

**Solutions:**
1. **From bastion, get credentials with internal IP:**
   ```bash
   gcloud container clusters get-credentials <cluster-name> \
     --region <region> \
     --project $PROJECT_ID \
     --internal-ip
   ```

2. **Verify cluster endpoint:**
   ```bash
   kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}'
   # Should contain "private" or internal IP
   ```

3. **Check cluster status:**
   ```bash
   gcloud container clusters describe <cluster-name> \
     --region <region> \
     --format="get(status)"
   ```

#### Pods stuck in "Pending"

**Problem:** Insufficient resources or node issues.

**Solutions:**
```bash
# Check node status
kubectl get nodes
kubectl describe node <node-name>

# Check if nodes can pull images
kubectl describe pod <pod-name> -n <namespace>

# Verify Private Google Access is enabled
gcloud compute networks subnets describe <subnet-name> \
  --region <region> \
  --format="get(privateIpGoogleAccess)"
```

#### Image pull errors

**Problem:** Cannot pull container images from Artifact Registry.

**Solutions:**
1. **Verify Private Google Access:**
   ```bash
   gcloud compute networks subnets describe <subnet-name> \
     --region <region> \
     --format="get(privateIpGoogleAccess)"
   # Should be True
   ```

2. **Check service account permissions:**
   ```bash
   # Get node service account
   gcloud container clusters describe <cluster-name> \
     --region <region> \
     --format="get(nodeConfig.serviceAccount)"
   
   # Verify it has Artifact Registry Reader role
   gcloud projects get-iam-policy $PROJECT_ID \
     --flatten="bindings[].members" \
     --filter="bindings.members:serviceAccount:<service-account>"
   ```

3. **Test image pull manually:**
   ```bash
   # From a node (via bastion)
   kubectl run test-pull --image=<image-url> --rm -it --restart=Never
   ```

### Network Issues

#### Cannot access internal load balancer

**Problem:** Internal load balancer IP not accessible.

**Solutions:**
1. **Verify load balancer is internal:**
   ```bash
   kubectl get service <service-name> -n <namespace> \
     -o jsonpath='{.metadata.annotations.cloud\.google\.com/load-balancer-type}'
   # Should be "Internal"
   ```

2. **Check load balancer IP:**
   ```bash
   kubectl get service <service-name> -n <namespace>
   # Internal IP should be in VPC range
   ```

3. **Access from within VPC:**
   - Use bastion port forwarding
   - Or access from another VM in VPC
   - Or use VPN/Interconnect

#### Private Google Access not working

**Problem:** Nodes cannot access GCP services.

**Solutions:**
1. **Verify Private Google Access is enabled:**
   ```bash
   gcloud compute networks subnets describe <subnet-name> \
     --region <region> \
     --format="get(privateIpGoogleAccess)"
   ```

2. **Enable if not enabled:**
   ```bash
   gcloud compute networks subnets update <subnet-name> \
     --region <region> \
     --enable-private-ip-google-access
   ```

3. **Test connectivity:**
   ```bash
   # From a node pod
   kubectl run test-connectivity --image=curlimages/curl --rm -it --restart=Never -- \
     curl -I https://storage.googleapis.com
   ```

### Argo Workflows Issues

#### Workflow stuck in "Pending"

**Problem:** Workflow controller not running or resource constraints.

**Solutions:**
```bash
# Check controller status
kubectl get pods -n argo

# Check workflow events
kubectl describe workflow <workflow-name> -n argo

# Check resource quotas
kubectl get resourcequota -n argo
```

#### Cannot access Argo UI

**Problem:** Argo Workflows UI not accessible.

**Solutions:**
1. **Verify internal ingress is created:**
   ```bash
   kubectl get ingress -n argo
   ```

2. **Check internal load balancer:**
   ```bash
   kubectl get service ingress-nginx-controller -n ingress-nginx
   ```

3. **Access via port forwarding:**
   ```bash
   # From bastion
   kubectl port-forward -n argo svc/argo-workflows-server 8080:2746
   
   # From local machine (via SSH tunnel)
   gcloud compute ssh <bastion-name> \
     --zone <zone> \
     --ssh-flag="-L 8080:localhost:8080"
   ```

#### Workflow pods cannot pull images

**Problem:** Workflow pods fail with image pull errors.

**Solutions:**
1. **Verify Private Google Access is enabled**
2. **Check Artifact Registry permissions**
3. **Use images from Artifact Registry (not Docker Hub)**
4. **Configure image pull secrets if needed**

### General Debugging

#### Check cluster connectivity

```bash
# From bastion
kubectl cluster-info
kubectl get nodes
kubectl get namespaces
```

#### Check network policies

```bash
# List network policies
kubectl get networkpolicies --all-namespaces

# Describe specific policy
kubectl describe networkpolicy <policy-name> -n <namespace>
```

#### Check firewall rules

```bash
# List all firewall rules
gcloud compute firewall-rules list

# Describe specific rule
gcloud compute firewall-rules describe <rule-name>
```

#### View logs

```bash
# Cluster logs
gcloud logging read "resource.type=gke_cluster" --limit 50

# Bastion logs
gcloud logging read "resource.type=gce_instance AND resource.labels.instance_id=<instance-id>" --limit 50

# Pod logs
kubectl logs <pod-name> -n <namespace>
```

## Getting Help

If you're still experiencing issues:

1. **Check GCP Status:** https://status.cloud.google.com/
2. **Review Documentation:** 
   - [GKE Private Clusters](https://cloud.google.com/kubernetes-engine/docs/how-to/private-clusters)
   - [Private Google Access](https://cloud.google.com/vpc/docs/private-google-access)
3. **Open an Issue:** Include:
   - Error messages
   - Terraform output
   - `kubectl` command results
   - GCP region and project ID (redacted)

## Prevention Tips

1. **Always use `--internal-ip`** when getting credentials for private clusters
2. **Restrict bastion authorized networks** to your IP
3. **Verify Private Google Access** is enabled before deploying
4. **Test connectivity** from bastion before deploying applications
5. **Monitor firewall rules** to ensure they're correct
6. **Keep bastion updated** with latest security patches


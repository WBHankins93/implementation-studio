# Lab 04 Troubleshooting

## Common Issues and Solutions

### Terraform Issues

#### Error: "API not enabled" (GCP)

**Problem:** Required GCP APIs are not enabled.

**Solution:**
```bash
gcloud services enable \
  container.googleapis.com \
  compute.googleapis.com \
  artifactregistry.googleapis.com \
  servicenetworking.googleapis.com
```

#### Error: "Firewall rule conflicts" (GCP)

**Problem:** Firewall rules have conflicting priorities or overlap.

**Solution:**
- Check existing firewall rules: `gcloud compute firewall-rules list`
- Verify rule priorities don't conflict
- Ensure destination ranges don't overlap incorrectly

#### Error: "Insufficient permissions" (AWS)

**Problem:** AWS credentials don't have required permissions.

**Solution:**
- Verify IAM permissions for EKS, EC2, VPC, ECR
- Check credentials: `aws sts get-caller-identity`
- Ensure required IAM policies are attached

#### Error: "Security group rule conflicts" (AWS)

**Problem:** Security group rules conflict or exceed limits.

**Solution:**
- AWS security groups have a limit of 60 rules per group
- Check existing rules: `aws ec2 describe-security-groups`
- Verify no duplicate rules exist
- Consider consolidating rules

### Proxy Issues

#### Proxy server not accessible

**Problem:** Cannot connect to proxy from cluster nodes.

**GCP Solutions:**
1. **Check proxy is running:**
   ```bash
   gcloud compute ssh <proxy-name> --zone <zone>
   sudo systemctl status squid
   ```

2. **Check firewall rules:**
   ```bash
   gcloud compute firewall-rules list --filter="name~proxy"
   ```

3. **Verify proxy IP:**
   ```bash
   terraform output proxy_internal_ip
   ```

4. **Test connectivity from node:**
   ```bash
   kubectl run test-proxy --image=curlimages/curl --rm -i --restart=Never -- \
     curl -v http://<proxy-ip>:3128
   ```

**AWS Solutions:**
1. **Check proxy is running:**
   ```bash
   # SSH to proxy (requires SSH key)
   ssh -i ~/.ssh/id_rsa ec2-user@<proxy-public-ip>
   sudo systemctl status squid
   ```

2. **Check security groups:**
   ```bash
   # Get proxy security group
   PROXY_SG=$(aws ec2 describe-instances \
     --filters "Name=tag:Name,Values=<proxy-name>" \
     --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' \
     --output text)
   
   # Check ingress rules
   aws ec2 describe-security-group-rules \
     --filters "Name=group-id,Values=$PROXY_SG" \
     --query 'SecurityGroupRules[?IsEgress==`false`]'
   ```

3. **Verify proxy IP:**
   ```bash
   terraform output proxy_internal_ip
   ```

4. **Test connectivity from node:**
   ```bash
   kubectl run test-proxy --image=curlimages/curl --rm -i --restart=Never -- \
     curl -v http://<proxy-ip>:3128
   ```

#### Proxy not forwarding traffic

**Problem:** Proxy accepts connections but doesn't forward.

**Solutions:**
1. **Check Squid configuration:**
   ```bash
   # GCP
   gcloud compute ssh <proxy-name> --zone <zone>
   
   # AWS
   ssh -i ~/.ssh/id_rsa ec2-user@<proxy-public-ip>
   
   # Then on proxy
   sudo cat /etc/squid/squid.conf
   ```

2. **Check Squid logs:**
   ```bash
   sudo tail -f /var/log/squid/access.log
   ```

3. **Verify proxy has external IP:**
   ```bash
   # GCP
   gcloud compute instances describe <proxy-name> --zone <zone> \
     --format="get(networkInterfaces[0].accessConfigs[0].natIP)"
   
   # AWS
   terraform output proxy_external_ip
   ```

### Firewall/Security Group Issues

#### Egress still working without proxy

**Problem:** Direct egress works despite strict rules.

**GCP Solutions:**
1. **Verify firewall rules are applied:**
   ```bash
   gcloud compute firewall-rules list --filter="direction=EGRESS"
   ```

2. **Check node tags:**
   ```bash
   gcloud container clusters describe <cluster-name> --region <region> \
     --format="get(nodeConfig.tags)"
   ```
   Ensure nodes have the tags specified in firewall rules.

3. **Verify rule priority:**
   Deny-all should have lower priority (higher number) than allow rules.

4. **Check for other firewall rules:**
   ```bash
   gcloud compute firewall-rules list --filter="network=<vpc-name>"
   ```

**AWS Solutions:**
1. **Verify security groups are attached:**
   ```bash
   # Get node group security groups
   NODE_SG=$(aws eks describe-nodegroup \
     --cluster-name <cluster-name> \
     --nodegroup-name <nodegroup-name> \
     --query 'nodegroup.resources.remoteAccessSecurityGroup' \
     --output text)
   
   # Check egress rules
   aws ec2 describe-security-group-rules \
     --filters "Name=group-id,Values=$NODE_SG" \
     --query 'SecurityGroupRules[?IsEgress==`true`]'
   ```

2. **Verify no default allow-all egress:**
   AWS security groups are allow-only, so ensure only specific allow rules exist.

3. **Check security group is attached to nodes:**
   ```bash
   aws eks describe-nodegroup \
     --cluster-name <cluster-name> \
     --nodegroup-name <nodegroup-name> \
     --query 'nodegroup.resources'
   ```

#### Cannot access specific endpoint

**Problem:** Application cannot reach required external endpoint.

**Solutions:**
1. **Check if endpoint is in allowlist:**
   ```bash
   terraform output -json allowed_external_endpoints
   ```

2. **Test from proxy:**
   ```bash
   # GCP
   gcloud compute ssh <proxy-name> --zone <zone>
   
   # AWS
   ssh -i ~/.ssh/id_rsa ec2-user@<proxy-public-ip>
   
   # Then on proxy
   curl -v https://<endpoint>
   ```

3. **Add to allowlist if needed:**
   Update `allowed_external_endpoints` in `terraform.tfvars` and reapply.

### Kubernetes Issues

#### Pods cannot pull images

**Problem:** Image pull fails with timeout or connection refused.

**Solutions:**
1. **Verify proxy configuration:**
   ```bash
   kubectl get configmap proxy-config -n argo -o yaml
   ```

2. **Check proxy IP is correct:**
   ```bash
   terraform output proxy_internal_ip
   kubectl get configmap proxy-config -n argo -o jsonpath='{.data.HTTP_PROXY}'
   ```

3. **Test image pull with proxy:**
   ```bash
   kubectl run test-pull --image=curlimages/curl --rm -i --restart=Never \
     --env="HTTP_PROXY=http://<proxy-ip>:3128" \
     --env="HTTPS_PROXY=http://<proxy-ip>:3128" \
     -- curl -v https://quay.io
   ```

4. **Check network policies:**
   ```bash
   kubectl get networkpolicy -n argo
   kubectl describe networkpolicy deny-all-egress -n argo
   ```

#### Argo Workflows not using proxy

**Problem:** Workflows fail to connect to external services.

**Solutions:**
1. **Verify Argo server has proxy env vars:**
   ```bash
   kubectl get deployment argo-workflows-server -n argo -o yaml | grep -i proxy
   ```

2. **Check workflow pod spec:**
   ```bash
   kubectl get workflow <workflow-name> -n argo -o yaml | grep -i proxy
   ```

3. **Verify ConfigMap is mounted:**
   ```bash
   kubectl describe deployment argo-workflows-server -n argo | grep -i proxy
   ```

4. **Check workflow controller:**
   ```bash
   kubectl logs -n argo -l app=argo-workflows-controller | grep -i proxy
   ```

### Network Policy Issues

#### Pods cannot communicate internally

**Problem:** Network policy is too restrictive.

**Solutions:**
1. **Check network policy:**
   ```bash
   kubectl get networkpolicy -n argo
   kubectl describe networkpolicy deny-all-egress -n argo
   ```

2. **Verify internal traffic is allowed:**
   Network policy should allow:
   - DNS (UDP/TCP port 53)
   - Internal cluster communication
   - Proxy access

3. **Temporarily disable network policy for testing:**
   ```bash
   kubectl delete networkpolicy deny-all-egress -n argo
   # Test, then recreate with correct rules
   ```

### General Debugging

#### Test egress restrictions

```bash
# Run the test script
./scripts/test-egress.sh

# Or manually test
kubectl run test-direct --image=curlimages/curl --rm -i --restart=Never -- \
  curl -v --max-time 5 https://www.google.com

kubectl run test-proxy --image=curlimages/curl --rm -i --restart=Never \
  --env="HTTP_PROXY=http://<proxy-ip>:3128" \
  --env="HTTPS_PROXY=http://<proxy-ip>:3128" \
  -- curl -v https://www.google.com
```

#### Check firewall rules (GCP)

```bash
# List all egress rules
gcloud compute firewall-rules list --filter="direction=EGRESS"

# Describe specific rule
gcloud compute firewall-rules describe <rule-name>

# Check rule priority
gcloud compute firewall-rules list --format="table(name,priority,direction)"
```

#### Check security groups (AWS)

```bash
# Get security group IDs
SECURITY_GROUPS=$(terraform output -raw security_groups)

# Describe security groups
for sg in $(echo $SECURITY_GROUPS | tr ',' ' '); do
  aws ec2 describe-security-groups --group-ids $sg --region <region>
done

# Check egress rules
aws ec2 describe-security-group-rules \
  --filters "Name=group-id,Values=<security-group-id>" \
  --query 'SecurityGroupRules[?IsEgress==`true`]' \
  --region <region>
```

#### View proxy logs

```bash
# GCP
gcloud compute ssh <proxy-name> --zone <zone>

# AWS
ssh -i ~/.ssh/id_rsa ec2-user@<proxy-public-ip>

# Then on proxy
sudo tail -f /var/log/squid/access.log
sudo tail -f /var/log/squid/cache.log
```

#### Check VPC Flow Logs

**GCP:**
```bash
# View flow logs (if enabled)
gcloud logging read "resource.type=gce_instance AND jsonPayload.src_instance.vm_name=~\"gke\"" --limit 50
```

**AWS:**
```bash
# View VPC Flow Logs (if enabled)
aws logs tail <log-group-name> --follow --region <region>
```

## Provider-Specific Notes

### GCP Firewall Rules
- Rules are network-level and apply to all instances with matching tags
- Can explicitly deny traffic (deny-all rule)
- Rules have priorities (lower number = higher priority)
- Private Google Access can be enabled for GCP services

### AWS Security Groups
- Rules are allow-only (implicit deny for unmatched traffic)
- Rules apply at the instance/ENI level
- Each instance can have multiple security groups
- VPC prefix lists can be used for AWS services
- Security groups have a limit of 60 rules per group

## Getting Help

If you're still experiencing issues:

1. **Check Cloud Status:**
   - GCP: https://status.cloud.google.com/
   - AWS: https://status.aws.amazon.com/

2. **Review Documentation:**
   - [GCP Firewall Rules](https://cloud.google.com/vpc/docs/firewalls)
   - [AWS Security Groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html)
   - [Kubernetes Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
   - [Squid Proxy](http://www.squid-cache.org/)

3. **Open an Issue:** Include:
   - Error messages
   - Terraform output
   - `kubectl` command results
   - Proxy logs
   - Firewall rule/security group configuration
   - Cloud provider (GCP or AWS)

## Prevention Tips

1. **Test firewall rules/security groups** before deploying applications
2. **Verify proxy configuration** matches actual proxy IP
3. **Document all endpoints** before requesting firewall rules
4. **Use network policies** to complement firewall/security group rules
5. **Monitor proxy logs** to identify issues early
6. **Test egress restrictions** regularly with test script
7. **Understand provider differences** (GCP firewall rules vs AWS security groups)

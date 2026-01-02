# Lab 04 Troubleshooting

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

#### Error: "Firewall rule conflicts"

**Problem:** Firewall rules have conflicting priorities or overlap.

**Solution:**
- Check existing firewall rules: `gcloud compute firewall-rules list`
- Verify rule priorities don't conflict
- Ensure destination ranges don't overlap incorrectly

### Proxy Issues

#### Proxy server not accessible

**Problem:** Cannot connect to proxy from GKE nodes.

**Solutions:**
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

#### Proxy not forwarding traffic

**Problem:** Proxy accepts connections but doesn't forward.

**Solutions:**
1. **Check Squid configuration:**
   ```bash
   gcloud compute ssh <proxy-name> --zone <zone>
   sudo cat /etc/squid/squid.conf
   ```

2. **Check Squid logs:**
   ```bash
   sudo tail -f /var/log/squid/access.log
   ```

3. **Verify proxy has external IP:**
   ```bash
   gcloud compute instances describe <proxy-name> --zone <zone> \
     --format="get(networkInterfaces[0].accessConfigs[0].natIP)"
   ```

### Firewall Issues

#### Egress still working without proxy

**Problem:** Direct egress works despite strict firewall rules.

**Solutions:**
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

#### Cannot access specific endpoint

**Problem:** Application cannot reach required external endpoint.

**Solutions:**
1. **Check if endpoint is in allowlist:**
   ```bash
   terraform output -json allowed_external_endpoints
   ```

2. **Test from proxy:**
   ```bash
   gcloud compute ssh <proxy-name> --zone <zone>
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

#### Check firewall rules

```bash
# List all egress rules
gcloud compute firewall-rules list --filter="direction=EGRESS"

# Describe specific rule
gcloud compute firewall-rules describe <rule-name>

# Check rule priority
gcloud compute firewall-rules list --format="table(name,priority,direction)"
```

#### View proxy logs

```bash
# SSH to proxy
gcloud compute ssh <proxy-name> --zone <zone>

# View access log
sudo tail -f /var/log/squid/access.log

# View cache log
sudo tail -f /var/log/squid/cache.log
```

#### Check VPC Flow Logs

```bash
# View flow logs (if enabled)
gcloud logging read "resource.type=gce_instance AND jsonPayload.src_instance.vm_name=~\"gke\"" --limit 50
```

## Getting Help

If you're still experiencing issues:

1. **Check GCP Status:** https://status.cloud.google.com/
2. **Review Documentation:**
   - [GCP Firewall Rules](https://cloud.google.com/vpc/docs/firewalls)
   - [Kubernetes Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
   - [Squid Proxy](http://www.squid-cache.org/)
3. **Open an Issue:** Include:
   - Error messages
   - Terraform output
   - `kubectl` command results
   - Proxy logs
   - Firewall rule configuration

## Prevention Tips

1. **Test firewall rules** before deploying applications
2. **Verify proxy configuration** matches actual proxy IP
3. **Document all endpoints** before requesting firewall rules
4. **Use network policies** to complement firewall rules
5. **Monitor proxy logs** to identify issues early
6. **Test egress restrictions** regularly with test script


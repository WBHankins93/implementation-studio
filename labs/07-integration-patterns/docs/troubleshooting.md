# Troubleshooting: Integration Patterns

Common issues and solutions for integration patterns in Lab 07.

## Authentication Integration

### OAuth2 Proxy

#### Redirect URI Mismatch

**Problem:** OAuth provider rejects redirect URI

**Symptoms:**
- Error: "redirect_uri_mismatch"
- Authentication fails after OAuth provider login

**Solution:**
1. Check redirect URI in OAuth app matches exactly:
   - Protocol (http vs https)
   - Domain
   - Path (`/oauth2/callback`)
2. Update OAuth app configuration
3. Restart OAuth2 Proxy

**Prevention:**
- Use consistent domain configuration
- Document redirect URI requirements

#### Cookie Issues

**Problem:** Users keep getting redirected to login

**Symptoms:**
- Users authenticated but redirected to login
- Session not persisting

**Solution:**
1. Check cookie domain matches your domain
2. Ensure cookie secret is set correctly
3. Check cookie secure flag (should be true for HTTPS)
4. Verify cookie samesite setting

**Debug:**
```bash
# Check OAuth2 Proxy logs
kubectl logs -n oauth-proxy deployment/oauth2-proxy

# Check cookie settings in config
kubectl get configmap oauth2-proxy-config -n oauth-proxy -o yaml
```

#### Token Validation Failed

**Problem:** OAuth tokens not validating

**Symptoms:**
- Authentication succeeds but access denied
- Token validation errors in logs

**Solution:**
1. Verify token issuer matches configuration
2. Check token expiration
3. Validate token signature
4. Ensure correct OAuth provider configuration

### SAML

#### Assertion Not Accepted

**Problem:** SAML assertion rejected

**Symptoms:**
- SAML response received but not accepted
- Authentication fails after IdP login

**Solution:**
1. Verify certificate matches IdP
2. Check entity IDs match
3. Validate assertion signature
4. Check assertion expiration
5. Verify ACS URL is correct

**Debug:**
- Check SAML response in browser developer tools
- Validate SAML assertion format
- Check application logs

#### Redirect Loop

**Problem:** Infinite redirect between app and IdP

**Symptoms:**
- Continuous redirects
- Never reaches authenticated state

**Solution:**
1. Verify SAML response is being processed
2. Check session creation
3. Validate assertion format
4. Ensure application handles SAML response correctly

### LDAP/AD

#### Connection Refused

**Problem:** Cannot connect to LDAP server

**Symptoms:**
- Connection timeout
- "Connection refused" errors

**Solution:**
1. Check server accessibility:
   ```bash
   telnet ldap-server 389
   ```
2. Verify port (389 for LDAP, 636 for LDAPS)
3. Check firewall rules
4. Verify network connectivity

#### Authentication Failed

**Problem:** LDAP bind fails

**Symptoms:**
- "Invalid credentials" errors
- User not found

**Solution:**
1. Verify bind DN is correct
2. Check password is correct
3. Verify user exists in LDAP
4. Validate search filter
5. Check user permissions

**Debug:**
```bash
# Test LDAP connection
ldapsearch -H ldap://ldap-server -x -D "bind-dn" -w "password" -b "base-dn" "(uid=testuser)"
```

## Database Integration

### Cloud SQL Proxy

#### Connection Refused

**Problem:** Cannot connect to Cloud SQL

**Symptoms:**
- Connection timeout
- "Connection refused" errors

**Solution:**
1. Check Cloud SQL instance is running:
   ```bash
   gcloud sql instances describe INSTANCE_NAME
   ```
2. Verify connection name is correct:
   ```
   PROJECT_ID:REGION:INSTANCE_NAME
   ```
3. Check service account has permissions:
   ```bash
   gcloud projects get-iam-policy PROJECT_ID \
     --flatten="bindings[].members" \
     --filter="bindings.members:serviceAccount:cloud-sql-proxy@*"
   ```
4. Verify Workload Identity is configured
5. Check proxy pod logs:
   ```bash
   kubectl logs -n database deployment/cloud-sql-proxy
   ```

#### Authentication Failed

**Problem:** IAM authentication fails

**Symptoms:**
- "Permission denied" errors
- Authentication errors

**Solution:**
1. Verify service account has `cloudsql.client` role
2. Check Workload Identity binding:
   ```bash
   gcloud iam service-accounts get-iam-policy \
     cloud-sql-proxy@PROJECT_ID.iam.gserviceaccount.com
   ```
3. Verify service account annotation in pod spec
4. Check proxy pod service account

#### Connection Pool Exhausted

**Problem:** Too many connections

**Symptoms:**
- "Too many connections" errors
- Connection wait times

**Solution:**
1. Increase connection pool size
2. Reduce connection lifetime
3. Check for connection leaks
4. Monitor connection usage

### External Database

#### Connection Timeout

**Problem:** Cannot connect to external database

**Symptoms:**
- Connection timeout
- Network unreachable

**Solution:**
1. Check network connectivity:
   ```bash
   kubectl run -it --rm debug --image=busybox --restart=Never -- \
     telnet database-host 5432
   ```
2. Verify firewall rules
3. Check DNS resolution
4. Verify VPN status (if applicable)
5. Check database is accessible from GKE nodes

#### SSL/TLS Errors

**Problem:** SSL certificate validation fails

**Symptoms:**
- "Certificate verify failed" errors
- SSL handshake errors

**Solution:**
1. Verify certificate is valid
2. Check certificate chain is complete
3. Validate SSL mode matches database configuration
4. Consider using `verify-ca` or `require` mode

## API Gateway

### Kong

#### 502 Bad Gateway

**Problem:** Kong cannot reach backend

**Symptoms:**
- 502 errors from Kong
- Backend unreachable

**Solution:**
1. Verify backend service is running:
   ```bash
   kubectl get svc -n argo
   ```
2. Check backend URL in Kong config
3. Verify network connectivity from Kong to backend
4. Check backend service endpoints

**Debug:**
```bash
# Check Kong logs
kubectl logs -n kong deployment/kong

# Test backend directly
kubectl port-forward -n argo svc/argo-workflows-server 2746:2746
curl http://localhost:2746
```

#### Rate Limiting Not Working

**Problem:** Rate limits not enforced

**Symptoms:**
- Requests exceed rate limit
- No rate limit errors

**Solution:**
1. Verify rate limiting plugin is enabled
2. Check plugin configuration
3. Verify plugin is applied to correct route
4. Check Kong admin API for plugin status

### GCP API Gateway

#### 502 Bad Gateway

**Problem:** API Gateway cannot reach backend

**Symptoms:**
- 502 errors from API Gateway
- Backend unreachable

**Solution:**
1. Verify backend service is accessible
2. Check service account has permissions
3. Verify backend URL in API config
4. Check backend service health

#### Authentication Failed

**Problem:** API key or JWT validation fails

**Symptoms:**
- 401 Unauthorized errors
- Authentication errors

**Solution:**
1. Verify API key is valid (if using)
2. Check JWT token is valid (if using)
3. Validate security definitions in API config
4. Check token issuer and audience

## Service Mesh

### Istio

#### Sidecar Not Injected

**Problem:** Pod doesn't have Envoy sidecar

**Symptoms:**
- Pod running but no sidecar
- Traffic not going through mesh

**Solution:**
1. Verify namespace has injection enabled:
   ```bash
   kubectl get namespace default -o jsonpath='{.metadata.labels.istio-injection}'
   ```
2. Enable injection:
   ```bash
   kubectl label namespace default istio-injection=enabled
   ```
3. Restart pods to get sidecar
4. Check Istio control plane is running

#### mTLS Handshake Failed

**Problem:** Services cannot communicate with mTLS

**Symptoms:**
- Connection errors between services
- mTLS handshake failures

**Solution:**
1. Verify PeerAuthentication policy
2. Check mTLS mode (STRICT, PERMISSIVE, DISABLE)
3. Verify certificates are valid
4. Check service mesh configuration

## General Troubleshooting

### Check Pod Logs

```bash
# Get pod logs
kubectl logs -n NAMESPACE deployment/DEPLOYMENT_NAME

# Follow logs
kubectl logs -f -n NAMESPACE deployment/DEPLOYMENT_NAME

# Get logs from all pods
kubectl logs -n NAMESPACE -l app=APP_NAME
```

### Check Pod Status

```bash
# Get pod status
kubectl get pods -n NAMESPACE

# Describe pod
kubectl describe pod -n NAMESPACE POD_NAME

# Get pod events
kubectl get events -n NAMESPACE --sort-by='.lastTimestamp'
```

### Check Service Status

```bash
# Get services
kubectl get svc -n NAMESPACE

# Describe service
kubectl describe svc -n NAMESPACE SERVICE_NAME

# Get endpoints
kubectl get endpoints -n NAMESPACE SERVICE_NAME
```

### Network Debugging

```bash
# Test connectivity from pod
kubectl run -it --rm debug --image=busybox --restart=Never -- \
  wget -O- http://service.namespace.svc.cluster.local

# Check DNS resolution
kubectl run -it --rm debug --image=busybox --restart=Never -- \
  nslookup service.namespace.svc.cluster.local
```

### Check Configuration

```bash
# Get ConfigMap
kubectl get configmap -n NAMESPACE CONFIGMAP_NAME -o yaml

# Get Secret (base64 encoded)
kubectl get secret -n NAMESPACE SECRET_NAME -o yaml

# Decode secret
kubectl get secret -n NAMESPACE SECRET_NAME -o jsonpath='{.data.key}' | base64 -d
```

## Getting Help

If you're stuck:

1. Check the specific integration pattern README
2. Review architecture documentation
3. Check application logs
4. Verify configuration matches examples
5. Test connectivity manually
6. Review GCP/cloud provider documentation

## Additional Resources

- [Kubernetes Troubleshooting](https://kubernetes.io/docs/tasks/debug/)
- [OAuth2 Proxy Issues](https://github.com/oauth2-proxy/oauth2-proxy/issues)
- [Cloud SQL Troubleshooting](https://cloud.google.com/sql/docs/postgres/troubleshooting)
- [Kong Troubleshooting](https://docs.konghq.com/gateway/latest/troubleshooting/)


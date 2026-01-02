# Common Troubleshooting Patterns

**Purpose:** Recognize common issue patterns for faster diagnosis.

## Overview

Pattern recognition is key to efficient troubleshooting. This guide helps you identify common patterns and their solutions.

## Pattern Recognition Framework

### Pattern: Network Connectivity

**Symptoms:**
- Connection timeouts
- Connection refused
- Network unreachable
- Services unreachable

**Quick Checks:**
1. Check network policies: `kubectl get networkpolicies`
2. Check service endpoints: `kubectl get endpoints`
3. Test connectivity: `kubectl exec [pod] -- wget [service]`
4. Check DNS: `kubectl exec [pod] -- nslookup [service]`

**Common Causes:**
- Network policy blocking traffic
- Service has no endpoints
- DNS resolution failing
- Firewall rules

**Quick Fix:**
- Review network policies
- Verify service selectors
- Check DNS configuration

### Pattern: Resource Exhaustion

**Symptoms:**
- OOMKilled pods
- Pending pods
- High CPU/memory usage
- Pods restarting

**Quick Checks:**
1. Check resource usage: `kubectl top pods`
2. Check resource quotas: `kubectl get resourcequota`
3. Check pod limits: `kubectl describe pod`
4. Check node capacity: `kubectl top nodes`

**Common Causes:**
- Resource quota too restrictive
- Node capacity exhausted
- Memory leaks
- Resource requests too high

**Quick Fix:**
- Increase resource quotas
- Scale cluster
- Fix memory leaks
- Adjust resource requests

### Pattern: Permission Denied

**Symptoms:**
- Forbidden errors
- Access denied
- Permission denied
- Unauthorized

**Quick Checks:**
1. Check RBAC: `kubectl get role,rolebinding`
2. Check service account: `kubectl get serviceaccount`
3. Test permissions: `kubectl auth can-i`
4. Check pod service account: `kubectl get pod -o jsonpath='{.spec.serviceAccountName}'`

**Common Causes:**
- Missing RBAC configuration
- Wrong service account
- Insufficient permissions
- File permission issues

**Quick Fix:**
- Create Role and RoleBinding
- Use correct service account
- Grant required permissions

### Pattern: Image Pull Failure

**Symptoms:**
- ImagePullBackOff
- ErrImagePull
- Failed to pull image
- Authentication errors

**Quick Checks:**
1. Check pod events: `kubectl describe pod`
2. Verify image name: `kubectl get pod -o jsonpath='{.spec.containers[0].image}'`
3. Check image pull secrets: `kubectl get secrets`
4. Test image pull: `docker pull [image]`

**Common Causes:**
- Image doesn't exist
- Wrong image name/tag
- Missing image pull secret
- Registry authentication failure

**Quick Fix:**
- Use correct image name
- Configure image pull secrets
- Verify image exists
- Check registry access

### Pattern: DNS Resolution Failure

**Symptoms:**
- Name or service not known
- DNS resolution timeout
- Services unreachable by name
- External DNS failures

**Quick Checks:**
1. Check CoreDNS: `kubectl get pods -n kube-system | grep coredns`
2. Test DNS: `kubectl exec [pod] -- nslookup [service]`
3. Check DNS config: `kubectl exec [pod] -- cat /etc/resolv.conf`
4. Check DNS policy: `kubectl get pod -o jsonpath='{.spec.dnsPolicy}'`

**Common Causes:**
- CoreDNS not running
- Wrong DNS configuration
- Network policy blocking DNS
- Custom DNS without cluster DNS

**Quick Fix:**
- Ensure CoreDNS is running
- Use default DNS policy
- Include cluster DNS in custom config
- Check network policies

### Pattern: Certificate/TLS Failure

**Symptoms:**
- Certificate verify failed
- TLS handshake failure
- Certificate expired
- x509 errors

**Quick Checks:**
1. Check certificate expiration: `openssl x509 -noout -dates -in cert.pem`
2. Test certificate: `openssl s_client -connect [host]:443`
3. Check certificate chain: `openssl s_client -showcerts`
4. Review error messages: Check pod logs

**Common Causes:**
- Expired certificate
- Invalid certificate
- Wrong CA
- Incomplete certificate chain

**Quick Fix:**
- Renew certificate
- Use valid certificate
- Add custom CA if needed
- Include full certificate chain

## Pattern Recognition Tips

### 1. Look for Error Messages

**Key Error Messages:**
- `OOMKilled` → Resource exhaustion
- `ImagePullBackOff` → Image pull failure
- `Forbidden` → Permission issue
- `Connection refused` → Network issue
- `certificate verify failed` → Certificate issue

### 2. Check Pod Status

**Status Patterns:**
- `Pending` → Scheduling issue (resources, constraints)
- `CrashLoopBackOff` → Application error, resource issue
- `ImagePullBackOff` → Image pull failure
- `Error` → Application error, permission issue
- `Running` but not working → Network, configuration, dependency issue

### 3. Review Events

**Event Patterns:**
- `FailedScheduling` → Resource constraints
- `Failed` → Application or configuration error
- `OOMKilling` → Memory exhaustion
- `FailedMount` → Volume or storage issue

### 4. Check Resource Usage

**Resource Patterns:**
- High CPU → Performance issue, resource limits
- High memory → Memory leak, resource limits
- Low resources → Resource quota, node capacity

## Quick Reference Matrix

| Symptom | Quick Check | Common Cause | Quick Fix |
|---------|-------------|--------------|-----------|
| Connection timeout | Network policies | Policy blocking | Review/update policy |
| OOMKilled | Resource limits | Memory limit exceeded | Increase limit |
| Pending pod | Resource quota | Quota exhausted | Increase quota |
| Forbidden | RBAC | Missing permissions | Create Role/RoleBinding |
| ImagePullBackOff | Image name | Image doesn't exist | Fix image name |
| DNS failure | CoreDNS | DNS not configured | Fix DNS config |
| Certificate error | Certificate | Expired/invalid | Renew certificate |

## Building Your Pattern Library

### Document Patterns

**For Each Pattern:**
1. Symptoms
2. Quick checks
3. Common causes
4. Quick fixes
5. Prevention

### Practice Recognition

**Ways to Practice:**
1. Work through scenarios
2. Review real incidents
3. Build mental models
4. Share with team

### Continuous Learning

**Improve Recognition:**
- Review incidents
- Update patterns
- Share knowledge
- Practice regularly

## Related Documentation

- [Systematic Debugging](./systematic-debugging.md)
- [Escalation Guide](./escalation-guide.md)
- [Troubleshooting Reference](./troubleshooting-reference.md)

---

**Remember:** Pattern recognition comes with experience. The more issues you see, the faster you'll recognize patterns.


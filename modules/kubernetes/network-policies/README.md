# Network Policies Module

Common Kubernetes NetworkPolicy patterns for multi-tenant isolation and security.

## Patterns

### deny-all.yaml

Denies all ingress and egress traffic. Use as a baseline, then add specific allow rules.

**Use Case:** Maximum security, start restrictive

### namespace-isolation.yaml

Isolates namespace from other namespaces while allowing:
- Traffic within the namespace
- Traffic to/from shared-services namespace
- DNS queries

**Use Case:** Multi-tenant isolation

### allow-ingress.yaml

Allows all ingress traffic. Use when namespace needs to receive traffic from anywhere.

**Use Case:** Public-facing services

### allow-egress-dns.yaml

Allows egress to DNS and within namespace. Restricts other egress.

**Use Case:** Namespaces that need DNS but limited external access

## Usage

### Apply Network Policy

```bash
# Deny all (baseline)
kubectl apply -f deny-all.yaml -n <namespace>

# Namespace isolation
kubectl apply -f namespace-isolation.yaml -n <namespace>
```

### Template Variables

Some policies use `{{NAMESPACE}}` placeholder. Replace with actual namespace name:

```bash
sed "s/{{NAMESPACE}}/tenant-a/g" namespace-isolation.yaml | kubectl apply -f - -n tenant-a
```

## Best Practices

1. **Start Restrictive**: Begin with deny-all, add specific allows
2. **Test Thoroughly**: Verify policies don't break functionality
3. **Document Rules**: Explain why each rule exists
4. **Review Regularly**: Remove unused rules
5. **Monitor Impact**: Watch for connectivity issues

## Additional Resources

- [Kubernetes Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [Network Policy Best Practices](https://kubernetes.io/docs/concepts/services-networking/network-policies/#best-practices)


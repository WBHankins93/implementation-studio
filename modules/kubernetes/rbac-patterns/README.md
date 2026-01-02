# RBAC Patterns Module

Common Kubernetes RBAC (Role-Based Access Control) patterns for multi-tenant deployments.

## Patterns

### namespace-admin.yaml

Full administrative access within a namespace. Can create, read, update, delete all resources.

**Use Case:** Tenant administrators who need full control

**Permissions:**
- All resources in namespace
- All verbs (create, read, update, delete, patch)

### read-only.yaml

Read-only access to namespace resources. Can view but not modify.

**Use Case:** Monitoring, auditing, troubleshooting

**Permissions:**
- All resources in namespace
- Read-only verbs (get, list, watch)

### deployment-only.yaml

Can deploy and manage applications but not modify namespace-level resources.

**Use Case:** Application developers who need to deploy but not manage infrastructure

**Permissions:**
- Pods, services, configmaps, secrets
- Deployments, replicasets
- Create, update, delete operations

## Usage

### Apply RBAC Pattern

```bash
# Replace template variables
sed "s/{{NAMESPACE}}/tenant-a/g; s/{{USER}}/user@example.com/g" namespace-admin.yaml | \
  kubectl apply -f -
```

### Template Variables

- `{{NAMESPACE}}`: Namespace name
- `{{USER}}`: User email or name

## Best Practices

1. **Principle of Least Privilege**: Grant minimum permissions needed
2. **Namespace Scoping**: Use Role/RoleBinding (not ClusterRole) for namespace isolation
3. **Service Accounts**: Use service accounts for application access
4. **Regular Review**: Audit permissions regularly
5. **Document Permissions**: Explain why each permission is needed

## Multi-Tenant Considerations

- Each tenant gets their own namespace
- RBAC scoped to namespace (Role, not ClusterRole)
- Service accounts per tenant
- No cross-tenant access

## Additional Resources

- [Kubernetes RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [RBAC Best Practices](https://kubernetes.io/docs/concepts/security/rbac-good-practices/)


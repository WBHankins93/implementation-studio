# LDAP/Active Directory Integration

LDAP (Lightweight Directory Access Protocol) is commonly used for authentication in enterprise environments, especially with Microsoft Active Directory.

## What is LDAP?

LDAP is a protocol for accessing directory services. Active Directory is Microsoft's implementation of LDAP.

## Architecture

```
User
 │
 │ Login request
 ▼
Application
 │
 │ LDAP bind
 ▼
LDAP/AD Server
 │
 │ Authentication result
 ▼
Application
 │
 │ Authenticated
 ▼
User
```

## Common LDAP Providers

- **Active Directory**: Microsoft's directory service
- **OpenLDAP**: Open-source LDAP implementation
- **389 Directory Server**: Red Hat's LDAP server
- **FreeIPA**: Identity management solution

## Implementation Options

### 1. LDAP Authentication Proxy

Use a proxy service that handles LDAP authentication:

```yaml
# Example: LDAP Auth Proxy
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ldap-auth-proxy
spec:
  template:
    spec:
      containers:
      - name: ldap-proxy
        image: your-ldap-proxy:latest
        env:
        - name: LDAP_HOST
          value: "ldap://ad.company.com"
        - name: LDAP_BASE_DN
          value: "dc=company,dc=com"
        - name: LDAP_BIND_DN
          value: "cn=service,ou=users,dc=company,dc=com"
        - name: LDAP_BIND_PASSWORD
          valueFrom:
            secretKeyRef:
              name: ldap-credentials
              key: password
```

### 2. Keycloak with LDAP

Keycloak can federate LDAP/AD:
- Configure LDAP user federation
- Users authenticate via LDAP
- Keycloak provides OAuth/OIDC to applications

### 3. Native LDAP Libraries

For applications with LDAP support:
- **Python**: `ldap3`
- **Node.js**: `ldapjs`
- **Java**: JNDI, Spring LDAP
- **Go**: `go-ldap`

## Discovery Questions

When working with customers on LDAP integration:

1. **What is your LDAP/AD server?**
   - Hostname or IP address
   - Port (389 for LDAP, 636 for LDAPS)

2. **What is the base DN?**
   - Root of the directory tree
   - Example: `dc=company,dc=com`

3. **What is the bind DN?**
   - Service account for LDAP queries
   - Example: `cn=service,ou=users,dc=company,dc=com`

4. **What is the user search base?**
   - Where to search for users
   - Example: `ou=users,dc=company,dc=com`

5. **What is the user search filter?**
   - How to find users
   - Example: `(uid={0})` or `(sAMAccountName={0})`

6. **Do you use LDAPS (TLS)?**
   - Secure LDAP connection
   - Requires certificate validation

7. **What attributes map to username?**
   - `uid`, `sAMAccountName`, `mail`, etc.

8. **Do you need group membership?**
   - Check user groups for authorization

## Example: Active Directory Configuration

```yaml
LDAP_HOST: "ldap://ad.company.com:389"
LDAP_BASE_DN: "dc=company,dc=com"
LDAP_BIND_DN: "CN=Service Account,OU=Service Accounts,DC=company,DC=com"
LDAP_USER_SEARCH_BASE: "OU=Users,DC=company,DC=com"
LDAP_USER_SEARCH_FILTER: "(sAMAccountName={0})"
LDAP_GROUP_SEARCH_BASE: "OU=Groups,DC=company,DC=com"
LDAP_GROUP_SEARCH_FILTER: "(member={0})"
```

## Security Considerations

1. **Use LDAPS (TLS)**: Encrypt LDAP connections
2. **Service Account**: Use dedicated account with minimal permissions
3. **Certificate Validation**: Validate LDAP server certificates
4. **Connection Pooling**: Reuse connections efficiently
5. **Timeouts**: Set appropriate connection timeouts

## Troubleshooting

### Connection Refused

**Check:**
- LDAP server is accessible
- Port is correct (389 or 636)
- Firewall rules allow connection

### Authentication Failed

**Check:**
- Bind DN is correct
- Password is correct
- User exists in LDAP
- User search filter is correct

### Certificate Errors (LDAPS)

**Check:**
- Certificate is valid
- Certificate chain is complete
- Server name matches certificate

## Additional Resources

- [LDAP Protocol](https://ldap.com/)
- [Active Directory](https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/get-started/virtual-dc/active-directory-domain-services-overview)
- [Keycloak LDAP Federation](https://www.keycloak.org/docs/latest/server_admin/#_ldap)


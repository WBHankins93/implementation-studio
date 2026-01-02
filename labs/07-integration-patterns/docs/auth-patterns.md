# Authentication Integration Patterns

This guide covers authentication integration patterns for customer deployments.

## Overview

Most enterprise customers require integration with existing authentication systems. This guide covers the three most common patterns:

1. **OAuth2/OIDC**: Modern, token-based authentication
2. **SAML**: Enterprise SSO protocol
3. **LDAP/Active Directory**: Directory service authentication

## OAuth2/OIDC Integration

### When to Use

- Customer uses OAuth2/OIDC providers (Google, GitHub, Azure AD)
- Modern applications with OAuth support
- Token-based authentication preferred
- Mobile and web applications

### Architecture

```
User → Application → OAuth Provider → Application (with token)
```

### Implementation Options

#### Option 1: OAuth2 Proxy

**Best for:** Applications without built-in OAuth support

**Components:**
- OAuth2 Proxy deployment
- Ingress controller
- OAuth provider configuration

**Pros:**
- Works with any application
- No code changes required
- Centralized authentication

**Cons:**
- Additional component to manage
- All traffic goes through proxy

#### Option 2: Native OAuth

**Best for:** Applications with OAuth libraries

**Components:**
- OAuth client library
- Token validation
- Session management

**Pros:**
- Direct integration
- No proxy overhead
- More control

**Cons:**
- Requires code changes
- More complex implementation

### Discovery Questions

1. What OAuth provider? (Google, GitHub, Azure AD, etc.)
2. Do you have client credentials? (Client ID, Secret)
3. What scopes are needed? (Profile, email, groups)
4. What redirect URI? (Callback URL)

### Configuration Example

```yaml
# OAuth2 Proxy configuration
provider: "google"
client_id: "YOUR_CLIENT_ID"
client_secret: "YOUR_CLIENT_SECRET"
redirect_url: "https://your-app.com/oauth2/callback"
email_domains:
  - "yourcompany.com"
```

## SAML Integration

### When to Use

- Enterprise customers with SAML IdP (Okta, Azure AD, etc.)
- SSO requirements
- Compliance requirements (some industries require SAML)
- Legacy enterprise systems

### Architecture

```
User → Application (SP) → IdP → Application (with assertion)
```

### Implementation Options

#### Option 1: OAuth2 Proxy with SAML

**Best for:** Applications without SAML support

**Components:**
- OAuth2 Proxy with SAML provider
- SAML IdP configuration

**Pros:**
- Works with any application
- No code changes

**Cons:**
- Limited SAML features
- Proxy dependency

#### Option 2: Keycloak as SAML Proxy

**Best for:** Multiple applications needing SAML

**Components:**
- Keycloak deployment
- SAML federation
- OAuth provider for applications

**Pros:**
- Centralized SAML handling
- Applications use OAuth (simpler)
- Supports multiple apps

**Cons:**
- Additional component
- More complex setup

#### Option 3: Native SAML

**Best for:** Applications with SAML libraries

**Components:**
- SAML library (python3-saml, passport-saml, etc.)
- SP configuration
- Assertion validation

**Pros:**
- Direct integration
- Full SAML control

**Cons:**
- Requires code changes
- Complex implementation

### Discovery Questions

1. What is your IdP? (Okta, Azure AD, etc.)
2. What is your IdP SSO URL?
3. What is your IdP Entity ID?
4. Do you have the IdP certificate?
5. What is your SP Entity ID?
6. What is your ACS URL?
7. What attributes are provided?
8. Do you require signed requests?

### Configuration Example

```yaml
# SAML configuration
provider: "saml"
saml_idp_url: "https://your-idp.com/saml/sso"
saml_idp_entity_id: "https://your-idp.com"
saml_idp_cert: "BASE64_CERT"
saml_sp_entity_id: "https://your-app.com"
saml_acs_url: "https://your-app.com/saml/acs"
```

## LDAP/Active Directory Integration

### When to Use

- Enterprise customers with Active Directory
- On-premises directory services
- Legacy authentication systems
- Group-based authorization needed

### Architecture

```
User → Application → LDAP/AD Server → Application (authenticated)
```

### Implementation Options

#### Option 1: LDAP Authentication Proxy

**Best for:** Applications without LDAP support

**Components:**
- LDAP proxy service
- LDAP/AD server connection
- Session management

**Pros:**
- Works with any application
- Centralized LDAP handling

**Cons:**
- Additional component
- Proxy dependency

#### Option 2: Keycloak with LDAP Federation

**Best for:** Multiple applications needing LDAP

**Components:**
- Keycloak deployment
- LDAP user federation
- OAuth provider for applications

**Pros:**
- Centralized LDAP handling
- Applications use OAuth (simpler)
- Supports multiple apps
- Group mapping

**Cons:**
- Additional component
- More complex setup

#### Option 3: Native LDAP

**Best for:** Applications with LDAP libraries

**Components:**
- LDAP client library (ldap3, ldapjs, etc.)
- LDAP bind
- User/group lookup

**Pros:**
- Direct integration
- Full LDAP control

**Cons:**
- Requires code changes
- Complex implementation

### Discovery Questions

1. What is your LDAP/AD server? (Hostname, port)
2. What is the base DN?
3. What is the bind DN? (Service account)
4. What is the user search base?
5. What is the user search filter?
6. Do you use LDAPS (TLS)?
7. What attributes map to username?
8. Do you need group membership?

### Configuration Example

```yaml
# LDAP configuration
LDAP_HOST: "ldap://ad.company.com:389"
LDAP_BASE_DN: "dc=company,dc=com"
LDAP_BIND_DN: "CN=Service Account,OU=Service Accounts,DC=company,DC=com"
LDAP_USER_SEARCH_BASE: "OU=Users,DC=company,DC=com"
LDAP_USER_SEARCH_FILTER: "(sAMAccountName={0})"
LDAP_GROUP_SEARCH_BASE: "OU=Groups,DC=company,DC=com"
```

## Decision Matrix

| Factor | OAuth2/OIDC | SAML | LDAP/AD |
|--------|-------------|------|---------|
| **Modern Apps** | ✅ Best | ⚠️ Possible | ⚠️ Possible |
| **Enterprise SSO** | ⚠️ Possible | ✅ Best | ⚠️ Possible |
| **Active Directory** | ❌ No | ⚠️ Possible | ✅ Best |
| **Token-Based** | ✅ Yes | ❌ No | ❌ No |
| **Mobile Apps** | ✅ Best | ❌ No | ❌ No |
| **Legacy Systems** | ❌ No | ✅ Best | ✅ Best |
| **Implementation Complexity** | Low | Medium | Medium |
| **Provider Support** | High | High | Medium |

## Security Best Practices

### OAuth2/OIDC

1. **Use HTTPS**: All OAuth flows must use HTTPS
2. **Validate Tokens**: Always validate tokens server-side
3. **Store Secrets Securely**: Use Kubernetes Secrets
4. **Token Expiration**: Implement token refresh
5. **Scope Limitation**: Request only needed scopes

### SAML

1. **Certificate Validation**: Validate IdP certificates
2. **Assertion Validation**: Verify assertion signatures
3. **Time Validation**: Check assertion expiration
4. **Replay Prevention**: Check assertion IDs
5. **HTTPS Only**: All SAML flows over HTTPS

### LDAP/AD

1. **Use LDAPS**: Always use TLS (LDAPS)
2. **Certificate Validation**: Validate server certificates
3. **Service Account**: Use dedicated service account
4. **Minimal Permissions**: Grant only needed permissions
5. **Connection Security**: Secure network path

## Troubleshooting

### OAuth2/OIDC

**Redirect URI Mismatch:**
- Ensure redirect URI matches exactly
- Check protocol (http vs https)
- Verify domain and path

**Token Validation Failed:**
- Check token signature
- Verify issuer
- Check expiration

### SAML

**Assertion Not Accepted:**
- Verify certificate matches
- Check entity IDs
- Validate assertion signature
- Check expiration

**Redirect Loop:**
- Verify SAML response processing
- Check session creation
- Validate assertion format

### LDAP/AD

**Connection Refused:**
- Check server accessibility
- Verify port (389/636)
- Check firewall rules

**Authentication Failed:**
- Verify bind DN and password
- Check user exists
- Validate search filter
- Check user permissions

## Additional Resources

- [OAuth2 Proxy Documentation](https://oauth2-proxy.github.io/oauth2-proxy/)
- [SAML 2.0 Specification](http://docs.oasis-open.org/security/saml/v2.0/)
- [LDAP Protocol](https://ldap.com/)
- [Keycloak Documentation](https://www.keycloak.org/documentation)


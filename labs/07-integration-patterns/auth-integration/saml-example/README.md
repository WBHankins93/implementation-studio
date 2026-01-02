# SAML Integration

SAML (Security Assertion Markup Language) is an XML-based authentication protocol commonly used in enterprise environments.

## What is SAML?

SAML enables Single Sign-On (SSO) by allowing identity providers (IdP) to authenticate users and provide assertions to service providers (SP).

## Architecture

```
User
 │
 │ Access application
 ▼
Application (SP)
 │
 │ Redirect to IdP
 ▼
Identity Provider (IdP)
 │
 │ SAML assertion
 ▼
Application (SP)
 │
 │ Authenticated
 ▼
User
```

## Common SAML Providers

- **Okta**: Enterprise identity management
- **Azure AD**: Microsoft's identity platform
- **Google Workspace**: Google's enterprise suite
- **OneLogin**: Cloud-based identity management
- **Ping Identity**: Enterprise identity solutions

## Implementation Options

### 1. OAuth2 Proxy with SAML

OAuth2 Proxy supports SAML via the `saml` provider:

```yaml
provider: "saml"
saml_idp_url: "https://your-idp.com/saml/sso"
saml_idp_entity_id: "https://your-idp.com"
saml_idp_cert: "BASE64_CERT"
```

### 2. Keycloak as SAML Proxy

Keycloak can act as a SAML-to-OAuth bridge:
- Configure Keycloak as SAML SP
- Configure Keycloak as OAuth provider
- Applications use OAuth (simpler than SAML)

### 3. Native SAML Libraries

For applications with SAML support:
- **Python**: `python3-saml`
- **Node.js**: `passport-saml`
- **Java**: Spring Security SAML
- **Go**: `crewjam/saml`

## Discovery Questions

When working with customers on SAML integration:

1. **What is your IdP?**
   - Okta, Azure AD, Google Workspace, etc.

2. **What is your IdP SSO URL?**
   - Where users are redirected for authentication

3. **What is your IdP Entity ID?**
   - Unique identifier for the IdP

4. **Do you have the IdP certificate?**
   - Public certificate for signature verification

5. **What is your SP Entity ID?**
   - Unique identifier for your application

6. **What is your ACS (Assertion Consumer Service) URL?**
   - Where SAML responses are sent

7. **What attributes are provided?**
   - Email, username, groups, etc.

8. **Do you require signed requests?**
   - Some IdPs require SP to sign requests

## Example: Okta Configuration

1. Create SAML application in Okta
2. Configure:
   - Single Sign-On URL: `https://your-app.com/saml/acs`
   - Audience URI: `https://your-app.com`
   - Name ID format: Email
3. Download certificate
4. Configure application with:
   - SSO URL from Okta
   - Certificate from Okta
   - Entity ID from Okta

## Troubleshooting

### SAML Response Not Accepted

**Check:**
- Certificate matches IdP
- Entity IDs match
- ACS URL is correct
- Response is not expired

### Redirect Loop

**Check:**
- SAML response is valid
- Application is processing response correctly
- Session is being created

## Additional Resources

- [SAML 2.0 Specification](http://docs.oasis-open.org/security/saml/v2.0/)
- [Okta SAML Guide](https://developer.okta.com/docs/guides/saml-application-setup/overview/)
- [Azure AD SAML](https://docs.microsoft.com/en-us/azure/active-directory/manage-apps/configure-saml-single-sign-on)


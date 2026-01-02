# OAuth2 Proxy Integration

OAuth2 Proxy provides authentication for applications that don't have built-in OAuth support.

## What is OAuth2 Proxy?

OAuth2 Proxy is a reverse proxy that provides authentication using OAuth2 providers (Google, GitHub, GitLab, etc.). It sits in front of your application and handles authentication before allowing access.

## Architecture

```
User
 │
 │ HTTPS
 ▼
OAuth2 Proxy (Ingress)
 │
 │ Authenticated request
 ▼
Argo Workflows UI
```

## Setup

### 1. Register OAuth Application

**For Google:**
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. APIs & Services → Credentials
3. Create OAuth 2.0 Client ID
4. Add authorized redirect URI: `https://your-domain.com/oauth2/callback`
5. Note Client ID and Client Secret

**For GitHub:**
1. Go to GitHub Settings → Developer settings → OAuth Apps
2. Create new OAuth App
3. Set Authorization callback URL: `https://your-domain.com/oauth2/callback`
4. Note Client ID and Client Secret

### 2. Generate Cookie Secret

```bash
openssl rand -base64 32 | head -c 32 | base64
```

### 3. Update Configuration

Edit `oauth2-proxy.yaml`:
- Replace `YOUR_CLIENT_ID` with your OAuth client ID
- Replace `YOUR_CLIENT_SECRET` with your OAuth client secret
- Replace `GENERATE_WITH_OPENSSL` with generated cookie secret
- Update `redirect_url` and `cookie_domains` with your domain
- Update `upstreams` to point to your application

### 4. Deploy

```bash
kubectl apply -f oauth2-proxy.yaml
```

### 5. Configure Ingress

Update the Ingress resource with your domain and TLS certificate.

## Configuration Options

### Email Domain Whitelist

Only allow users from specific email domains:

```yaml
email_domains:
  - "yourcompany.com"
```

### User Whitelist

Only allow specific users:

```yaml
whitelist_domains:
  - "yourcompany.com"
```

### Session Duration

```yaml
cookie_expire: "168h"  # 7 days
```

## Testing

1. Access your application URL
2. You should be redirected to OAuth provider
3. Authenticate
4. You should be redirected back to application
5. Access should be granted

## Troubleshooting

### Redirect URI Mismatch

**Problem:** OAuth provider rejects redirect URI

**Solution:** Ensure redirect URI in OAuth app matches exactly:
- Protocol (http vs https)
- Domain
- Path (`/oauth2/callback`)

### Cookie Issues

**Problem:** Users keep getting redirected to login

**Solution:**
- Check cookie domain matches your domain
- Ensure cookie secret is set correctly
- Check cookie secure flag (should be true for HTTPS)

## Additional Resources

- [OAuth2 Proxy Documentation](https://oauth2-proxy.github.io/oauth2-proxy/)
- [OAuth2 Proxy GitHub](https://github.com/oauth2-proxy/oauth2-proxy)


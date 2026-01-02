# GCP API Gateway

GCP API Gateway is a fully managed service for creating, deploying, and managing APIs.

## What is GCP API Gateway?

GCP API Gateway provides:
- API management and routing
- Authentication and authorization
- Rate limiting and quotas
- Monitoring and logging
- No infrastructure to manage

## Architecture

```
Client
 │
 │ HTTPS
 ▼
GCP API Gateway (Managed)
 │
 │ (routed, authenticated)
 ▼
Backend Services (GKE, Cloud Run, etc.)
```

## Setup

### 1. Create API Config

```yaml
# api-config.yaml
swagger: '2.0'
info:
  title: Argo Workflows API
  description: API Gateway for Argo Workflows
  version: 1.0.0
host: api-gateway-XXXXX-uc.a.run.app
schemes:
  - https
produces:
  - application/json
paths:
  /argo/{path=**}:
    get:
      summary: Proxy to Argo Workflows
      operationId: proxy_argo
      x-google-backend:
        address: https://argo-workflows.example.com
      responses:
        '200':
          description: Success
```

### 2. Deploy API Gateway

```bash
# Create API Gateway
gcloud api-gateway gateways create argo-gateway \
  --api=argo-api \
  --api-config=api-config \
  --location=us-central1 \
  --project=PROJECT_ID

# Create API Config
gcloud api-gateway api-configs create api-config \
  --api=argo-api \
  --openapi-spec=api-config.yaml \
  --project=PROJECT_ID \
  --backend-auth-service-account=SERVICE_ACCOUNT
```

### 3. Configure Authentication

```yaml
security:
  - google_id_token: []
securityDefinitions:
  google_id_token:
    authorizationUrl: ""
    flow: "implicit"
    type: "oauth2"
    x-google-issuer: "https://accounts.google.com"
    x-google-jwks_uri: "https://www.googleapis.com/oauth2/v3/certs"
```

## Features

### Rate Limiting

```yaml
x-google-quota:
  metric: requests
  limit: 1000
  unit: 1/minutes
```

### API Keys

```yaml
security:
  - api_key: []
securityDefinitions:
  api_key:
    type: apiKey
    name: key
    in: query
```

### CORS

```yaml
x-google-cors:
  allowOrigin: "*"
  allowMethods: "GET, POST, PUT, DELETE, OPTIONS"
  allowHeaders: "Authorization, Content-Type"
  exposeHeaders: "Content-Length"
  maxAge: 3600
```

## GCP API Gateway vs Alternatives

| Feature | GCP API Gateway | Kong | NGINX |
|---------|----------------|------|-------|
| Managed | ✅ | ❌ | ❌ |
| Cost | Pay-per-use | Free/Paid | Free |
| Setup Complexity | Low | Medium | Low |
| GCP Integration | ✅ | ❌ | ❌ |
| Custom Plugins | Limited | ✅ | ✅ |

## Use Cases

**Good For:**
- GCP-native applications
- Serverless backends (Cloud Run, Cloud Functions)
- Simple routing and authentication
- Managed service preference

**Consider Alternatives For:**
- Complex routing requirements
- Custom plugins needed
- Cost optimization
- Multi-cloud deployments

## Pricing

- **API Calls**: $3 per million calls
- **Data Transfer**: Standard egress pricing
- **No infrastructure costs**

## Troubleshooting

### 502 Bad Gateway

**Check:**
- Backend service is accessible
- Service account has permissions
- Backend URL is correct

### Authentication Failed

**Check:**
- API key is valid (if using)
- JWT token is valid (if using)
- Security definitions are correct

## Additional Resources

- [GCP API Gateway Documentation](https://cloud.google.com/api-gateway/docs)
- [API Gateway Pricing](https://cloud.google.com/api-gateway/pricing)


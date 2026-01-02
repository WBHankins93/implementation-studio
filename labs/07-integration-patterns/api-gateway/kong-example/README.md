# Kong API Gateway Integration

Kong is an open-source API gateway that provides routing, authentication, rate limiting, and more.

## What is Kong?

Kong is a cloud-native API gateway that sits in front of your services, providing:
- Request routing
- Authentication/authorization
- Rate limiting
- Request/response transformation
- Logging and monitoring

## Architecture

```
Client
 │
 │ HTTP/HTTPS
 ▼
Kong API Gateway
 │
 │ (routed, rate-limited, authenticated)
 ▼
Backend Services
```

## Setup

### 1. Deploy Kong

```bash
kubectl apply -f kong-deployment.yaml
```

### 2. Access Kong Admin API

```bash
# Port forward to admin API
kubectl port-forward -n kong svc/kong-admin 8001:8001

# Test admin API
curl http://localhost:8001/
```

### 3. Configure Routes

The example configuration includes:
- Route to Argo Workflows
- Rate limiting (100/minute, 1000/hour)
- CORS configuration

### 4. Access via Gateway

```bash
# Get proxy service IP
kubectl get svc kong-proxy -n kong

# Access Argo Workflows via Kong
curl http://<kong-proxy-ip>/argo
```

## Kong Plugins

### Rate Limiting

```yaml
plugins:
- name: rate-limiting
  config:
    minute: 100
    hour: 1000
```

### Authentication

```yaml
plugins:
- name: key-auth
  config:
    key_names:
    - apikey
```

### CORS

```yaml
plugins:
- name: cors
  config:
    origins:
    - "*"
    methods:
    - GET
    - POST
```

## Kong vs Other Gateways

| Feature | Kong | NGINX | GCP API Gateway |
|---------|------|-------|-----------------|
| Open Source | ✅ | ✅ | ❌ |
| Plugin Ecosystem | ✅ | Limited | Limited |
| Cloud-Native | ✅ | ✅ | ✅ |
| Managed Option | ✅ (Kong Cloud) | ❌ | ✅ |
| Cost | Free/Paid | Free | Pay-per-use |

## Additional Resources

- [Kong Documentation](https://docs.konghq.com/)
- [Kong Kubernetes Ingress](https://docs.konghq.com/kubernetes-ingress-controller/)


# Ingress NGINX Module

## What is This?

This module provides Helm values for deploying the NGINX Ingress Controller to Kubernetes. An ingress controller manages external access to services in your cluster, typically via HTTP/HTTPS.

## When to Use This Module

- Need to expose services to the internet
- Want to use domain names instead of IP addresses
- Need TLS/SSL termination
- Require load balancing across multiple pods
- Building web applications or APIs

## What is an Ingress Controller?

An Ingress Controller:
- Receives external traffic
- Routes to services based on rules (hostname, path)
- Terminates TLS/SSL
- Provides load balancing
- Acts as a reverse proxy

**Without Ingress**: Services need LoadBalancer type (one per service, expensive)

**With Ingress**: One LoadBalancer routes to many services (cost-effective)

## How It Works

```
Internet
   │
   ▼
┌─────────────────────────────┐
│  LoadBalancer (GCP)         │
│  - Single external IP       │
└─────────────────────────────┘
   │
   ▼
┌─────────────────────────────┐
│  Ingress NGINX Controller  │
│  - Routes based on rules    │
│  - Terminates TLS           │
└─────────────────────────────┘
   │
   ├───► Service 1 (app.example.com)
   ├───► Service 2 (api.example.com)
   └───► Service 3 (admin.example.com)
```

## Usage

### Install Ingress NGINX

```bash
# Add Helm repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install
helm install ingress-nginx ingress-nginx/ingress-nginx \
  -f modules/kubernetes/ingress-nginx/helm-values.yaml \
  -n ingress-nginx --create-namespace
```

### Get External IP

```bash
kubectl get service ingress-nginx-controller -n ingress-nginx
# Wait for EXTERNAL-IP to be assigned (may take 2-5 minutes)
```

### Create an Ingress Resource

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress
  namespace: my-app
spec:
  ingressClassName: nginx
  rules:
  - host: my-app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-app-service
            port:
              number: 80
```

Apply it:

```bash
kubectl apply -f ingress.yaml
```

## Configuration Explained

### LoadBalancer Service

```yaml
service:
  type: LoadBalancer
  annotations:
    cloud.google.com/load-balancer-type: "External"
```

Creates a GCP Load Balancer with an external IP.

### Resource Limits

```yaml
resources:
  limits:
    cpu: 500m
    memory: 512Mi
```

Prevents the controller from consuming too many resources.

### Pod Disruption Budget

```yaml
podDisruptionBudget:
  enabled: true
  minAvailable: 1
```

Ensures at least one pod is always available during updates.

### Metrics

```yaml
metrics:
  enabled: true
```

Enables Prometheus metrics for monitoring.

## Features

- **High Availability**: 2 replicas by default
- **Auto-scaling**: Can enable horizontal pod autoscaling
- **TLS Support**: Automatic TLS with cert-manager
- **Metrics**: Prometheus metrics enabled
- **Webhooks**: Admission webhooks for validation

## Common Use Cases

### Expose Argo Workflows UI

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argo-workflows-ui
  namespace: argo
spec:
  ingressClassName: nginx
  rules:
  - host: argo.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argo-workflows-server
            port:
              number: 2746
```

### Multiple Services

```yaml
spec:
  rules:
  - host: app.example.com
    http:
      paths:
      - path: /
        backend:
          service:
            name: frontend
            port:
              number: 80
  - host: api.example.com
    http:
      paths:
      - path: /
        backend:
          service:
            name: backend
            port:
              number: 8080
```

## Requirements

- **Kubernetes Cluster**: Version 1.19 or higher
- **Helm**: Version 3.x
- **kubectl**: Configured to access cluster
- **LoadBalancer Support**: Cluster must support LoadBalancer services

## Cost Considerations

- **LoadBalancer**: ~$0.025/hour (GCP)
- **Data Processing**: Standard egress charges
- **Controller Resources**: Minimal (2 pods)

**Tip**: One ingress controller can handle many services, making it cost-effective.

## Security Best Practices

1. **Use TLS**: Always use HTTPS in production
2. **Restrict Access**: Use firewall rules to limit source IPs
3. **Rate Limiting**: Configure rate limits to prevent abuse
4. **WAF**: Consider Web Application Firewall for production

## Troubleshooting

### External IP Not Assigned

```bash
# Check service status
kubectl describe service ingress-nginx-controller -n ingress-nginx

# Check events
kubectl get events -n ingress-nginx --sort-by='.lastTimestamp'

# May take 2-5 minutes for GCP to provision
```

### 502 Bad Gateway

```bash
# Check backend service
kubectl get svc <backend-service> -n <namespace>

# Check backend pods
kubectl get pods -n <namespace>

# Check ingress configuration
kubectl describe ingress <ingress-name> -n <namespace>
```

### Cannot Access Service

```bash
# Verify ingress rule
kubectl get ingress -A

# Check controller logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller
```

## Learn More

- [NGINX Ingress Documentation](https://kubernetes.github.io/ingress-nginx/)
- [Ingress Concepts](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [GCP Load Balancer](https://cloud.google.com/load-balancing/docs/network)

## Related Modules

- `argo-workflows` - Often exposed via this ingress controller


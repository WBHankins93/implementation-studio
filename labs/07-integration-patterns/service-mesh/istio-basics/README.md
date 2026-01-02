# Istio Service Mesh Basics

Istio provides traffic management, security, and observability for microservices.

## What is a Service Mesh?

A service mesh is a dedicated infrastructure layer for managing service-to-service communication. It handles:
- Traffic routing and load balancing
- Security (mTLS, authentication)
- Observability (metrics, tracing, logging)
- Policy enforcement

## Architecture

```
Application Pod
   │
   │ (via sidecar)
   ▼
Istio Sidecar (Envoy)
   │
   │ (mTLS, routing, policies)
   ▼
Destination Service
```

## Key Concepts

### Sidecar Proxy

Each pod gets an Envoy sidecar that:
- Intercepts all traffic
- Applies policies
- Collects metrics
- Handles routing

### VirtualService

Defines routing rules:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: argo-workflows
spec:
  hosts:
  - argo-workflows
  http:
  - match:
    - headers:
        user-type:
          exact: premium
    route:
    - destination:
        host: argo-workflows
        subset: premium
  - route:
    - destination:
        host: argo-workflows
        subset: standard
```

### DestinationRule

Defines traffic policies:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: argo-workflows
spec:
  host: argo-workflows
  subsets:
  - name: premium
    labels:
      tier: premium
  - name: standard
    labels:
      tier: standard
  trafficPolicy:
    loadBalancer:
      simple: LEAST_CONN
```

### Gateway

Manages ingress traffic:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: argo-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - argo.example.com
```

## Installation

### Install Istio

```bash
# Download Istio
curl -L https://istio.io/downloadIstio | sh -
cd istio-*

# Install with demo profile
istioctl install --set profile=demo

# Enable sidecar injection
kubectl label namespace default istio-injection=enabled
```

### Verify Installation

```bash
kubectl get pods -n istio-system
```

## Common Use Cases

### 1. Traffic Splitting (Canary)

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: canary
spec:
  hosts:
  - myapp
  http:
  - route:
    - destination:
        host: myapp
        subset: v1
      weight: 90
    - destination:
        host: myapp
        subset: v2
      weight: 10
```

### 2. mTLS (Mutual TLS)

```yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
spec:
  mtls:
    mode: STRICT
```

### 3. Rate Limiting

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: rate-limit
spec:
  hosts:
  - myapp
  http:
  - match:
    - headers:
        user-type:
          exact: free
    route:
    - destination:
        host: myapp
    fault:
      delay:
        percentage:
          value: 50
        fixedDelay: 5s
```

## When to Use Istio

**Good For:**
- Complex microservices architectures
- Need for advanced traffic management
- Security requirements (mTLS)
- Observability needs

**Consider Alternatives For:**
- Simple applications
- Single service deployments
- Cost-sensitive environments
- Limited operational complexity tolerance

## Alternatives

- **Linkerd**: Simpler, lighter weight
- **Consul Connect**: HashiCorp's service mesh
- **NGINX Service Mesh**: NGINX-based
- **Native Kubernetes**: Ingress, Network Policies

## Additional Resources

- [Istio Documentation](https://istio.io/latest/docs/)
- [Istio Examples](https://istio.io/latest/docs/examples/)
- [Service Mesh Comparison](https://servicemesh.es/)


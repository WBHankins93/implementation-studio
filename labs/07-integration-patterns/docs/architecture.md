# Integration Patterns Architecture

This document describes the architecture patterns for integrating applications with external systems.

## Overview

Customer deployments often require integration with:
- External authentication systems
- Databases outside the cluster
- API gateways for traffic management
- Service meshes for advanced routing

## Authentication Integration

### OAuth2 Proxy Pattern

```mermaid
sequenceDiagram
    participant User
    participant Ingress as Ingress Controller
    participant OAuth as OAuth2 Proxy<br/>(Authentication)
    participant App as Application<br/>(Argo Workflows)
    participant Provider as OAuth Provider<br/>(Google, GitHub)
    
    User->>Ingress: HTTPS Request
    Ingress->>OAuth: Forward Request
    OAuth->>Provider: Authenticate User
    Provider-->>OAuth: Authentication Token
    OAuth->>App: Authenticated Request
    App-->>OAuth: Response
    OAuth-->>Ingress: Response
    Ingress-->>User: Response
```

**Components:**
- OAuth2 Proxy deployment
- Ingress for external access
- OAuth provider (Google, GitHub, etc.)
- Application (protected by proxy)

### SAML Pattern

```mermaid
sequenceDiagram
    participant User
    participant App as Application (SP)
    participant IdP as Identity Provider<br/>(Okta, Azure AD)
    
    User->>App: Access Application
    App->>IdP: Redirect to IdP
    User->>IdP: Authenticate
    IdP->>App: SAML Assertion
    App->>User: Authenticated Access
```

**Components:**
- Application as Service Provider (SP)
- Identity Provider (IdP)
- SAML assertions for authentication

### LDAP/AD Pattern

```mermaid
sequenceDiagram
    participant User
    participant App as Application
    participant LDAP as LDAP/AD Server<br/>(Active Directory)
    
    User->>App: Login Request
    App->>LDAP: LDAP Bind
    LDAP-->>App: Authentication Result
    App->>User: Authenticated Access
```

**Components:**
- Application with LDAP client
- LDAP/AD server
- Service account for LDAP queries

## Database Connectivity

### Cloud SQL Proxy Pattern

```mermaid
graph LR
    App[Application Pod]
    Proxy[Cloud SQL Proxy<br/>Sidecar/Service]
    SQL[Cloud SQL Instance<br/>Private IP]
    
    App -->|via Service| Proxy
    Proxy -->|IAM-Authenticated| SQL
    
    style App fill:#e0f2f1
    style Proxy fill:#fff4e1
    style SQL fill:#e1f5ff
```

**Components:**
- Cloud SQL Proxy deployment
- Workload Identity for IAM auth
- Cloud SQL instance with private IP
- Application connecting via proxy

### External Database Pattern

```
┌─────────────────────┐
│  Application Pod    │
└──────┬──────────────┘
       │
       │ (via VPN/Public IP)
       ▼
┌─────────────────────┐
│  VPN Gateway        │
│  (or Direct)        │
└──────┬──────────────┘
       │
       │ (private network)
       ▼
┌─────────────────────┐
│  External Database  │
│  (Customer DC)      │
└─────────────────────┘
```

**Components:**
- VPN connection (Cloud VPN/Interconnect)
- External database
- Application with database client

### Connection Pooling Pattern

```
┌─────────────────────┐
│  Application Pods  │
│  (Multiple)         │
└──────┬──────────────┘
       │
       │ (request connections)
       ▼
┌─────────────────────┐
│  Connection Pooler │
│  (PgBouncer, etc.) │
└──────┬──────────────┘
       │
       │ (reuse connections)
       ▼
┌─────────────────────┐
│  Database           │
└─────────────────────┘
```

**Components:**
- Connection pooler (PgBouncer, ProxySQL)
- Database
- Applications sharing connection pool

## API Gateway

### Kong Pattern

```mermaid
graph TB
    Client[Client]
    Kong[Kong API Gateway<br/>Routing, Auth<br/>Rate Limiting]
    Backend[Backend Services<br/>Argo, etc.]
    
    Client -->|HTTP/HTTPS| Kong
    Kong -->|Routed| Backend
    Backend -->|Response| Kong
    Kong -->|Response| Client
    
    style Kong fill:#fff4e1
    style Backend fill:#e0f2f1
```

**Components:**
- Kong deployment
- Routes and plugins
- Backend services

### GCP API Gateway Pattern

```
┌─────────────┐
│   Client    │
└──────┬──────┘
       │ HTTPS
       ▼
┌─────────────────────┐
│  GCP API Gateway    │
│  (Managed Service)  │
└──────┬──────────────┘
       │
       │ (routed, authenticated)
       ▼
┌─────────────────────┐
│  Backend Services   │
│  (GKE, Cloud Run)  │
└─────────────────────┘
```

**Components:**
- GCP API Gateway (managed)
- API configuration (OpenAPI)
- Backend services

## Service Mesh

### Istio Pattern

```mermaid
graph TB
    subgraph "Source Pod"
        App1[Application]
        Envoy1[Envoy Sidecar]
    end
    
    subgraph "Destination Pod"
        Envoy2[Envoy Sidecar]
        App2[Application]
    end
    
    App1 --> Envoy1
    Envoy1 -->|mTLS, Routing| Envoy2
    Envoy2 --> App2
    
    style App1 fill:#e0f2f1
    style Envoy1 fill:#fff4e1
    style Envoy2 fill:#fff4e1
    style App2 fill:#e0f2f1
```

**Components:**
- Istio control plane
- Envoy sidecars per pod
- VirtualServices and DestinationRules
- Policies (mTLS, rate limiting)

## Integration Decision Tree

```
Need Authentication?
├─ Yes → OAuth available?
│   ├─ Yes → OAuth2 Proxy
│   └─ No → SAML/LDAP?
│       ├─ SAML → SAML Integration
│       └─ LDAP → LDAP Integration
└─ No → Skip authentication

Need Database?
├─ Cloud SQL → Cloud SQL Proxy
├─ External (GCP) → VPN + Direct Connection
├─ External (Other) → VPN/Proxy + Connection Pooling
└─ No → Skip database

Need API Gateway?
├─ Managed → GCP API Gateway
├─ Self-Hosted → Kong
└─ No → Skip gateway

Need Advanced Routing?
├─ Yes → Istio Service Mesh
└─ No → Native Kubernetes
```

## Security Considerations

### Authentication
- Use HTTPS/TLS for all authentication flows
- Store secrets in Kubernetes Secrets
- Validate tokens/assertions properly
- Implement session management

### Database
- Use private IPs when possible
- Enable SSL/TLS for database connections
- Use IAM authentication (Cloud SQL)
- Implement connection pooling
- Monitor connection attempts

### API Gateway
- Enable authentication on gateway
- Use rate limiting
- Log all requests
- Monitor for abuse

### Service Mesh
- Enable mTLS for service-to-service
- Implement network policies
- Monitor traffic patterns
- Use authentication policies

## Performance Considerations

### Database
- Connection pooling reduces overhead
- Monitor connection pool metrics
- Tune pool size based on workload
- Use read replicas for read-heavy workloads

### API Gateway
- Cache responses when possible
- Use CDN for static content
- Monitor gateway latency
- Scale gateway based on traffic

### Service Mesh
- Sidecar adds latency (minimal)
- Monitor Envoy metrics
- Use appropriate routing policies
- Consider mesh overhead

## Monitoring

### Key Metrics

**Authentication:**
- Authentication success/failure rates
- Token validation times
- Session duration

**Database:**
- Connection pool usage
- Query latency
- Connection errors
- Database CPU/memory

**API Gateway:**
- Request rate
- Response latency
- Error rates
- Rate limit hits

**Service Mesh:**
- Request rate per service
- Latency percentiles
- Error rates
- mTLS handshake failures

## Troubleshooting

See [Troubleshooting Guide](./troubleshooting.md) for common issues and solutions.


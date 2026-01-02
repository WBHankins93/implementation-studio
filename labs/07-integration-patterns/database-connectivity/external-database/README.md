# External Database Connectivity

Connecting to databases outside the Kubernetes cluster requires careful network and security configuration.

## Common Scenarios

1. **Customer-Managed Database**: Database in customer's data center
2. **Cloud Database (Non-GCP)**: AWS RDS, Azure Database, etc.
3. **Legacy Database**: Existing database that can't be migrated
4. **Shared Database**: Database shared across multiple applications

## Architecture Patterns

### Pattern 1: Direct Connection (Public IP)

```
Application Pod
   │
   │ (via public IP)
   ▼
External Database
```

**Requirements:**
- Database has public IP
- Firewall allows connections from GKE nodes
- SSL/TLS encryption
- Strong authentication

### Pattern 2: VPN Connection

```
Application Pod
   │
   │ (via VPN)
   ▼
VPN Gateway
   │
   │ (private network)
   ▼
External Database
```

**Requirements:**
- VPN tunnel between GCP and customer network
- Cloud VPN or Cloud Interconnect
- Private IP routing

### Pattern 3: Proxy Service

```
Application Pod
   │
   │ (via service)
   ▼
Database Proxy Pod
   │
   │ (via VPN/private)
   ▼
External Database
```

**Benefits:**
- Centralized connection management
- Connection pooling
- Monitoring and logging

## Implementation

### Direct Connection Example

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-with-external-db
spec:
  template:
    spec:
      containers:
      - name: app
        env:
        - name: DB_HOST
          value: "external-db.example.com"
        - name: DB_PORT
          value: "5432"
        - name: DB_NAME
          value: "appdb"
        - name: DB_USER
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: username
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: password
        - name: DB_SSL_MODE
          value: "require"
```

### Proxy Service Example

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: db-proxy
spec:
  template:
    spec:
      containers:
      - name: pgbouncer  # PostgreSQL connection pooler
        image: pgbouncer/pgbouncer:latest
        env:
        - name: DATABASES_HOST
          value: "external-db.example.com"
        - name: DATABASES_PORT
          value: "5432"
        - name: DATABASES_USER
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: username
        - name: DATABASES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: password
```

## Discovery Questions

1. **Where is the database located?**
   - Customer data center, cloud provider, etc.

2. **What is the database type?**
   - PostgreSQL, MySQL, Oracle, SQL Server, etc.

3. **Does it have a public IP?**
   - Or is it only accessible via private network?

4. **What network connectivity exists?**
   - VPN, direct connect, internet only?

5. **What are the connection requirements?**
   - IP whitelist, VPN, certificate-based auth?

6. **What is the connection string format?**
   - Host, port, database name, SSL requirements

7. **Are there connection limits?**
   - Max connections, connection timeout

8. **What authentication method?**
   - Username/password, certificate, IAM

## Security Considerations

1. **Encryption in Transit**: Always use SSL/TLS
2. **Encryption at Rest**: Ensure database encryption
3. **Network Security**: VPN or private connection preferred
4. **Credential Management**: Use Kubernetes secrets
5. **Connection Pooling**: Limit concurrent connections
6. **Monitoring**: Log connection attempts and failures

## Troubleshooting

### Connection Timeout

**Check:**
- Network connectivity (ping, telnet)
- Firewall rules
- DNS resolution
- VPN status (if applicable)

### Authentication Failed

**Check:**
- Credentials are correct
- User has permissions
- Database allows connections from source IP

### SSL/TLS Errors

**Check:**
- Certificate is valid
- Certificate chain is complete
- SSL mode matches database configuration

## Additional Resources

- [GCP Cloud VPN](https://cloud.google.com/vpn/docs/concepts/overview)
- [GCP Cloud Interconnect](https://cloud.google.com/network-connectivity/docs/interconnect)
- [PostgreSQL Connection Pooling](https://www.postgresql.org/docs/current/runtime-config-connection.html)


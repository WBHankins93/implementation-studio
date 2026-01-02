# Database Connectivity Patterns

This guide covers database connectivity patterns for customer deployments.

## Overview

Applications often need to connect to databases outside the Kubernetes cluster. This guide covers:

1. **Cloud SQL Proxy**: GCP-managed databases
2. **External Databases**: Customer-managed or other clouds
3. **Connection Pooling**: Efficient connection management

## Cloud SQL Proxy

### When to Use

- GCP Cloud SQL instances
- Private IP preferred
- IAM authentication desired
- No public IP needed

### Architecture

```
Application Pod → Cloud SQL Proxy → Cloud SQL (Private IP)
```

### Benefits

✅ **No Public IPs**: Cloud SQL doesn't need public IP
✅ **IAM Authentication**: Uses service accounts, no passwords
✅ **Automatic SSL**: Proxy handles SSL/TLS
✅ **Connection Pooling**: Proxy manages connections
✅ **High Availability**: Proxy can be replicated

### Setup

1. **Create Service Account**:
   ```bash
   gcloud iam service-accounts create cloud-sql-proxy
   gcloud projects add-iam-policy-binding PROJECT_ID \
     --member="serviceAccount:cloud-sql-proxy@PROJECT_ID.iam.gserviceaccount.com" \
     --role="roles/cloudsql.client"
   ```

2. **Enable Workload Identity**:
   ```bash
   gcloud iam service-accounts add-iam-policy-binding \
     cloud-sql-proxy@PROJECT_ID.iam.gserviceaccount.com \
     --role roles/iam.workloadIdentityUser \
     --member "serviceAccount:PROJECT_ID.svc.id.goog[database/cloud-sql-proxy]"
   ```

3. **Deploy Proxy**:
   ```bash
   kubectl apply -f database-connectivity/cloud-sql-proxy/cloud-sql-proxy.yaml
   ```

### Connection String

```
PROJECT_ID:REGION:INSTANCE_NAME
```

Example:
```
my-project:us-central1:my-instance
```

## External Database

### When to Use

- Customer-managed databases
- Databases in other clouds (AWS RDS, Azure Database)
- On-premises databases
- Legacy databases

### Architecture Patterns

#### Pattern 1: Direct Connection (Public IP)

```
Application Pod → External Database (Public IP)
```

**Requirements:**
- Database has public IP
- Firewall allows connections from GKE nodes
- SSL/TLS encryption
- Strong authentication

#### Pattern 2: VPN Connection

```
Application Pod → VPN Gateway → External Database (Private IP)
```

**Requirements:**
- VPN tunnel between GCP and customer network
- Cloud VPN or Cloud Interconnect
- Private IP routing

#### Pattern 3: Proxy Service

```
Application Pod → Database Proxy → External Database
```

**Benefits:**
- Centralized connection management
- Connection pooling
- Monitoring and logging

### Discovery Questions

1. Where is the database located?
2. What database type?
3. Does it have a public IP?
4. What network connectivity exists?
5. What are connection requirements?
6. What is connection string format?
7. Are there connection limits?
8. What authentication method?

### Security Considerations

1. **Encryption in Transit**: Always use SSL/TLS
2. **Encryption at Rest**: Ensure database encryption
3. **Network Security**: VPN or private connection preferred
4. **Credential Management**: Use Kubernetes secrets
5. **Connection Pooling**: Limit concurrent connections
6. **Monitoring**: Log connection attempts and failures

## Connection Pooling

### Why Connection Pooling?

**Without Pooling:**
- Each request creates new connection
- High overhead (TCP handshake, authentication)
- Database connection limits exhausted quickly

**With Pooling:**
- Reuse existing connections
- Lower latency
- Better resource utilization
- Respect database connection limits

### Common Poolers

#### PgBouncer (PostgreSQL)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pgbouncer
spec:
  template:
    spec:
      containers:
      - name: pgbouncer
        image: pgbouncer/pgbouncer:latest
        env:
        - name: DATABASES_HOST
          value: "postgres.example.com"
        - name: POOL_MODE
          value: "transaction"
        - name: MAX_CLIENT_CONN
          value: "1000"
        - name: DEFAULT_POOL_SIZE
          value: "25"
```

#### ProxySQL (MySQL/MariaDB)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: proxysql
spec:
  template:
    spec:
      containers:
      - name: proxysql
        image: proxysql/proxysql:latest
        env:
        - name: MYSQL_HOST
          value: "mysql.example.com"
```

### Pooling Modes

#### Transaction Mode (PgBouncer)

- Connection returned to pool after transaction
- Best for short transactions
- Highest connection reuse

#### Session Mode

- Connection held for entire session
- Best for long-running sessions
- Lower connection reuse

#### Statement Mode

- Connection returned after each statement
- Highest overhead
- Rarely used

### Configuration Guidelines

#### Pool Size

**Too Small:**
- Connection wait times
- Reduced throughput

**Too Large:**
- Wasted resources
- Database connection limits

**Rule of Thumb:**
- Start with: `(expected concurrent requests) / 2`
- Monitor and adjust based on metrics

#### Connection Timeout

- How long to wait for connection from pool
- Default: 30 seconds
- Adjust based on application requirements

#### Idle Timeout

- How long idle connection stays in pool
- Default: 10 minutes
- Prevents stale connections

## Decision Matrix

| Factor | Cloud SQL Proxy | External (VPN) | External (Public) | Connection Pooling |
|--------|----------------|----------------|-------------------|---------------------|
| **GCP Cloud SQL** | ✅ Best | ❌ No | ❌ No | ✅ Recommended |
| **Customer DB** | ❌ No | ✅ Best | ⚠️ Possible | ✅ Recommended |
| **Security** | ✅ High | ✅ High | ⚠️ Medium | N/A |
| **Setup Complexity** | Low | Medium | Low | Low |
| **Cost** | Pay-per-use | VPN costs | Internet egress | Minimal |

## Monitoring

### Key Metrics

**Database:**
- Connection pool usage
- Query latency
- Connection errors
- Database CPU/memory

**Connection Pooler:**
- Active connections
- Idle connections
- Wait time
- Connection errors

### Example Queries

**PgBouncer:**
```sql
SHOW POOLS;
SHOW STATS;
SHOW CLIENTS;
```

## Troubleshooting

### Connection Exhausted

**Symptoms:**
- "Too many connections" errors
- Long wait times

**Solutions:**
- Increase pool size
- Reduce connection lifetime
- Check for connection leaks

### Stale Connections

**Symptoms:**
- Connection errors after idle period
- Database connection timeouts

**Solutions:**
- Reduce idle timeout
- Enable connection validation
- Use health checks

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

## Best Practices

1. **Use Private Connections**: VPN or private IP when possible
2. **Enable SSL/TLS**: Encrypt all database connections
3. **Use Connection Pooling**: Improve performance and resource usage
4. **Monitor Connections**: Track pool usage and errors
5. **Handle Errors Gracefully**: Retry on transient errors
6. **Use Health Checks**: Verify connection health
7. **Limit Connections**: Respect database connection limits
8. **Secure Credentials**: Use Kubernetes secrets

## Additional Resources

- [Cloud SQL Proxy Documentation](https://cloud.google.com/sql/docs/postgres/sql-proxy)
- [PgBouncer Documentation](https://www.pgbouncer.org/)
- [GCP Cloud VPN](https://cloud.google.com/vpn/docs/concepts/overview)
- [PostgreSQL Connection Pooling](https://www.postgresql.org/docs/current/runtime-config-connection.html)


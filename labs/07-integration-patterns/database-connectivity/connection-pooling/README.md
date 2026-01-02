# Database Connection Pooling

Connection pooling manages a pool of database connections, improving performance and resource utilization.

## Why Connection Pooling?

**Without Pooling:**
- Each request creates new connection
- High overhead (TCP handshake, authentication)
- Database connection limits exhausted quickly

**With Pooling:**
- Reuse existing connections
- Lower latency
- Better resource utilization
- Respect database connection limits

## Architecture

```
Application Pods
   │
   │ (request connections)
   ▼
Connection Pooler
   │
   │ (reuse connections)
   ▼
Database
```

## Common Poolers

### PgBouncer (PostgreSQL)

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
        - name: DATABASES_PORT
          value: "5432"
        - name: DATABASES_DBNAME
          value: "appdb"
        - name: POOL_MODE
          value: "transaction"  # transaction, session, statement
        - name: MAX_CLIENT_CONN
          value: "1000"
        - name: DEFAULT_POOL_SIZE
          value: "25"
```

### ProxySQL (MySQL/MariaDB)

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
        - name: MYSQL_PORT
          value: "3306"
```

### HikariCP (Java)

Built into many Java frameworks (Spring Boot, etc.):

```yaml
spring:
  datasource:
    hikari:
      maximum-pool-size: 10
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
      max-lifetime: 1800000
```

## Pooling Modes

### Transaction Mode (PgBouncer)

- Connection returned to pool after transaction
- Best for short transactions
- Highest connection reuse

### Session Mode

- Connection held for entire session
- Best for long-running sessions
- Lower connection reuse

### Statement Mode

- Connection returned after each statement
- Highest overhead
- Rarely used

## Configuration Guidelines

### Pool Size

**Too Small:**
- Connection wait times
- Reduced throughput

**Too Large:**
- Wasted resources
- Database connection limits

**Rule of Thumb:**
- Start with: `(expected concurrent requests) / 2`
- Monitor and adjust based on metrics

### Connection Timeout

- How long to wait for connection from pool
- Default: 30 seconds
- Adjust based on application requirements

### Idle Timeout

- How long idle connection stays in pool
- Default: 10 minutes
- Prevents stale connections

## Monitoring

### Key Metrics

1. **Active Connections**: Currently in use
2. **Idle Connections**: Available in pool
3. **Wait Time**: Time waiting for connection
4. **Connection Errors**: Failed connections
5. **Query Time**: Average query duration

### Example Queries

**PgBouncer:**
```sql
SHOW POOLS;
SHOW STATS;
SHOW CLIENTS;
```

## Best Practices

1. **Size Appropriately**: Match pool size to workload
2. **Monitor Metrics**: Track connection usage
3. **Handle Errors**: Retry on connection errors
4. **Health Checks**: Verify pool health
5. **Graceful Shutdown**: Close connections cleanly

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

## Additional Resources

- [PgBouncer Documentation](https://www.pgbouncer.org/)
- [ProxySQL Documentation](https://proxysql.com/documentation/)
- [HikariCP Documentation](https://github.com/brettwooldridge/HikariCP)


# Integration Discovery Questions

When working with customers on integration requirements, ask these questions to understand their environment and needs.

## Authentication Integration

### General Authentication

1. **What authentication system do you currently use?**
   - OAuth2/OIDC
   - SAML
   - LDAP/Active Directory
   - Custom authentication
   - None (need to implement)

2. **Who is your identity provider?**
   - Google Workspace
   - Microsoft Azure AD
   - Okta
   - OneLogin
   - Ping Identity
   - On-premises AD
   - Other

3. **Do you require Single Sign-On (SSO)?**
   - Yes, required
   - Yes, preferred
   - No

4. **What user attributes do you need?**
   - Email address
   - Username
   - Groups/roles
   - Department
   - Custom attributes

### OAuth/OIDC Specific

5. **What OAuth provider do you use?**
   - Google
   - GitHub
   - GitLab
   - Azure AD (OAuth)
   - Custom provider

6. **Do you have OAuth client credentials?**
   - Client ID
   - Client Secret
   - Redirect URI configured

7. **What OAuth scopes do you need?**
   - User profile
   - Email
   - Groups
   - Custom scopes

### SAML Specific

8. **What is your IdP SSO URL?**
   - Where users are redirected for authentication

9. **What is your IdP Entity ID?**
   - Unique identifier for the identity provider

10. **Do you have the IdP certificate?**
    - Public certificate for signature verification

11. **What is your SP Entity ID?**
    - Unique identifier for your application

12. **What is your ACS (Assertion Consumer Service) URL?**
    - Where SAML responses are sent

13. **What attributes are provided in SAML assertions?**
    - Email, username, groups, etc.

14. **Do you require signed requests?**
    - Some IdPs require SP to sign requests

### LDAP/AD Specific

15. **What is your LDAP/AD server?**
    - Hostname or IP address
    - Port (389 for LDAP, 636 for LDAPS)

16. **What is the base DN?**
    - Root of the directory tree
    - Example: `dc=company,dc=com`

17. **What is the bind DN?**
    - Service account for LDAP queries
    - Example: `cn=service,ou=users,dc=company,dc=com`

18. **What is the user search base?**
    - Where to search for users
    - Example: `ou=users,dc=company,dc=com`

19. **What is the user search filter?**
    - How to find users
    - Example: `(uid={0})` or `(sAMAccountName={0})`

20. **Do you use LDAPS (TLS)?**
    - Secure LDAP connection
    - Requires certificate validation

21. **What attributes map to username?**
    - `uid`, `sAMAccountName`, `mail`, etc.

22. **Do you need group membership?**
    - Check user groups for authorization

## Database Integration

### General Database

1. **Where is your database located?**
   - GCP Cloud SQL
   - AWS RDS
   - Azure Database
   - On-premises data center
   - Other cloud provider
   - Customer-managed

2. **What database type?**
   - PostgreSQL
   - MySQL/MariaDB
   - SQL Server
   - Oracle
   - MongoDB
   - Other

3. **What database version?**
   - Specific version number
   - Any compatibility requirements

### Connectivity

4. **How is the database accessed?**
   - Public IP
   - Private IP (VPN)
   - Private IP (VPC peering)
   - Direct connect
   - Not yet determined

5. **What network connectivity exists?**
   - VPN tunnel
   - Cloud Interconnect
   - Direct connect
   - Internet only
   - Private network

6. **What are the connection requirements?**
   - IP whitelist
   - VPN required
   - Certificate-based authentication
   - Username/password
   - IAM authentication

### Configuration

7. **What is the connection string format?**
   - Host
   - Port
   - Database name
   - SSL requirements

8. **What authentication method?**
   - Username/password
   - Certificate
   - IAM (Cloud SQL)
   - Kerberos
   - Other

9. **Are there connection limits?**
   - Max connections
   - Connection timeout
   - Idle timeout

10. **What SSL/TLS requirements?**
    - SSL required
    - SSL mode (require, verify-full, etc.)
    - Certificate validation

### Performance

11. **What is the expected workload?**
    - Read-heavy
    - Write-heavy
    - Balanced
    - High transaction volume

12. **Do you need connection pooling?**
    - Yes, required
    - Yes, preferred
    - No

13. **What are performance requirements?**
    - Query latency targets
    - Throughput requirements
    - Concurrent connection needs

## API Gateway

### Requirements

1. **Do you need API gateway functionality?**
   - Routing
   - Rate limiting
   - Authentication
   - Request transformation
   - Monitoring

2. **What are your requirements?**
   - Managed service preferred
   - Self-hosted acceptable
   - Specific features needed

3. **What is your traffic volume?**
   - Requests per second
   - Requests per day
   - Peak traffic patterns

### Features

4. **What authentication do you need?**
   - API keys
   - OAuth tokens
   - JWT validation
   - Custom authentication

5. **Do you need rate limiting?**
   - Per API key
   - Per IP
   - Per user
   - Global limits

6. **Do you need request/response transformation?**
   - Header modification
   - Body transformation
   - URL rewriting

7. **What monitoring do you need?**
   - Request logs
   - Metrics
   - Tracing
   - Alerting

## Service Mesh

### Requirements

1. **Do you need service mesh functionality?**
   - Advanced traffic routing
   - mTLS between services
   - Observability
   - Policy enforcement

2. **What is your service architecture?**
   - Microservices
   - Monolithic
   - Hybrid

3. **What are your traffic management needs?**
   - Canary deployments
   - A/B testing
   - Traffic splitting
   - Circuit breaking

4. **What security requirements?**
   - mTLS required
   - Network policies
   - Authentication policies

5. **What observability needs?**
   - Distributed tracing
   - Service metrics
   - Request logging

## General Integration Questions

1. **What is your timeline?**
   - Urgent (days)
   - Standard (weeks)
   - Flexible (months)

2. **What is your budget?**
   - Managed services acceptable
   - Cost-sensitive
   - Open source preferred

3. **What is your operational capability?**
   - Can manage complex systems
   - Prefer managed services
   - Limited operations team

4. **What are your compliance requirements?**
   - HIPAA
   - SOC 2
   - FedRAMP
   - Industry-specific

5. **What is your disaster recovery plan?**
   - Backup requirements
   - RTO/RPO targets
   - Failover procedures

## Documentation Requirements

1. **What documentation do you need?**
   - Architecture diagrams
   - Configuration guides
   - Troubleshooting runbooks
   - Training materials

2. **Who will maintain this?**
   - Your team
   - Customer team
   - Shared responsibility

3. **What handoff is required?**
   - Full documentation
   - Training sessions
   - Support period

## Next Steps

After gathering answers:

1. **Document Requirements**: Create integration requirements document
2. **Design Architecture**: Design integration architecture
3. **Plan Implementation**: Create implementation plan
4. **Validate Assumptions**: Confirm understanding with customer
5. **Implement**: Build and test integration
6. **Document**: Create operational documentation


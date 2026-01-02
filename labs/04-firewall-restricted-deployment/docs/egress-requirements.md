# Egress Requirements Documentation

## Overview

When deploying applications in firewall-restricted environments, you must identify and document all external endpoints your application requires. This guide shows you how.

## Why Document Egress Requirements?

1. **Security Team Approval**: Security teams need to know what to allow
2. **Firewall Configuration**: Network teams need specific IPs/CIDRs and ports
3. **Compliance**: Auditors need to see documented access patterns
4. **Troubleshooting**: When things break, you know what should be accessible
5. **Change Management**: New requirements can be reviewed and approved

## What to Document

For each external endpoint, document:

1. **Purpose**: Why does the application need this endpoint?
2. **Protocol**: TCP, UDP, or both?
3. **Ports**: Specific ports or port ranges
4. **Destination**: IP address, CIDR block, or domain name
5. **Direction**: Outbound only (egress)
6. **Frequency**: How often is this accessed?
7. **Data**: What data is transmitted?
8. **Alternatives**: Can this be avoided or proxied?

## Template

```markdown
## Egress Requirements for [Application Name]

### Endpoint 1: [Name/Purpose]

- **Purpose**: [Why is this needed?]
- **Protocol**: TCP/UDP
- **Ports**: [Port numbers]
- **Destination**: [IP/CIDR or domain]
- **Frequency**: [How often?]
- **Data**: [What data is sent?]
- **Alternatives**: [Can this be avoided?]

### Endpoint 2: [Name/Purpose]
...
```

## Common Endpoints

### Container Images

**Docker Hub:**
- Purpose: Pull container images
- Protocol: TCP
- Ports: 443 (HTTPS)
- Destination: registry-1.docker.io (IPs vary, use domain)
- Frequency: On pod startup
- Data: Image layers
- Alternatives: Use private registry (Artifact Registry)

**Artifact Registry:**
- Purpose: Pull container images
- Protocol: TCP
- Ports: 443
- Destination: [region]-docker.pkg.dev (GCP service)
- Frequency: On pod startup
- Data: Image layers
- Alternatives: None (if using GCP)

### Package Managers

**npm (Node.js):**
- Purpose: Install npm packages
- Protocol: TCP
- Ports: 443
- Destination: registry.npmjs.org
- Frequency: During builds
- Data: Package metadata and tarballs
- Alternatives: Use private npm registry

**PyPI (Python):**
- Purpose: Install Python packages
- Protocol: TCP
- Ports: 443
- Destination: pypi.org, files.pythonhosted.org
- Frequency: During builds
- Data: Package metadata and wheels
- Alternatives: Use private PyPI mirror

**Maven (Java):**
- Purpose: Download dependencies
- Protocol: TCP
- Ports: 443
- Destination: repo1.maven.org, central.maven.org
- Frequency: During builds
- Data: JAR files and metadata
- Alternatives: Use private Maven repository

### APIs and Services

**GitHub:**
- Purpose: Clone repositories, download releases
- Protocol: TCP
- Ports: 443, 22 (SSH)
- Destination: github.com, api.github.com
- Frequency: During CI/CD
- Data: Code, releases, API responses
- Alternatives: Use GitHub Enterprise or mirror

**Cloud Provider APIs:**
- Purpose: Access cloud services
- Protocol: TCP
- Ports: 443
- Destination: [cloud provider API endpoints]
- Frequency: Continuous
- Data: API requests/responses
- Alternatives: Use Private Google Access (GCP)

### Monitoring and Logging

**Monitoring Services:**
- Purpose: Send metrics
- Protocol: TCP
- Ports: 443
- Destination: [monitoring service endpoints]
- Frequency: Continuous
- Data: Metrics, telemetry
- Alternatives: Use cloud-native monitoring

**Logging Services:**
- Purpose: Send logs
- Protocol: TCP
- Ports: 443
- Destination: [logging service endpoints]
- Frequency: Continuous
- Data: Application logs
- Alternatives: Use cloud-native logging

## How to Identify Required Endpoints

### Method 1: Application Documentation

Check your application's documentation for:
- External dependencies
- API endpoints
- Service integrations
- Third-party services

### Method 2: Network Monitoring

Run the application and monitor network traffic:

```bash
# On a test node
tcpdump -i any -n 'tcp and port 443'

# Or use VPC Flow Logs in GCP
gcloud logging read "resource.type=gce_instance" --limit 100
```

### Method 3: Application Logs

Check application logs for connection errors:
- DNS resolution failures
- Connection timeouts
- SSL/TLS errors

### Method 4: Test in Restricted Environment

Deploy to a test environment with strict firewall:
- See what breaks
- Document what's needed
- Test fixes

## Example: Argo Workflows Egress Requirements

```markdown
## Egress Requirements for Argo Workflows

### Container Image Registry

- **Purpose**: Pull Argo Workflows container images
- **Protocol**: TCP
- **Ports**: 443
- **Destination**: quay.io (or Artifact Registry)
- **Frequency**: On pod startup
- **Data**: Container image layers
- **Alternatives**: Use private registry mirror

### Workflow Container Images

- **Purpose**: Pull images for workflow steps
- **Protocol**: TCP
- **Ports**: 443
- **Destination**: docker.io, quay.io, gcr.io (varies by workflow)
- **Frequency**: Per workflow execution
- **Data**: Container image layers
- **Alternatives**: Pre-pull images to private registry

### Artifact Storage

- **Purpose**: Store workflow artifacts
- **Protocol**: TCP
- **Ports**: 443
- **Destination**: [S3, GCS, or other storage]
- **Frequency**: Per workflow execution
- **Data**: Workflow artifacts
- **Alternatives**: Use internal storage

### External APIs (if workflows call them)

- **Purpose**: [Specific API purpose]
- **Protocol**: TCP
- **Ports**: 443
- **Destination**: [API endpoint]
- **Frequency**: [As needed by workflow]
- **Data**: [API requests/responses]
- **Alternatives**: [If any]
```

## Presenting to Security Teams

### Format

1. **Executive Summary**: High-level overview
2. **Detailed Requirements**: Per-endpoint breakdown
3. **Risk Assessment**: Security implications
4. **Mitigation Strategies**: How risks are addressed
5. **Alternatives Considered**: Why direct access is needed

### Key Points to Emphasize

1. **Minimal Scope**: Only what's absolutely necessary
2. **HTTPS Only**: All traffic encrypted in transit
3. **Audit Trail**: All access is logged
4. **Proxy Control**: Traffic goes through controlled proxy
5. **Regular Review**: Requirements reviewed periodically

## Maintaining Documentation

### Regular Reviews

- **Quarterly**: Review all endpoints
- **After Changes**: Update when application changes
- **After Incidents**: Document what was needed for troubleshooting

### Version Control

- Keep documentation in version control
- Tag versions with application releases
- Track changes over time

## Tools

### Network Analysis

- **tcpdump**: Capture network traffic
- **Wireshark**: Analyze packets
- **VPC Flow Logs**: GCP network logs
- **kubectl exec**: Test from pods

### Documentation

- **Markdown**: Easy to version control
- **Spreadsheets**: For tabular data
- **Confluence/Wiki**: For team collaboration

## Additional Resources

- [GCP VPC Flow Logs](https://cloud.google.com/vpc/docs/flow-logs)
- [Kubernetes Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [OWASP Dependency Check](https://owasp.org/www-project-dependency-check/)


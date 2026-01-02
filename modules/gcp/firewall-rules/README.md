# Firewall Rules Module

Creates firewall rules for strict egress control, commonly used in security-restricted environments.

## Features

- **Strict Egress Control**: Deny-all by default, allow only specific endpoints
- **DNS Allowlist**: Allow DNS queries to specific DNS servers
- **Proxy Support**: Allow egress to proxy servers
- **External Endpoint Allowlist**: Whitelist specific external endpoints
- **Internal Traffic**: Always allow internal VPC traffic
- **GCP Services**: Optional allowlist for GCP services

## Usage

### Basic Strict Egress

```hcl
module "firewall_rules" {
  source = "../../modules/gcp/firewall-rules"
  
  network_name        = "my-vpc"
  enable_strict_egress = true
  target_tags         = ["gke-node"]
  
  internal_ranges = ["10.0.0.0/8"]
}
```

### With Proxy

```hcl
module "firewall_rules" {
  source = "../../modules/gcp/firewall-rules"
  
  network_name        = "my-vpc"
  enable_strict_egress = true
  target_tags         = ["gke-node"]
  proxy_subnet_cidr   = "10.0.3.0/24"
  proxy_ports         = ["3128"]
  
  internal_ranges = ["10.0.0.0/8"]
}
```

### With External Endpoints

```hcl
module "firewall_rules" {
  source = "../../modules/gcp/firewall-rules"
  
  network_name        = "my-vpc"
  enable_strict_egress = true
  target_tags         = ["gke-node"]
  
  allowed_external_endpoints = {
    "docker-hub" = {
      protocol    = "tcp"
      ports       = ["443"]
      cidr        = "0.0.0.0/0"  # Docker Hub IPs (simplified)
      description = "Docker Hub registry"
    }
    "github" = {
      protocol    = "tcp"
      ports       = ["443"]
      cidr        = "140.82.112.0/20"  # GitHub IP range
      description = "GitHub API and releases"
    }
  }
  
  internal_ranges = ["10.0.0.0/8"]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| network_name | Name of the VPC network | `string` | n/a | yes |
| enable_strict_egress | Enable strict egress firewall rules | `bool` | `false` | no |
| target_tags | Target tags for firewall rules | `list(string)` | `[]` | no |
| proxy_subnet_cidr | CIDR block of proxy subnet | `string` | `null` | no |
| proxy_ports | Ports used by proxy server | `list(string)` | `["3128", "8080"]` | no |
| allowed_external_endpoints | Map of allowed external endpoints | `map(object)` | `{}` | no |
| internal_ranges | Internal IP ranges (VPC subnets) | `list(string)` | `["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]` | no |
| allow_gcp_services | Allow egress to GCP services | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| firewall_rules | List of created firewall rule names |

## Firewall Rule Priority

Firewall rules are applied in order of priority (lower number = higher priority):

1. **Internal traffic** (priority 100) - Always allowed
2. **DNS, proxy, external endpoints** (priority 1000) - Specific allowlist
3. **Deny all egress** (priority 65534) - Default deny

## Security Considerations

1. **Start Restrictive**: Begin with deny-all and add specific allowlist rules
2. **Document Endpoints**: Maintain clear documentation of required endpoints
3. **Regular Review**: Periodically review and remove unused allowlist entries
4. **Use Proxy**: Prefer proxy over direct external access for better control
5. **Monitor Traffic**: Enable VPC Flow Logs to monitor egress traffic

## Use Cases

- Compliance requirements (HIPAA, PCI-DSS)
- Security-restricted environments
- Air-gapped or partially air-gapped networks
- Customer environments with strict security policies
- Defense and government deployments


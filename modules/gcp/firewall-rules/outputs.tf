output "firewall_rules" {
  description = "List of created firewall rule names"
  value = concat(
    var.enable_strict_egress ? [google_compute_firewall.deny_all_egress[0].name] : [],
    var.enable_strict_egress ? [google_compute_firewall.allow_dns[0].name] : [],
    var.enable_strict_egress && var.proxy_subnet_cidr != null ? [google_compute_firewall.allow_proxy[0].name] : [],
    var.enable_strict_egress ? [for rule in google_compute_firewall.allow_external_endpoints : rule.name] : [],
    [google_compute_firewall.allow_internal.name],
    var.enable_strict_egress && var.allow_gcp_services ? [google_compute_firewall.allow_gcp_services[0].name] : []
  )
}


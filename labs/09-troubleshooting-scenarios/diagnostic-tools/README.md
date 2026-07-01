# Diagnostic Tools

These scripts support Lab 09 troubleshooting scenarios. Run them from the lab directory after creating the local scenario environment.

| Tool | Use it when |
| --- | --- |
| `cluster-health.sh` | You need a quick view of nodes, pods, events, and common cluster-level symptoms. |
| `connectivity-check.sh` | You need to test service, DNS, and network reachability. |
| `log-collector.sh` | You need to collect relevant logs for a failing scenario. |
| `resource-inspector.sh` | You need to inspect requests, limits, quotas, and resource pressure. |

```bash
cd labs/09-troubleshooting-scenarios
diagnostic-tools/cluster-health.sh
diagnostic-tools/connectivity-check.sh
diagnostic-tools/log-collector.sh
diagnostic-tools/resource-inspector.sh
```

For the full workflow, see [Lab 09: Troubleshooting Scenarios](../README.md).

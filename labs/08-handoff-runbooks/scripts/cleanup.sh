#!/bin/bash
# Cleanup script for Lab 08: Handoff and Runbooks

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🧹 Cleaning up Lab 08: Handoff and Runbooks"
echo ""

# Confirm deletion
echo "⚠️  This will destroy the monitoring stack and all dashboards."
echo ""
read -p "Are you sure you want to continue? (yes/N): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
  echo "Cancelled."
  exit 0
fi

# Uninstall Prometheus Stack
echo "🗑️  Uninstalling Prometheus Stack..."
helm uninstall prometheus -n monitoring 2>/dev/null || echo "  (Prometheus stack not found)"

# Delete alerting rules
echo "🗑️  Deleting alerting rules..."
kubectl delete -f "$LAB_DIR/monitoring-setup/alerting-rules/application-alerts.yaml" 2>/dev/null || true

# Delete namespace (this will delete all resources in monitoring namespace)
echo "🗑️  Deleting monitoring namespace..."
kubectl delete namespace monitoring --wait=false 2>/dev/null || echo "  (Namespace not found)"

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "All monitoring resources have been destroyed."


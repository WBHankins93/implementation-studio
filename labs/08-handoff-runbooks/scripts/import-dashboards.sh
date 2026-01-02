#!/bin/bash
# Import Grafana dashboards

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "📊 Importing Grafana Dashboards"
echo ""

# Check if Grafana is accessible
if ! kubectl get svc -n monitoring prometheus-grafana &>/dev/null; then
  echo "❌ Grafana service not found. Make sure monitoring stack is deployed."
  echo "   Run: ./scripts/setup-monitoring.sh"
  exit 1
fi

# Port forward Grafana
echo "🔌 Setting up port forward to Grafana..."
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80 &
PORT_FORWARD_PID=$!

# Wait for port forward to be ready
sleep 5

# Cleanup function
cleanup() {
  echo ""
  echo "🧹 Cleaning up port forward..."
  kill $PORT_FORWARD_PID 2>/dev/null || true
}

trap cleanup EXIT

GRAFANA_URL="http://localhost:3000"
GRAFANA_USER="admin"
GRAFANA_PASSWORD="prom-operator"

echo "📥 Importing dashboards..."
echo ""

# Import Cluster Overview
echo "  - Cluster Overview..."
curl -s -X POST \
  -u "${GRAFANA_USER}:${GRAFANA_PASSWORD}" \
  -H "Content-Type: application/json" \
  -d @"${LAB_DIR}/monitoring-setup/grafana/cluster-overview.json" \
  "${GRAFANA_URL}/api/dashboards/db" > /dev/null || echo "    ⚠️  Failed to import Cluster Overview"

# Import Argo Workflows
echo "  - Argo Workflows..."
curl -s -X POST \
  -u "${GRAFANA_USER}:${GRAFANA_PASSWORD}" \
  -H "Content-Type: application/json" \
  -d @"${LAB_DIR}/monitoring-setup/grafana/argo-workflows.json" \
  "${GRAFANA_URL}/api/dashboards/db" > /dev/null || echo "    ⚠️  Failed to import Argo Workflows"

# Import Application Health
echo "  - Application Health..."
curl -s -X POST \
  -u "${GRAFANA_USER}:${GRAFANA_PASSWORD}" \
  -H "Content-Type: application/json" \
  -d @"${LAB_DIR}/monitoring-setup/grafana/application-health.json" \
  "${GRAFANA_URL}/api/dashboards/db" > /dev/null || echo "    ⚠️  Failed to import Application Health"

echo ""
echo "✅ Dashboard import complete!"
echo ""
echo "📊 View dashboards at:"
echo "   http://localhost:3000"
echo "   (Port forward will close when script exits)"
echo ""
echo "💡 To keep port forward running, run manually:"
echo "   kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"


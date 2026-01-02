#!/bin/bash
# Setup monitoring stack (Prometheus + Grafana)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "📊 Setting up Monitoring Stack"
echo ""

# Check prerequisites
command -v helm >/dev/null 2>&1 || { echo "❌ helm is required but not installed." >&2; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required but not installed." >&2; exit 1; }

# Check if kubectl is configured
if ! kubectl cluster-info &>/dev/null; then
  echo "❌ kubectl is not configured or cluster is not accessible"
  exit 1
fi

echo "✅ Prerequisites met"
echo ""

# Create namespace
echo "📦 Creating monitoring namespace..."
kubectl apply -f "$LAB_DIR/manifests/monitoring/namespace.yaml"

# Add Prometheus Community Helm repo
echo "📥 Adding Prometheus Community Helm repository..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus Stack
echo "🚀 Installing Prometheus Operator Stack..."
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --values "$LAB_DIR/monitoring-setup/prometheus/prometheus-values.yaml" \
  --wait

# Apply alerting rules
echo "🔔 Applying alerting rules..."
kubectl apply -f "$LAB_DIR/monitoring-setup/alerting-rules/application-alerts.yaml"

echo ""
echo "✅ Monitoring stack deployed successfully!"
echo ""
echo "📊 Access Grafana:"
echo "   kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
echo "   Open http://localhost:3000"
echo "   Username: admin"
echo "   Password: prom-operator"
echo ""
echo "📈 Access Prometheus:"
echo "   kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090"
echo "   Open http://localhost:9090"
echo ""
echo "🔔 Access Alertmanager:"
echo "   kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-alertmanager 9093:9093"
echo "   Open http://localhost:9093"
echo ""
echo "Next step: Import Grafana dashboards with ./scripts/import-dashboards.sh"


#!/bin/bash
# Setup Troubleshooting Scenarios

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🚀 Setting up Troubleshooting Scenarios"
echo ""

# Check prerequisites
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required but not installed." >&2; exit 1; }
command -v kind >/dev/null 2>&1 || { echo "❌ kind is required but not installed." >&2; exit 1; }

# Check if cluster exists
if ! kubectl cluster-info &>/dev/null; then
  echo "⚠️  No cluster detected. Creating Kind cluster..."
  kind create cluster --name troubleshooting-lab
  echo "✅ Kind cluster created"
else
  echo "✅ Cluster detected"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "Available scenarios:"
echo "  1. Network Connectivity: ./scenarios/network-connectivity/simulate.sh"
echo "  2. Resource Exhaustion: ./scenarios/resource-exhaustion/simulate.sh"
echo ""
echo "Diagnostic tools:"
echo "  - connectivity-check.sh"
echo "  - resource-inspector.sh"
echo "  - log-collector.sh"
echo "  - cluster-health.sh"
echo ""
echo "Run a scenario to get started!"


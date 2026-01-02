#!/bin/bash
# Main setup script for Lab 02: Air-Gapped Deployment
# This script guides you through the two-phase approach

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🚀 Lab 02: Air-Gapped Deployment Setup"
echo ""
echo "This lab uses a two-phase approach:"
echo "  1. Preparation (with internet) - Prepare offline packages"
echo "  2. Deployment (air-gapped) - Deploy without internet"
echo ""

# Check prerequisites
echo "📋 Checking prerequisites..."

command -v docker >/dev/null 2>&1 || { echo "❌ docker is required but not installed." >&2; exit 1; }
command -v kind >/dev/null 2>&1 || { echo "❌ kind is required but not installed. Install: brew install kind" >&2; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "❌ helm is required but not installed." >&2; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required but not installed." >&2; exit 1; }

echo "✅ All prerequisites met"
echo ""

# Check disk space
echo "💾 Checking disk space..."
AVAILABLE=$(df -h . | tail -1 | awk '{print $4}')
echo "  Available: $AVAILABLE"
echo "  Required: ~10GB for images"
echo ""

# Ask which phase
echo "Which phase would you like to run?"
echo "  1) Preparation Phase (with internet) - Prepare deployment bundle"
echo "  2) Deployment Phase (air-gapped) - Deploy from bundle"
echo "  3) Local Simulation Setup - Setup Kind cluster for testing"
echo ""
read -p "Enter choice (1-3): " -r choice

case $choice in
  1)
    echo ""
    echo "📦 Starting Preparation Phase..."
    echo ""
    cd "$LAB_DIR/preparation"
    echo "Step 1: Mirroring images..."
    ./mirror-images.sh
    echo ""
    echo "Step 2: Packaging Helm charts..."
    ./package-helm.sh
    echo ""
    echo "Step 3: Creating deployment bundle..."
    ./create-bundle.sh
    echo ""
    echo "✅ Preparation phase complete!"
    echo "   Next: Transfer bundle to air-gapped environment"
    ;;
  2)
    echo ""
    echo "📦 Starting Deployment Phase..."
    echo ""
    echo "⚠️  Make sure you have:"
    echo "  - Transferred the deployment bundle"
    echo "  - Set up Kind cluster (or have air-gapped cluster)"
    echo ""
    read -p "Continue? (y/N): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      exit 0
    fi
    cd "$LAB_DIR/deployment"
    echo "Step 1: Deploying registry..."
    ./deploy-registry.sh
    echo ""
    echo "Step 2: Loading images..."
    ./load-images.sh
    echo ""
    echo "Step 3: Deploying Argo Workflows..."
    ./deploy-argo.sh
    echo ""
    echo "Step 4: Validating deployment..."
    ./validate.sh
    echo ""
    echo "✅ Deployment phase complete!"
    ;;
  3)
    echo ""
    echo "🔧 Setting up local simulation..."
    echo ""
    cd "$LAB_DIR/local-simulation"
    ./setup-airgap-sim.sh
    echo ""
    echo "✅ Local simulation setup complete!"
    ;;
  *)
    echo "Invalid choice"
    exit 1
    ;;
esac


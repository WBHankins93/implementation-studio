#!/bin/bash
# Deploy Argo Workflows with proxy configuration

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🚀 Deploying Argo Workflows with Proxy Configuration"
echo ""

# Check if kubectl is configured
if ! kubectl cluster-info &>/dev/null; then
  echo "❌ kubectl is not configured or cluster is not accessible"
  echo "   Run: gcloud container clusters get-credentials <cluster-name> --region <region> --project <project-id>"
  exit 1
fi

# Get proxy IP from Terraform output
cd "$LAB_DIR"
PROXY_IP=$(terraform output -raw proxy_internal_ip 2>/dev/null || echo "")

if [ -z "$PROXY_IP" ]; then
  echo "⚠️  Could not get proxy IP from Terraform output"
  echo "   Please set PROXY_IP environment variable or update manifests/proxy-configmap.yaml manually"
  read -p "Enter proxy internal IP: " PROXY_IP
fi

# Get cluster info
CLUSTER_NAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}' 2>/dev/null || echo "unknown")
echo "📦 Cluster: $CLUSTER_NAME"
echo "🔌 Proxy IP: $PROXY_IP"
echo ""

# Add Helm repos
echo "📥 Adding Helm repositories..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Create namespace
echo "📝 Creating namespace..."
kubectl create namespace argo --dry-run=client -o yaml | kubectl apply -f -

# Update proxy ConfigMap with actual proxy IP
echo "🔧 Configuring proxy settings..."
sed "s|PROXY_INTERNAL_IP|$PROXY_IP|g" "$LAB_DIR/manifests/proxy-configmap.yaml" | kubectl apply -f -

# Apply network policies
echo "🛡️  Applying network policies..."
kubectl apply -f "$LAB_DIR/manifests/network-policy-egress.yaml"

# Install Ingress NGINX
echo "🌐 Installing Ingress NGINX..."
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --wait

# Install Argo Workflows with proxy environment variables
echo "⚙️  Installing Argo Workflows with proxy configuration..."

# Create values file with proxy settings
cat > /tmp/argo-values.yaml <<EOF
server:
  extraEnv:
    - name: HTTP_PROXY
      valueFrom:
        configMapKeyRef:
          name: proxy-config
          key: HTTP_PROXY
    - name: HTTPS_PROXY
      valueFrom:
        configMapKeyRef:
          name: proxy-config
          key: HTTPS_PROXY
    - name: NO_PROXY
      valueFrom:
        configMapKeyRef:
          name: proxy-config
          key: NO_PROXY
  env:
    - name: HTTP_PROXY
      valueFrom:
        configMapKeyRef:
          name: proxy-config
          key: HTTP_PROXY
    - name: HTTPS_PROXY
      valueFrom:
        configMapKeyRef:
          name: proxy-config
          key: HTTPS_PROXY
    - name: NO_PROXY
      valueFrom:
        configMapKeyRef:
          name: proxy-config
          key: NO_PROXY

controller:
  extraEnv:
    - name: HTTP_PROXY
      valueFrom:
        configMapKeyRef:
          name: proxy-config
          key: HTTP_PROXY
    - name: HTTPS_PROXY
      valueFrom:
        configMapKeyRef:
          name: proxy-config
          key: HTTPS_PROXY
    - name: NO_PROXY
      valueFrom:
        configMapKeyRef:
          name: proxy-config
          key: NO_PROXY
  env:
    - name: HTTP_PROXY
      valueFrom:
        configMapKeyRef:
          name: proxy-config
          key: HTTP_PROXY
    - name: HTTPS_PROXY
      valueFrom:
        configMapKeyRef:
          name: proxy-config
          key: HTTPS_PROXY
    - name: NO_PROXY
      valueFrom:
        configMapKeyRef:
          name: proxy-config
          key: NO_PROXY

workflow:
  podSpecPatch: |
    env:
      - name: HTTP_PROXY
        valueFrom:
          configMapKeyRef:
            name: proxy-config
            key: HTTP_PROXY
      - name: HTTPS_PROXY
        valueFrom:
          configMapKeyRef:
            name: proxy-config
            key: HTTPS_PROXY
      - name: NO_PROXY
        valueFrom:
          configMapKeyRef:
            name: proxy-config
            key: NO_PROXY
EOF

helm upgrade --install argo-workflows argo/argo-workflows \
  --namespace argo \
  --values "$LAB_DIR/../../modules/kubernetes/argo-workflows/helm-values.yaml" \
  --values /tmp/argo-values.yaml \
  --wait

# Wait for services
echo "⏳ Waiting for services to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argo-workflows-server -n argo || true
kubectl wait --for=condition=available --timeout=300s deployment/ingress-nginx-controller -n ingress-nginx || true

# Get ingress IP
echo ""
echo "🔍 Getting Ingress IP..."
INGRESS_IP=$(kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")
if [ "$INGRESS_IP" != "pending" ] && [ -n "$INGRESS_IP" ]; then
  echo "✅ Ingress IP: $INGRESS_IP"
else
  echo "⏳ Ingress IP is still being assigned. Check with:"
  echo "   kubectl get service ingress-nginx-controller -n ingress-nginx"
fi

echo ""
echo "✅ Deployment complete!"
echo ""
echo "Proxy Configuration:"
echo "  HTTP_PROXY: http://$PROXY_IP:3128"
echo "  HTTPS_PROXY: http://$PROXY_IP:3128"
echo ""
echo "Next steps:"
echo "1. Verify proxy is accessible: ./scripts/test-egress.sh"
echo "2. Submit a sample workflow: kubectl apply -f manifests/sample-workflow.yaml"
echo "3. Check workflow logs to verify proxy usage"


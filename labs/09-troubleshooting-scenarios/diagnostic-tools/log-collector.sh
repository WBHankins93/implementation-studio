#!/bin/bash
# Log Collector Tool

set -euo pipefail

NAMESPACE="${1:-default}"
POD_NAME="${2:-}"
OUTPUT_DIR="${3:-./logs}"

echo "📋 Log Collector Tool"
echo ""

if [ -z "$POD_NAME" ]; then
  echo "Usage: $0 <namespace> <pod-name> [output-dir]"
  echo ""
  echo "Example: $0 default my-pod"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo "Collecting logs for pod: $POD_NAME in namespace: $NAMESPACE"
echo "Output directory: $OUTPUT_DIR"
echo ""

# Collect current logs
echo "📥 Collecting current logs..."
kubectl logs "$POD_NAME" -n "$NAMESPACE" > "$OUTPUT_DIR/${POD_NAME}-current.log" 2>&1 || echo "  ⚠️  Could not collect current logs"
echo "  ✅ Saved to: $OUTPUT_DIR/${POD_NAME}-current.log"

# Collect previous logs (if pod restarted)
echo "📥 Collecting previous logs..."
kubectl logs "$POD_NAME" -n "$NAMESPACE" --previous > "$OUTPUT_DIR/${POD_NAME}-previous.log" 2>&1 || echo "  ℹ️  No previous logs (pod hasn't restarted)"
if [ -s "$OUTPUT_DIR/${POD_NAME}-previous.log" ]; then
  echo "  ✅ Saved to: $OUTPUT_DIR/${POD_NAME}-previous.log"
fi

# Collect pod description
echo "📥 Collecting pod description..."
kubectl describe pod "$POD_NAME" -n "$NAMESPACE" > "$OUTPUT_DIR/${POD_NAME}-describe.txt" 2>&1
echo "  ✅ Saved to: $OUTPUT_DIR/${POD_NAME}-describe.txt"

# Collect events
echo "📥 Collecting events..."
kubectl get events -n "$NAMESPACE" --field-selector involvedObject.name="$POD_NAME" --sort-by='.lastTimestamp' > "$OUTPUT_DIR/${POD_NAME}-events.txt" 2>&1
echo "  ✅ Saved to: $OUTPUT_DIR/${POD_NAME}-events.txt"

# Collect pod YAML
echo "📥 Collecting pod YAML..."
kubectl get pod "$POD_NAME" -n "$NAMESPACE" -o yaml > "$OUTPUT_DIR/${POD_NAME}.yaml" 2>&1
echo "  ✅ Saved to: $OUTPUT_DIR/${POD_NAME}.yaml"

echo ""
echo "✅ Log collection complete"
echo ""
echo "📁 Collected files:"
ls -lh "$OUTPUT_DIR" | grep "$POD_NAME"
echo ""
echo "💡 Tip: Review logs for errors, warnings, and patterns"


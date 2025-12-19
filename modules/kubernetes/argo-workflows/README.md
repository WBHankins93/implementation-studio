# Argo Workflows Module

## What is This?

This module provides the Helm values configuration for deploying Argo Workflows to a Kubernetes cluster. Argo Workflows is a container-native workflow engine for orchestrating parallel jobs on Kubernetes.

## When to Use This Module

- Need to run multi-step workflows (data pipelines, ML training, batch jobs)
- Want to orchestrate parallel container tasks
- Building CI/CD pipelines
- Running scheduled or event-driven jobs

## What is Argo Workflows?

Argo Workflows lets you:
- Define workflows as Kubernetes YAML
- Run tasks in parallel or sequence
- Handle retries and error handling
- Pass data between workflow steps
- Integrate with Kubernetes resources

**Example Use Cases:**
- Data processing pipelines
- Machine learning model training
- Batch job processing
- Multi-step deployments
- Simulation workloads

## What This Module Provides

- **Helm Values File**: Pre-configured values for Argo Workflows
- **Production Settings**: Resource limits, persistence, TTL
- **Security**: Non-root user, proper security contexts
- **Monitoring**: Metrics enabled

## How It Works

```
Workflow YAML
   │
   ▼
┌─────────────────────────────┐
│  kubectl apply              │
└─────────────────────────────┘
   │
   ▼
┌─────────────────────────────┐
│  Argo Workflow Controller  │
│  - Validates workflow       │
│  - Creates pods for steps   │
│  - Manages state            │
└─────────────────────────────┘
   │
   ▼
┌─────────────────────────────┐
│  Kubernetes Pods            │
│  - Execute workflow steps   │
│  - Pass artifacts          │
└─────────────────────────────┘
```

## Usage

### Using Helm Directly

```bash
# Add Helm repository
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Install Argo Workflows
helm install argo-workflows argo/argo-workflows \
  -f modules/kubernetes/argo-workflows/helm-values.yaml \
  -n argo --create-namespace
```

### Verify Installation

```bash
kubectl get pods -n argo
kubectl get svc -n argo
```

### Access the UI

```bash
# Port forward to access UI
kubectl port-forward svc/argo-workflows-server 2746:2746 -n argo
# Open http://localhost:2746
```

## Configuration Explained

### Resource Limits

```yaml
resources:
  limits:
    cpu: 500m      # Maximum CPU
    memory: 512Mi  # Maximum memory
  requests:
    cpu: 100m      # Guaranteed CPU
    memory: 128Mi  # Guaranteed memory
```

### Workflow TTL

```yaml
ttlStrategy:
  secondsAfterCompletion: 86400  # Delete after 24 hours
  secondsAfterSuccess: 86400
  secondsAfterFailure: 604800    # Keep failures for 7 days
```

This automatically cleans up completed workflows.

### Persistence

```yaml
persistence:
  archive: true           # Store workflow history
  accessMode: ReadWriteOnce
  size: 10Gi             # Storage size
```

## Submitting Workflows

### Simple Workflow

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: hello-world-
  namespace: argo
spec:
  entrypoint: whalesay
  templates:
    - name: whalesay
      container:
        image: docker/whalesay:latest
        command: [cowsay]
        args: ["Hello from Argo!"]
```

Apply it:

```bash
kubectl apply -f workflow.yaml
kubectl get workflows -n argo
```

## Files

- `helm-values.yaml` - Helm chart configuration values
- `README.md` - This documentation

## Requirements

- **Kubernetes Cluster**: Version 1.20 or higher
- **Helm**: Version 3.x
- **kubectl**: Configured to access your cluster
- **Storage**: Persistent volume for workflow history (optional)

## Components Deployed

1. **Workflow Controller**: Manages workflow execution
2. **Workflow Server**: Provides API and UI
3. **Service Account**: For workflow execution
4. **ConfigMaps**: Configuration
5. **Services**: For UI and API access

## Security Features

- **Non-root User**: Workflows run as non-root (UID 8737)
- **RBAC**: Proper role-based access control
- **Service Accounts**: Isolated service accounts per namespace
- **Network Policies**: Compatible with network policies

## Monitoring

Metrics are enabled by default. Access them:

```bash
kubectl port-forward svc/argo-workflows-server-metrics 9090:9090 -n argo
```

## Troubleshooting

### Workflows Stuck in Pending

```bash
# Check controller logs
kubectl logs -n argo -l app=workflow-controller

# Check workflow events
kubectl describe workflow <workflow-name> -n argo
```

### Cannot Access UI

```bash
# Check service
kubectl get svc argo-workflows-server -n argo

# Port forward as workaround
kubectl port-forward svc/argo-workflows-server 2746:2746 -n argo
```

### Workflow Fails

```bash
# View workflow details
kubectl describe workflow <workflow-name> -n argo

# Check pod logs
kubectl logs <pod-name> -n argo
```

## Learn More

- [Argo Workflows Documentation](https://argoproj.github.io/workflows/)
- [Workflow Examples](https://github.com/argoproj/argo-workflows/tree/master/examples)
- [Workflow Concepts](https://argoproj.github.io/workflows/concepts/)

## Related Modules

- `argo-workflows-airgap` - Offline deployment version
- `ingress-nginx` - Expose UI via ingress


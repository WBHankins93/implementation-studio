# Reference Application: Argo Workflows

## Overview

Argo Workflows serves as the reference application for Implementation Studio. It's a Kubernetes-native workflow engine that demonstrates deployment patterns in various constrained environments.

## Why Argo Workflows?

- **Kubernetes-native**: Deployment IS the lesson
- **Relevant**: Common in ML/data engineering contexts
- **Lightweight**: Minimal deployment footprint
- **Useful**: Teaches a genuinely useful tool
- **Real-world**: Represents simulation/compute workloads (job submission, execution, results)

## Sample Workflows

The `workflows/` directory contains example workflows demonstrating different patterns:

### hello-world.yaml
Simplest possible workflow - a single container task.

```bash
kubectl apply -f workflows/hello-world.yaml
```

### multi-step.yaml
Sequential execution - tasks run one after another.

```bash
kubectl apply -f workflows/multi-step.yaml
```

### parallel-jobs.yaml
Parallel execution - multiple tasks run simultaneously.

```bash
kubectl apply -f workflows/parallel-jobs.yaml
```

### compute-intensive.yaml
CPU-heavy workload - demonstrates resource requests and limits.

```bash
kubectl apply -f workflows/compute-intensive.yaml
```

### data-pipeline.yaml
Input → process → output - demonstrates artifact passing.

```bash
kubectl apply -f workflows/data-pipeline.yaml
```

### failure-handling.yaml
Retries and error handling - demonstrates resilience patterns.

```bash
kubectl apply -f workflows/failure-handling.yaml
```

## Using Workflows

### Submit a Workflow

```bash
kubectl apply -f workflows/hello-world.yaml
```

### List Workflows

```bash
kubectl get workflows -n argo
```

### View Workflow Details

```bash
kubectl describe workflow <workflow-name> -n argo
```

### View Workflow Logs

```bash
kubectl logs -n argo <workflow-name>
```

### Delete a Workflow

```bash
kubectl delete workflow <workflow-name> -n argo
```

## Workflow Templates

The `workflow-templates/` directory contains reusable workflow templates for common patterns.

## Scripts

The `scripts/` directory contains helper scripts for workflow management:

- `submit-workflow.sh` - Submit a workflow
- `watch-workflow.sh` - Watch workflow status
- `get-results.sh` - Get workflow results
- `cleanup-completed.sh` - Clean up completed workflows

## Learn More

- [Argo Workflows Documentation](https://argoproj.github.io/workflows/)
- [Workflow Examples](https://github.com/argoproj/argo-workflows/tree/master/examples)


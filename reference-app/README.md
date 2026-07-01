# Reference Application: Argo Workflows

Argo Workflows is the reference workload for Implementation Studio. It is Kubernetes-native, lightweight enough for labs, and realistic enough to expose the deployment issues this repo teaches: networking, image access, RBAC, ingress, resource limits, failures, and handoff.

## Why Argo Workflows

| Quality | Why it matters here |
| --- | --- |
| Kubernetes-native | The deployment platform is part of the lesson. |
| Operationally realistic | Workflows model compute, data, ML, and batch-processing workloads. |
| Portable | The same workload can run across Kind, GKE, and EKS. |
| Constraint-sensitive | It makes air-gap, proxy, registry, RBAC, and resource issues visible. |
| Useful | Learners leave with a real tool, not only a toy app. |

## Workflow Catalog

| Workflow | Pattern | Run |
| --- | --- | --- |
| [hello-world.yaml](workflows/hello-world.yaml) | Minimal single-step workflow | `kubectl apply -f workflows/hello-world.yaml` |
| [multi-step.yaml](workflows/multi-step.yaml) | Sequential task execution | `kubectl apply -f workflows/multi-step.yaml` |
| [parallel-jobs.yaml](workflows/parallel-jobs.yaml) | Parallel fan-out | `kubectl apply -f workflows/parallel-jobs.yaml` |
| [compute-intensive.yaml](workflows/compute-intensive.yaml) | Resource requests and limits | `kubectl apply -f workflows/compute-intensive.yaml` |
| [data-pipeline.yaml](workflows/data-pipeline.yaml) | Input, process, output flow | `kubectl apply -f workflows/data-pipeline.yaml` |
| [failure-handling.yaml](workflows/failure-handling.yaml) | Retries and failure behavior | `kubectl apply -f workflows/failure-handling.yaml` |

## Basic Commands

Submit a workflow:

```bash
kubectl apply -f reference-app/workflows/hello-world.yaml
```

List workflows:

```bash
kubectl get workflows -n argo
```

Inspect a workflow:

```bash
kubectl describe workflow <workflow-name> -n argo
```

View pod logs:

```bash
kubectl logs -n argo <pod-name>
```

Delete a workflow:

```bash
kubectl delete workflow <workflow-name> -n argo
```

## Used By

The workflows are used across the labs as a stable target application:

- [Lab 01: Standard Deployment](../labs/01-standard-deployment/README.md)
- [Lab 02: Air-Gapped Deployment](../labs/02-airgapped-deployment/README.md)
- [Lab 03: Private Network Deployment](../labs/03-private-network-deployment/README.md)
- [Lab 04: Firewall-Restricted Deployment](../labs/04-firewall-restricted-deployment/README.md)
- [Lab 05: POC Sprint](../labs/05-poc-sprint/README.md)

## Learn More

- [Argo Workflows documentation](https://argoproj.github.io/workflows/)
- [Argo Workflows examples](https://github.com/argoproj/argo-workflows/tree/master/examples)

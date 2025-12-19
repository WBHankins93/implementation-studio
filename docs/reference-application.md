# Reference Application: Argo Workflows

## Why Argo Workflows?

Implementation Studio uses **Argo Workflows** as the reference application across all labs. This choice was made for several strategic reasons:

### 1. Kubernetes-Native

Argo Workflows is built specifically for Kubernetes, which means:
- The deployment process itself teaches Kubernetes concepts
- No external dependencies or complex integrations
- Everything runs within the cluster

### 2. Relevant to Real-World Scenarios

Argo Workflows represents a class of applications that:
- Submit compute jobs (simulation workloads, data processing)
- Execute tasks that consume resources
- Produce results that need to be retrieved
- Are common in ML/data engineering contexts

### 3. Lightweight Footprint

Unlike heavier platforms (JupyterHub, full ML platforms), Argo Workflows:
- Has a minimal resource footprint
- Starts quickly
- Is easy to understand and modify
- Doesn't distract from deployment patterns

### 4. Educational Value

Learning Argo Workflows provides:
- Understanding of workflow orchestration
- Experience with Kubernetes-native job execution
- Skills transferable to other workflow engines
- A genuinely useful tool beyond this project

## What Argo Workflows Represents

In the context of Implementation Studio, Argo Workflows represents:

- **A compute-intensive application** that needs resources
- **A job submission system** where users submit work
- **A results retrieval system** where outputs are accessed
- **A multi-tenant application** (in later labs)

Think of it as a stand-in for:
- Simulation platforms
- Data processing pipelines
- ML training jobs
- Scientific computing workloads
- Any application that runs jobs and produces results

## Sample Workflows

The `reference-app/workflows/` directory contains example workflows:

- **hello-world.yaml** - Simplest possible workflow
- **multi-step.yaml** - Sequential execution
- **parallel-jobs.yaml** - Parallel execution
- **compute-intensive.yaml** - CPU-heavy workloads
- **data-pipeline.yaml** - Input → process → output
- **failure-handling.yaml** - Retries and error handling

## Using the Reference Application

### In Labs

Each lab deploys Argo Workflows and uses sample workflows to:
- Validate the deployment works
- Demonstrate the application's capabilities
- Test connectivity and access patterns
- Verify constraints (air-gap, network policies, etc.)

### In Real Engagements

The patterns learned here apply to:
- Any Kubernetes-native application
- Applications requiring job execution
- Multi-tenant platforms
- Applications with similar deployment constraints

## Substituting Other Applications

While Argo Workflows is the reference, the deployment patterns taught here apply to any Kubernetes application. You can:

- Replace Argo Workflows with your own application
- Use the same modules and patterns
- Adapt the labs to your specific use case

The deployment constraints (air-gap, private networks, firewalls) are universal.

---

For more information about Argo Workflows, see: https://argoproj.github.io/workflows/


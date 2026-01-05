# ADR-001: Reference Application Selection

## Status
Accepted

## Context

Implementation Studio is a learning platform that teaches engineers how to deploy software into real-world, constrained customer environments. To effectively teach deployment patterns, we need a **reference application** that:

1. **Demonstrates deployment challenges** - Must be deployable in various constrained environments (air-gapped, private networks, firewall-restricted)
2. **Represents real-world use cases** - Should mirror applications engineers encounter in customer environments
3. **Is Kubernetes-native** - The deployment process itself should teach Kubernetes concepts
4. **Has minimal complexity** - Should not distract from learning deployment patterns
5. **Provides educational value** - Learning the application should be useful beyond this project

The reference application will be used across all 9 labs, so this decision has significant long-term impact on the platform's effectiveness and learner experience.

## Decision

We will use **Argo Workflows** as the reference application for Implementation Studio.

Argo Workflows is a Kubernetes-native workflow engine that orchestrates parallel jobs on Kubernetes. It will be deployed in every lab to demonstrate deployment patterns in various constrained environments.

## Consequences

### Positive

- **Kubernetes-native architecture** - The deployment process itself teaches Kubernetes concepts (CRDs, controllers, pods, services)
- **No external dependencies** - Everything runs within the cluster, simplifying deployment in constrained environments
- **Lightweight footprint** - Minimal resource requirements, fast startup, easy to understand
- **Real-world relevance** - Represents compute-intensive applications common in ML/data engineering contexts
- **Educational value** - Teaches workflow orchestration, a genuinely useful skill
- **Well-documented** - Active community, comprehensive documentation, stable project
- **Air-gap friendly** - Can be packaged for offline deployment (critical for Lab 02)
- **Multi-tenant capable** - Supports namespace isolation and RBAC (important for Lab 06)
- **Flexible** - Can represent various application patterns (job submission, results retrieval, batch processing)

### Negative

- **Learning curve** - Learners must understand Argo Workflows concepts in addition to deployment patterns
- **Specific use case** - Primarily suited for workflow/job execution scenarios, less representative of web applications
- **Not a traditional web app** - Doesn't demonstrate typical HTTP service patterns (though this is acceptable for our use case)

### Neutral

- **CNCF project** - Well-maintained but not as widely known as some alternatives
- **Workflow-focused** - Specialized tool, but specialization aligns with our teaching goals

## Alternatives Considered

### Option 1: Apache Airflow

**Pros:**
- Industry standard for workflow orchestration
- Extensive ecosystem and integrations
- Well-known in data engineering communities
- Mature and battle-tested

**Cons:**
- **Not Kubernetes-native** - Requires external database (PostgreSQL), Redis, and complex setup
- **Heavy footprint** - Multiple components, higher resource requirements
- **Complex deployment** - Air-gapped deployment would be significantly more complex
- **External dependencies** - Database and message broker add deployment complexity
- **Less educational** - Deployment complexity distracts from learning deployment patterns

**Why not chosen:** The external dependencies (database, Redis) make it unsuitable for constrained environments and add unnecessary complexity to the learning experience.

### Option 2: Tekton

**Pros:**
- Kubernetes-native (CNCF project)
- Designed for CI/CD pipelines
- Strong Kubernetes integration
- Good for teaching Kubernetes concepts

**Cons:**
- **CI/CD focused** - Less representative of general application deployment
- **More complex** - Requires understanding of Tekton-specific concepts (Tasks, Pipelines, PipelineRuns)
- **Less versatile** - Primarily for CI/CD, not general compute workloads
- **Smaller ecosystem** - Less documentation and examples compared to Argo

**Why not chosen:** While Kubernetes-native, Tekton is too specialized for CI/CD and doesn't represent the broader class of applications we want to teach deployment for.

### Option 3: Kubeflow

**Pros:**
- Comprehensive ML platform
- Kubernetes-native
- Represents complex multi-component applications
- Good for ML/data science use cases

**Cons:**
- **Extremely heavy** - Multiple components, high resource requirements
- **Complex deployment** - Would require significant simplification for labs
- **Overkill** - Too complex for teaching deployment patterns
- **Distracting** - Complexity of Kubeflow itself would overshadow deployment lessons
- **Air-gap challenging** - Many components make offline deployment difficult

**Why not chosen:** The complexity is too high and would distract from the core learning objectives. It's also overkill for demonstrating deployment patterns.

### Option 4: NGINX / Simple Web Application

**Pros:**
- Simple and familiar
- Minimal complexity
- Represents common web application pattern
- Easy to understand

**Cons:**
- **Too simple** - Doesn't demonstrate job submission, execution, and results retrieval patterns
- **Limited learning value** - Doesn't teach workflow orchestration or complex application patterns
- **Less representative** - Many customer deployments involve compute-intensive workloads, not just web services
- **No multi-step patterns** - Doesn't demonstrate sequential or parallel execution patterns

**Why not chosen:** While simple, it doesn't represent the class of applications (simulation platforms, data processing, ML training) that commonly face the deployment constraints we're teaching.

### Option 5: Custom Simple Application

**Pros:**
- Complete control over complexity
- Can be designed specifically for teaching
- No external dependencies

**Cons:**
- **Maintenance burden** - We'd need to maintain our own application
- **Less real-world** - Learners wouldn't gain experience with a real tool
- **Limited transferability** - Skills wouldn't transfer to real-world scenarios
- **Development time** - Would require significant development effort

**Why not chosen:** The maintenance burden and lack of real-world applicability outweigh the benefits of complete control.

## Decision Rationale

Argo Workflows was chosen because it best balances all our requirements:

1. **Kubernetes-native** - Everything runs in-cluster, teaching Kubernetes concepts through deployment
2. **Appropriate complexity** - Complex enough to be interesting, simple enough not to distract
3. **Real-world relevance** - Represents compute-intensive applications common in customer environments
4. **Constrained environment friendly** - Can be packaged for air-gapped deployment
5. **Educational value** - Teaches a genuinely useful tool (workflow orchestration)
6. **Multi-tenant capable** - Supports the isolation patterns we teach in Lab 06
7. **Well-maintained** - Active CNCF project with good documentation

The choice of a workflow engine over a traditional web application is intentional - many customer deployments involve compute-intensive workloads (simulation, data processing, ML training) that follow the job submission → execution → results retrieval pattern that Argo Workflows represents.

## Implementation

Argo Workflows is deployed in all 9 labs using:
- Helm charts for standard deployments
- Custom configurations for air-gapped scenarios (Lab 02)
- Namespace isolation for multi-tenant scenarios (Lab 06)
- Integration patterns for external services (Lab 07)

Sample workflows are provided in `reference-app/workflows/` to demonstrate various patterns.

## References

- [Argo Workflows Documentation](https://argoproj.github.io/workflows/)
- [Reference Application Guide](../01-getting-started/reference-application.md)
- [Argo Workflows GitHub](https://github.com/argoproj/argo-workflows)
- [CNCF Argo Project](https://www.cncf.io/projects/argo/)

---

**Date:** January 5, 2026  
**Author:** Ben Hankins  
**Status:** Accepted


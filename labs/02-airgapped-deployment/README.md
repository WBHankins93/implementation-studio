# Lab 02: Air-Gapped Deployment

## Learning Objectives

By completing this lab, you will:

- Understand what "air-gapped" means in practice and why it matters
- Learn how to mirror container images to a private registry
- Package Helm charts for offline installation
- Deploy applications to a cluster with no internet access
- Plan update and patch strategies for isolated environments
- Apply these patterns to real customer air-gapped deployments

## What is Air-Gapped?

An **air-gapped** environment is a network-isolated system that has no connection to the internet or external networks. These environments are common in:

- **Defense and Government** - Classified systems, secure facilities
- **Financial Services** - High-security trading systems, compliance requirements
- **Healthcare** - Protected health information (PHI) systems
- **Industrial Control** - Critical infrastructure, SCADA systems
- **Research Facilities** - Proprietary research, intellectual property protection

**Why Air-Gap?**
- Security: Prevent external attacks, data exfiltration
- Compliance: Meet regulatory requirements (HIPAA, FedRAMP, etc.)
- Isolation: Protect sensitive data and systems
- Control: Complete control over what enters the environment

**The Challenge:**
- Cannot pull container images from Docker Hub, Quay.io, etc.
- Cannot download Helm charts from public repositories
- Cannot access external package managers
- Updates must be planned and transferred manually

**The Solution:**
This lab teaches you to prepare everything offline, transfer it securely, and deploy without internet access.

## Prerequisites

### Tools Required

- **Docker** - For pulling, saving, and loading images
- **Kind** - For local Kubernetes cluster (or use existing cluster)
- **Helm 3.x** - For packaging and installing charts
- **kubectl** - For cluster management
- **Internet Access** - Only for preparation phase

### Disk Space

- **~10GB** for container images
- **~100MB** for Helm charts
- **~500MB** for deployment bundle

### Knowledge

- Basic understanding of Kubernetes concepts
- Familiarity with Docker commands
- Understanding of container registries
- Basic shell scripting knowledge (helpful but not required)

## Two-Phase Approach

This lab uses a **two-phase approach** that mirrors real-world air-gapped deployments:

### Phase 1: Preparation (With Internet) 🌐

**Location:** Your development machine or a "jump server" with internet access

**What You Do:**
1. Identify all required container images
2. Pull and save images as tar files
3. Package Helm charts for offline use
4. Create a complete deployment bundle
5. Verify bundle integrity

**Output:** A complete deployment bundle ready for transfer

**Time:** 15-30 minutes (depending on internet speed)

### Phase 2: Deployment (Air-Gapped) 🔒

**Location:** Air-gapped environment (simulated with Kind for this lab)

**What You Do:**
1. Transfer bundle to air-gapped environment
2. Deploy local container registry
3. Load images into registry
4. Deploy Argo Workflows from local charts and images
5. Validate deployment works without internet

**Output:** Fully functional Argo Workflows deployment

**Time:** 30-45 minutes

## Quick Start

### Complete Workflow

```bash
# 1. Preparation Phase (with internet)
cd labs/02-airgapped-deployment/preparation
./mirror-images.sh
./package-helm.sh
./create-bundle.sh

# 2. Setup local simulation (optional, for testing)
cd ../local-simulation
./setup-airgap-sim.sh

# 3. Deployment Phase (air-gapped)
cd ../deployment
./deploy-registry.sh
./load-images.sh
./deploy-argo.sh
./validate.sh
```

### Using the Main Setup Script

```bash
cd labs/02-airgapped-deployment
./scripts/setup.sh
# Follow the interactive prompts
```

## Detailed Walkthrough

For step-by-step instructions with explanations:

- **[Preparation Phase Guide](./preparation/README.md)** - Detailed preparation steps
- **[Deployment Phase Guide](./deployment/README.md)** - Detailed deployment steps
- **[Step-by-Step Guide](./docs/step-by-step.md)** - Complete walkthrough
- **[Local Simulation Guide](./local-simulation/README.md)** - Kind cluster setup

## What Gets Deployed

### Preparation Phase Outputs

- **Images Directory** - All container images as tar files
  - Argo Workflows controller images
  - Argo Workflows server images
  - Executor images
  - Any workflow-dependent images

- **Charts Directory** - Packaged Helm charts
  - Argo Workflows Helm chart (.tgz)

- **Deployment Bundle** - Complete package
  - All images
  - All charts
  - Deployment scripts
  - Kubernetes manifests
  - Checksums for verification

### Deployment Phase Outputs

- **Local Container Registry** - Docker registry running in cluster
  - Service: `local-registry.registry.svc.cluster.local:5000`
  - Stores all container images
  - Accessible only from within cluster

- **Argo Workflows** - Complete deployment
  - Workflow controller
  - Workflow server (UI)
  - All using images from local registry
  - No external dependencies

- **Network Policies** - Air-gap enforcement
  - Blocks all egress traffic
  - Allows only internal cluster communication
  - Prevents external internet access

## Estimated Time

- **Preparation Phase:** 15-30 minutes
  - Image mirroring: 10-25 minutes (depends on internet speed)
  - Chart packaging: 1-2 minutes
  - Bundle creation: 1-2 minutes

- **Deployment Phase:** 30-45 minutes
  - Cluster setup: 5-10 minutes
  - Registry deployment: 2-3 minutes
  - Image loading: 10-20 minutes
  - Argo deployment: 5-10 minutes
  - Validation: 5 minutes

**Total:** 45-75 minutes

## Estimated Cost

**$0** - This lab is fully local and requires no cloud resources.

All components run on your local machine using:
- Kind (local Kubernetes)
- Docker (local container runtime)
- Local container registry

## Architecture

See [Architecture Documentation](./docs/architecture.md) for detailed diagrams showing:
- Preparation phase flow
- Deployment phase flow
- Image mirroring process
- Registry architecture
- Network isolation

## Validation

See [VALIDATION-STATUS.md](./VALIDATION-STATUS.md) for validation details.

### Quick Validation

```bash
# Verify air-gap (should fail)
kubectl run test --image=busybox --rm -it --restart=Never -- wget -O- https://www.google.com

# Check Argo Workflows
kubectl get pods -n argo
kubectl get workflows -n argo

# Submit test workflow
kubectl apply -f ../../reference-app/workflows/hello-world.yaml
kubectl get workflows -n argo
```

## Troubleshooting

See [Troubleshooting Guide](./docs/troubleshooting.md) for common issues and solutions.

Common issues:
- Images fail to load into registry
- Argo Workflows pods stuck in ImagePullBackOff
- External access still works (air-gap not enforced)
- Registry not accessible from pods

## Real-World Application

This lab teaches patterns you'll use in real customer engagements:

### When You'll Use This

1. **Defense Contractors** - Classified systems, secure facilities
2. **Government Agencies** - FedRAMP, IL requirements
3. **Financial Institutions** - High-security trading, compliance
4. **Healthcare Organizations** - HIPAA-compliant systems
5. **Industrial Systems** - SCADA, critical infrastructure

### Adapting for Real Engagements

1. **Identify All Images** - Not just Argo, but all application dependencies
2. **Use Production Registry** - Harbor or enterprise registry instead of simple Docker registry
3. **Plan Transfer Method** - USB, secure network, physical media
4. **Document Everything** - Image versions, chart versions, configurations
5. **Test First** - Always test in non-production air-gap first
6. **Update Strategy** - Plan how to update without internet (see [Update Strategies](./docs/update-strategies.md))

### Key Differences in Production

- **Registry:** Use Harbor or enterprise registry (not simple Docker registry)
- **Transfer:** Follow customer's approved transfer procedures
- **Security:** Additional security scanning, approval processes
- **Documentation:** More detailed runbooks, change management
- **Testing:** Extensive testing in staging air-gap before production

See [Real-World Patterns](./docs/real-world-patterns.md) for more details.

## Additional Resources

### Deep Dives

- [Image Mirroring Guide](./docs/image-mirroring-guide.md) - Detailed image management
- [Offline Helm Guide](./docs/offline-helm-guide.md) - Helm chart packaging
- [Update Strategies](./docs/update-strategies.md) - How to update without internet

### External Resources

- [Docker Registry Documentation](https://docs.docker.com/registry/)
- [Harbor Documentation](https://goharbor.io/docs/) - Enterprise registry option
- [Argo Workflows Documentation](https://argoproj.github.io/workflows/)
- [Kind Documentation](https://kind.sigs.k8s.io/)

## Cleanup

To clean up all resources:

```bash
./scripts/cleanup.sh
```

Or manually:

```bash
# Delete Kind cluster
kind delete cluster --name airgap-simulation

# Delete namespaces
kubectl delete namespace argo registry
```

## Next Steps

After completing this lab:

1. **Review the Patterns** - Understand how images and charts were packaged
2. **Experiment** - Try adding more images, different workflows
3. **Understand Updates** - Read about update strategies for air-gapped environments
4. **Apply to Real Scenarios** - Use these patterns in actual customer engagements
5. **Proceed to Lab 03** - Private Network Deployment (similar constraints, different approach)

## Key Takeaways

- **Air-gap is common** - Many enterprise customers require it
- **Preparation is critical** - Everything must be ready before deployment
- **Registry is essential** - Local registry is the foundation
- **Testing matters** - Always test in non-production first
- **Documentation is key** - Track versions, configurations, procedures

This lab provides the foundation for deploying to any air-gapped environment.


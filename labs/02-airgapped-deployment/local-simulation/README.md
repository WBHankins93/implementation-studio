# Local Air-Gap Simulation

This directory contains the setup for simulating an air-gapped environment using Kind (Kubernetes in Docker).

## What is This?

This simulation creates a Kind cluster with network policies that block all external internet access, effectively simulating an air-gapped environment on your local machine.

## Why Simulate?

- **No Cloud Costs** - Test air-gap deployment patterns for free
- **Fast Iteration** - Quickly test and retry without waiting for cloud resources
- **Learning** - Understand air-gap patterns before working with real air-gapped environments
- **Validation** - Verify your deployment bundle works before transferring to real air-gap

## How It Works

1. **Kind Cluster** - Creates a local Kubernetes cluster
2. **Network Policies** - Blocks all egress traffic to external networks
3. **Local Registry** - Deploy a container registry inside the cluster
4. **Internal Only** - All traffic stays within the cluster

## Setup

```bash
cd labs/02-airgapped-deployment/local-simulation
./setup-airgap-sim.sh
```

This will:
- Create a Kind cluster named `airgap-simulation`
- Apply network policies to block external access
- Create necessary namespaces
- Configure cluster for air-gap simulation

## Verify Air-Gap

Test that external access is blocked:

```bash
# This should FAIL (proving we're air-gapped)
kubectl run test --image=busybox --rm -it --restart=Never -- wget -O- https://www.google.com

# Expected output: Connection refused or timeout
```

## Using the Cluster

```bash
# Set context
export KUBECONFIG=$(kind get kubeconfig-path --name airgap-simulation)
kubectl config use-context kind-airgap-simulation

# Verify cluster
kubectl get nodes
kubectl get pods --all-namespaces
```

## Limitations

This simulation has some limitations compared to real air-gapped environments:

- **Image Pulls** - Kind can still pull images from Docker Hub (we'll work around this)
- **Network Isolation** - Not as strict as physical air-gap
- **Scale** - Single-node or small cluster only

However, it's excellent for learning the patterns and validating your deployment process.

## Cleanup

```bash
kind delete cluster --name airgap-simulation
```

## Next Steps

After setting up the simulation:
1. Deploy local registry (see deployment/README.md)
2. Load images into registry
3. Deploy Argo Workflows from local images
4. Validate deployment works without internet


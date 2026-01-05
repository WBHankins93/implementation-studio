# Getting Started with Implementation Studio

Welcome to Implementation Studio! This guide will help you get started with the platform.

## Prerequisites

### Required Tools

- **Terraform** >= 1.5
- **kubectl** (latest stable)
- **Helm** 3.x
- **Docker** (for local testing)
- **Kind** (for local Kubernetes clusters)
- **gcloud CLI** (for GCP labs)

### Cloud Accounts

- **GCP Account** with billing enabled (for GCP labs)
- **AWS Account** with appropriate permissions (for AWS labs)
- **GitHub Account** (for cloning and contributing)

**Note:** Many labs support **Kind** (local Kubernetes) for zero-cost learning. Cloud accounts are optional.

## Installation

### Install Terraform

```bash
# macOS
brew install terraform

# Linux
# Download from https://www.terraform.io/downloads
```

### Install kubectl

```bash
# macOS
brew install kubectl

# Linux
# Follow: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
```

### Install Helm

```bash
# macOS
brew install helm

# Linux
# Follow: https://helm.sh/docs/intro/install/
```

### Install Kind

```bash
# macOS
brew install kind

# Linux
# Follow: https://kind.sigs.k8s.io/docs/user/quick-start/#installation
```

### Install gcloud CLI (for GCP labs)

```bash
# macOS
brew install google-cloud-sdk

# Linux
# Follow: https://cloud.google.com/sdk/docs/install
```

### Install aws CLI (for AWS labs)

```bash
# macOS
brew install awscli

# Linux
# Follow: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
```

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/WBHankins93/implementation-studio.git
cd implementation-studio
```

### 2. Choose Your First Lab

We recommend starting with **Lab 02: Air-Gapped Deployment** because:
- Fully testable locally (no cloud costs)
- Teaches critical skills for enterprise deployments
- No cloud account required

Alternatively:
- **Lab 01: Standard Deployment** - Supports GCP or AWS
- **Lab 05: POC Sprint** - Supports Kind (local), GCP, or AWS

### 3. Follow the Lab Instructions

Each lab includes:
- Learning objectives
- Step-by-step instructions
- Validation steps
- Troubleshooting guide

Navigate to the lab directory and follow the README.md:

```bash
cd labs/02-airgapped-deployment
cat README.md
```

## Learning Paths

See [Learning Paths](./learning-paths.md) for recommended progression through the labs.

## Next Steps

1. Read [Learning Paths](./learning-paths.md) to choose your path
2. Read [Reference Application](./reference-application.md) to understand Argo Workflows
3. Review [Lab Specifications](../04-labs/lab-specifications.md) to see all available labs
4. Choose your first lab and get started!

## Getting Help

- Check the lab's troubleshooting section
- Review [Testing Strategy](./testing-strategy.md)
- Open an issue on GitHub
- Check existing issues for solutions

## Next Steps

1. Read [Reference Application](./reference-application.md) to understand what we're deploying
2. Review [Testing Strategy](./testing-strategy.md) to understand validation
3. Choose your first lab and begin!

---

Happy learning!


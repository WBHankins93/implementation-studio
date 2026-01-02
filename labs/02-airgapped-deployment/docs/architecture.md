# Lab 02 Architecture

## Overview

Lab 02 demonstrates air-gapped deployment using a two-phase approach: preparation (with internet) and deployment (without internet).

## Two-Phase Architecture

```
┌─────────────────────────────────────────────────────────────┐
│              PHASE 1: PREPARATION (With Internet)           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Internet                                                   │
│     │                                                       │
│     ▼                                                       │
│  ┌──────────────────┐    ┌──────────────────┐            │
│  │  Docker Hub      │    │  Helm Repos      │            │
│  │  Quay.io         │    │  (argo-helm)     │            │
│  └──────────────────┘    └──────────────────┘            │
│     │                           │                          │
│     ▼                           ▼                          │
│  ┌──────────────────┐    ┌──────────────────┐            │
│  │  Pull Images     │    │  Pull Charts     │            │
│  │  Save as .tar    │    │  Package .tgz    │            │
│  └──────────────────┘    └──────────────────┘            │
│     │                           │                          │
│     └───────────┬───────────────┘                          │
│                 ▼                                           │
│         ┌───────────────┐                                  │
│         │ Create Bundle │                                  │
│         │  - Images     │                                  │
│         │  - Charts     │                                  │
│         │  - Scripts    │                                  │
│         │  - Manifests  │                                  │
│         └───────────────┘                                  │
│                 │                                           │
│                 ▼                                           │
│         ┌───────────────┐                                  │
│         │ Transfer      │                                  │
│         │ (USB/Network) │                                  │
│         └───────────────┘                                  │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│           PHASE 2: DEPLOYMENT (Air-Gapped)                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │         Air-Gapped Kubernetes Cluster               │   │
│  │  (No Internet Access)                                │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │                                                     │   │
│  │  ┌──────────────────────────────────────────────┐  │   │
│  │  │  Local Registry Namespace                     │  │   │
│  │  │  ┌────────────────────────────────────────┐  │  │   │
│  │  │  │  Docker Registry                       │  │  │   │
│  │  │  │  - Stores all images                   │  │  │   │
│  │  │  │  - Accessible only from cluster         │  │  │   │
│  │  │  └────────────────────────────────────────┘  │  │   │
│  │  └──────────────────────────────────────────────┘  │   │
│  │           │                                         │   │
│  │           ▼                                         │   │
│  │  ┌──────────────────────────────────────────────┐  │   │
│  │  │  Argo Namespace                               │  │   │
│  │  │  ┌────────────────────────────────────────┐  │  │   │
│  │  │  │  Argo Workflows                        │  │  │   │
│  │  │  │  - Controller (from local registry)    │  │  │   │
│  │  │  │  - Server (from local registry)        │  │  │   │
│  │  │  │  - Executor (from local registry)      │  │  │   │
│  │  │  └────────────────────────────────────────┘  │  │   │
│  │  └──────────────────────────────────────────────┘  │   │
│  │                                                     │   │
│  │  ┌──────────────────────────────────────────────┐  │   │
│  │  │  Network Policies                             │  │   │
│  │  │  - Block all egress                           │  │   │
│  │  │  - Allow internal only                        │  │   │
│  │  └──────────────────────────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## Image Flow

```
Preparation Phase:
Internet → Docker Pull → Docker Save → Tar Files → Bundle

Deployment Phase:
Bundle → Docker Load → Docker Tag → Docker Push → Local Registry → Pods Pull
```

## Registry Architecture

```
┌─────────────────────────────────────────┐
│      Local Container Registry           │
│      (registry namespace)               │
├─────────────────────────────────────────┤
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  Registry Service                 │ │
│  │  local-registry.registry.svc...   │ │
│  │  Port: 5000                       │ │
│  └───────────────────────────────────┘ │
│           │                             │
│           ▼                             │
│  ┌───────────────────────────────────┐ │
│  │  Registry Pod                     │ │
│  │  - Image: registry:2.8           │ │
│  │  - Storage: EmptyDir (or PVC)    │ │
│  │  - Access: ClusterIP only         │ │
│  └───────────────────────────────────┘ │
│                                         │
│  Images Stored:                         │
│  - argoproj/workflow-controller:v3.5.5  │
│  - argoproj/argoexec:v3.5.5            │
│  - (all workflow images)               │
└─────────────────────────────────────────┘
```

## Network Isolation

```
┌─────────────────────────────────────────┐
│      Air-Gapped Cluster                 │
├─────────────────────────────────────────┤
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  Network Policies                 │ │
│  │  - Default: Deny All Egress       │ │
│  │  - Allow: Internal DNS            │ │
│  │  - Allow: Registry Access         │ │
│  │  - Block: External Internet       │ │
│  └───────────────────────────────────┘ │
│           │                             │
│           ▼                             │
│  ┌───────────────────────────────────┐ │
│  │  Pod Egress Attempt               │ │
│  │  → Blocked by Network Policy      │ │
│  │  → No Internet Access             │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ✅ Internal cluster communication      │
│  ✅ Registry access                     │
│  ❌ External internet access            │
└─────────────────────────────────────────┘
```

## Deployment Flow

1. **Bundle Transfer** - Move bundle to air-gapped environment
2. **Registry Deployment** - Deploy local registry
3. **Image Loading** - Load images from bundle into registry
4. **Argo Installation** - Install Argo from local charts
5. **Image Configuration** - Configure Argo to use local registry
6. **Validation** - Verify everything works without internet

## Comparison: With Internet vs Air-Gapped

### With Internet (Standard Deployment)

```
Pod → Internet → Docker Hub → Pull Image → Run
```

### Air-Gapped (This Lab)

```
Pod → Local Registry → Pull Image → Run
     (no internet)
```

## Security Considerations

- **No External Access** - Network policies prevent data exfiltration
- **Local Registry Only** - All images come from trusted local source
- **No External Dependencies** - Everything is self-contained
- **Controlled Updates** - Updates must be planned and approved


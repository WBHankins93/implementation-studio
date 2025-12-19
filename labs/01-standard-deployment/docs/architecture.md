# Lab 01 Architecture

## Overview

Lab 01 deploys a standard GKE cluster with Argo Workflows, representing a typical production deployment pattern.

## Network Architecture

```
Internet
   │
   ▼
┌─────────────────────────────────────────┐
│         GCP VPC Network                 │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │   Public Subnet (10.0.1.0/24)    │  │
│  │   - Load Balancers               │  │
│  └──────────────────────────────────┘  │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │  Private Subnet (10.0.2.0/24)     │  │
│  │  - GKE Nodes (no external IPs)    │  │
│  │  - Cloud NAT Gateway              │  │
│  └──────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## GKE Cluster Architecture

```
┌─────────────────────────────────────────┐
│         GKE Cluster                     │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │   Control Plane (Public Endpoint) │  │
│  └──────────────────────────────────┘  │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │   Node Pool                      │  │
│  │   - Private IPs only             │  │
│  │   - Auto-scaling enabled         │  │
│  └──────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## Application Architecture

```
Internet
   │
   ▼
┌─────────────────────────────────────────┐
│   Ingress NGINX Controller              │
│   (LoadBalancer Service)                │
└─────────────────────────────────────────┘
   │
   ▼
┌─────────────────────────────────────────┐
│   Argo Workflows Server                 │
│   - UI (port 2746)                      │
│   - API (port 2746)                     │
└─────────────────────────────────────────┘
   │
   ▼
┌─────────────────────────────────────────┐
│   Argo Workflow Controller             │
│   - Executes workflows                 │
│   - Manages workflow state             │
└─────────────────────────────────────────┘
```

## Resource Flow

1. **Terraform** creates:
   - VPC and subnets
   - GKE cluster
   - Artifact Registry

2. **Helm** installs:
   - Ingress NGINX Controller
   - Argo Workflows

3. **Kubectl** applies:
   - Namespaces
   - Sample workflows

## Security Features

- Private node pools (no external IPs)
- Network policies enabled
- Workload Identity for secure service account access
- Private Google Access for GCP services

## High Availability

- Multi-zone node distribution (GKE default)
- Ingress NGINX with 2 replicas
- Pod disruption budgets configured


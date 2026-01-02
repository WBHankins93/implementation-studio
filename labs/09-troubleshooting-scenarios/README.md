# Lab 09: Troubleshooting Scenarios

## Learning Objectives

By completing this lab, you will:

- Diagnose common deployment failures systematically
- Use diagnostic tools effectively (`kubectl`, logs, events, describe)
- Document and communicate issues clearly
- Build pattern recognition for common problems
- Develop a systematic debugging methodology
- Understand when to escalate vs. resolve independently

## Why This Lab Matters

**This is the final lab in Implementation Studio - completing your troubleshooting skills.**

Real-world deployments fail. The difference between a good engineer and a great one is:
- **Systematic Approach:** Methodical debugging vs. random guessing
- **Pattern Recognition:**** "I've seen this before" vs. starting from scratch
- **Tool Mastery:** Knowing which tool to use when
- **Clear Communication:** Documenting issues effectively for escalation

This lab teaches you to diagnose and resolve the most common deployment issues you'll encounter in customer environments.

## Prerequisites

- `kubectl` installed
- Kind installed (for local cluster)
- Basic understanding of Kubernetes
- Completion of previous labs (recommended)

## Architecture

This lab provides:
- **6 Common Scenarios:** Real-world problems you'll encounter
- **Diagnostic Tools:** Collection of troubleshooting utilities
- **Systematic Methodology:** Step-by-step debugging approach
- **Pattern Recognition:** Learn to identify common issues quickly

## Quick Start

### Setup

```bash
cd labs/09-troubleshooting-scenarios

# Create Kind cluster
kind create cluster --name troubleshooting-lab

# Setup scenarios
./scripts/setup-scenarios.sh
```

### Run a Scenario

```bash
# Create a problem scenario
./scenarios/network-connectivity/simulate.sh

# Diagnose the problem
./diagnostic-tools/connectivity-check.sh

# Follow the scenario guide
cat scenarios/network-connectivity/scenario.md
```

## Scenarios Overview

### 1. Network Connectivity Failures

**Problem:** Pods can't communicate with each other or external services

**What You'll Learn:**
- Diagnose network policy issues
- Check service endpoints
- Verify DNS resolution
- Test connectivity

**Files:**
- `scenarios/network-connectivity/scenario.md`
- `scenarios/network-connectivity/simulate.sh`
- `scenarios/network-connectivity/diagnosis.md`
- `scenarios/network-connectivity/resolution.md`

### 2. Resource Exhaustion

**Problem:** Pods failing due to CPU, memory, or disk constraints

**What You'll Learn:**
- Identify resource constraints
- Check resource quotas
- Diagnose OOMKilled pods
- Resolve resource issues

**Files:**
- `scenarios/resource-exhaustion/scenario.md`
- `scenarios/resource-exhaustion/simulate.sh`
- `scenarios/resource-exhaustion/diagnosis.md`
- `scenarios/resource-exhaustion/resolution.md`

### 3. Permission Denied Errors

**Problem:** Applications failing due to RBAC or file permission issues

**What You'll Learn:**
- Diagnose RBAC issues
- Check service account permissions
- Verify file permissions
- Resolve permission problems

**Files:**
- `scenarios/permission-denied/scenario.md`
- `scenarios/permission-denied/simulate.sh`
- `scenarios/permission-denied/diagnosis.md`
- `scenarios/permission-denied/resolution.md`

### 4. Image Pull Failures

**Problem:** Pods can't pull container images

**What You'll Learn:**
- Diagnose image pull errors
- Check registry access
- Verify image pull secrets
- Resolve authentication issues

**Files:**
- `scenarios/image-pull-failures/scenario.md`
- `scenarios/image-pull-failures/simulate.sh`
- `scenarios/image-pull-failures/diagnosis.md`
- `scenarios/image-pull-failures/resolution.md`

### 5. DNS Resolution Issues

**Problem:** Applications can't resolve DNS names

**What You'll Learn:**
- Diagnose DNS problems
- Check CoreDNS configuration
- Verify service discovery
- Resolve DNS issues

**Files:**
- `scenarios/dns-resolution/scenario.md`
- `scenarios/dns-resolution/simulate.sh`
- `scenarios/dns-resolution/diagnosis.md`
- `scenarios/dns-resolution/resolution.md`

### 6. Certificate/TLS Problems

**Problem:** TLS handshake failures, certificate errors

**What You'll Learn:**
- Diagnose certificate issues
- Check certificate validity
- Verify TLS configuration
- Resolve certificate problems

**Files:**
- `scenarios/certificate-issues/scenario.md`
- `scenarios/certificate-issues/simulate.sh`
- `scenarios/certificate-issues/diagnosis.md`
- `scenarios/certificate-issues/resolution.md`

## Diagnostic Tools

### Available Tools

- **`connectivity-check.sh`**: Test network connectivity
- **`resource-inspector.sh`**: Inspect resource usage
- **`log-collector.sh`**: Collect and analyze logs
- **`cluster-health.sh`**: Overall cluster health check

### Using Diagnostic Tools

```bash
# Run connectivity check
./diagnostic-tools/connectivity-check.sh

# Inspect resources
./diagnostic-tools/resource-inspector.sh

# Collect logs
./diagnostic-tools/log-collector.sh [namespace] [pod-name]

# Check cluster health
./diagnostic-tools/cluster-health.sh
```

## Systematic Debugging Methodology

### Step 1: Observe

**What to Check:**
- Pod status: `kubectl get pods`
- Events: `kubectl get events`
- Logs: `kubectl logs [pod]`
- Describe: `kubectl describe pod [pod]`

### Step 2: Hypothesize

**Questions to Ask:**
- What changed recently?
- What error messages appear?
- What patterns do I see?
- What's the most likely cause?

### Step 3: Investigate

**Investigation Steps:**
- Check relevant resources
- Review logs and events
- Test connectivity
- Verify configuration

### Step 4: Resolve

**Resolution Steps:**
- Apply fix
- Verify resolution
- Document solution
- Update runbooks if needed

## Estimated Time

**Per Scenario:** 30-45 minutes
**All Scenarios:** 2-4 hours

## Estimated Cost

**$0** - Fully local with Kind (no cloud costs)

## Validation

See [VALIDATION-STATUS.md](./VALIDATION-STATUS.md) for validation details.

## Documentation

- [Systematic Debugging](./docs/systematic-debugging.md) - Debugging methodology
- [Common Patterns](./docs/common-patterns.md) - Pattern recognition guide
- [Escalation Guide](./docs/escalation-guide.md) - When and how to escalate
- [Step-by-Step Guide](./docs/step-by-step.md) - Detailed walkthrough
- [Troubleshooting Reference](./docs/troubleshooting-reference.md) - Quick reference

## Scenario Guides

Each scenario includes:
- **scenario.md**: Problem description and symptoms
- **simulate.sh**: Script to create the problem
- **diagnosis.md**: How to diagnose the issue
- **resolution.md**: How to resolve the issue

## Cleanup

To clean up all scenarios:

```bash
./scripts/cleanup-all.sh
```

**Warning:** This will delete the cluster and all resources!

## Next Steps

After completing this lab:

1. Practice scenarios multiple times
2. Build your own diagnostic toolkit
3. Document patterns you encounter
4. Share knowledge with your team
5. Apply systematic debugging to real issues

## Additional Resources

- [Kubernetes Troubleshooting](https://kubernetes.io/docs/tasks/debug/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Debugging Applications](https://kubernetes.io/docs/tasks/debug/debug-application/)

---

**Remember:** Good troubleshooting is systematic. Follow the methodology, use the right tools, and document everything. This lab completes your Implementation Studio journey!


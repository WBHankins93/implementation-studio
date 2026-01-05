# ADR-002: Terraform Selection

## Status
Accepted

## Context

Implementation Studio requires Infrastructure as Code (IaC) tooling to provision cloud resources (GCP, AWS) and manage Kubernetes configurations. The chosen tool must:

1. **Support multiple cloud providers** - GCP and AWS at minimum, with potential for future expansion
2. **Be widely adopted** - Learners should gain skills transferable to real-world projects
3. **Enable modularity** - Support reusable modules for common patterns
4. **Have strong ecosystem** - Rich provider ecosystem, active community, good documentation
5. **Be declarative** - Infrastructure should be defined as code, not scripts
6. **Support state management** - Track infrastructure state for updates and rollbacks
7. **Be cloud-agnostic** - Not tied to a single cloud provider's tooling
8. **Be accessible** - Easy for learners to understand and use

The IaC tool will be used across all labs that provision cloud infrastructure (Labs 01, 03, 04, 07) and will be a core skill taught to learners.

## Decision

We will use **Terraform** (by HashiCorp) as the Infrastructure as Code tool for Implementation Studio.

Terraform is a declarative IaC tool that uses HCL (HashiCorp Configuration Language) to define infrastructure. It will be used to provision all cloud resources (VPCs, Kubernetes clusters, container registries, databases) across GCP and AWS.

## Consequences

### Positive

- **Multi-cloud support** - Native support for GCP, AWS, Azure, and 100+ other providers
- **Industry standard** - Most widely adopted IaC tool, highly transferable skill
- **Strong ecosystem** - Extensive provider ecosystem, active community, rich documentation
- **Declarative syntax** - Infrastructure defined as code, not imperative scripts
- **State management** - Built-in state tracking for infrastructure changes
- **Modularity** - Excellent module system for reusable patterns
- **Plan/Apply workflow** - Preview changes before applying (safety)
- **Mature and stable** - Battle-tested in production environments
- **Version control friendly** - HCL is human-readable and diff-friendly
- **Community modules** - Large registry of reusable modules
- **Provider parity** - Consistent interface across cloud providers
- **Learning value** - Teaches a genuinely useful, industry-standard tool

### Negative

- **HCL learning curve** - Learners must learn HCL syntax (though it's relatively simple)
- **State file management** - Requires careful state file handling (backup, locking)
- **Provider versioning** - Must manage provider versions and compatibility
- **Limited programming constructs** - HCL is less expressive than full programming languages
- **Debugging complexity** - Can be challenging to debug complex configurations
- **Cost** - Terraform Cloud/Enterprise has costs (though open-source is free)

### Neutral

- **HashiCorp owned** - Vendor-controlled (though open-source)
- **HCL syntax** - Domain-specific language, not a general-purpose language
- **State file size** - Can grow large with complex infrastructure

## Alternatives Considered

### Option 1: Pulumi

**Pros:**
- **General-purpose languages** - Use Python, TypeScript, Go, etc. (familiar to developers)
- **Strong typing** - Type safety in TypeScript/Go
- **Better abstractions** - Can create higher-level abstractions with real programming
- **Modern tooling** - Good IDE support, debugging tools
- **State management** - Built-in state management (Pulumi Cloud)
- **Multi-cloud** - Supports multiple cloud providers

**Cons:**
- **Less adoption** - Smaller community than Terraform (though growing)
- **Learning curve** - Must learn Pulumi-specific patterns and SDKs
- **Less mature** - Newer tool, less battle-tested
- **Vendor lock-in** - Pulumi Cloud for state management (though can self-host)
- **Less ecosystem** - Fewer community modules and examples
- **Cost** - Pulumi Cloud has costs for teams
- **Less transferable** - Skills less transferable than Terraform

**Why not chosen:** While Pulumi offers advantages (general-purpose languages, better abstractions), Terraform's industry dominance, larger ecosystem, and higher transferability make it the better choice for a learning platform. Learners will encounter Terraform more frequently in real-world projects.

### Option 2: CloudFormation (AWS) / Deployment Manager (GCP)

**Pros:**
- **Native integration** - Deep integration with respective cloud providers
- **Cloud-specific features** - Access to latest features first
- **No additional tooling** - Built into cloud console
- **Official support** - Supported by cloud providers

**Cons:**
- **Cloud-specific** - CloudFormation only works with AWS, Deployment Manager only with GCP
- **No multi-cloud** - Cannot use same tooling across providers
- **JSON/YAML complexity** - CloudFormation templates can be verbose and complex
- **Less modular** - Weaker module/abstraction capabilities
- **Vendor lock-in** - Tied to specific cloud provider
- **Less transferable** - Skills less applicable across clouds
- **Learning curve** - CloudFormation templates can be difficult to read/maintain

**Why not chosen:** Cloud-specific tools don't support our multi-cloud strategy. Using CloudFormation for AWS and Deployment Manager for GCP would require learners to learn two different tools, reducing transferability and increasing complexity.

### Option 3: Ansible

**Pros:**
- **Agentless** - No agents required on target systems
- **Idempotent** - Can run multiple times safely
- **Flexible** - Can manage infrastructure, configuration, and applications
- **YAML-based** - Human-readable YAML syntax
- **Large ecosystem** - Extensive collection of modules

**Cons:**
- **Imperative model** - Describes "how" to achieve state, not "what" the state should be
- **Less infrastructure-focused** - Better for configuration management than infrastructure provisioning
- **State management** - Weaker state tracking compared to Terraform
- **Multi-cloud support** - Less mature multi-cloud support
- **Learning curve** - Different paradigm (playbooks vs declarative config)
- **Less common for IaC** - More commonly used for configuration management

**Why not chosen:** Ansible is better suited for configuration management and application deployment than infrastructure provisioning. Terraform's declarative model and superior state management make it more appropriate for infrastructure provisioning.

### Option 4: CDK (Cloud Development Kit)

**Pros:**
- **General-purpose languages** - Use TypeScript, Python, Java, etc.
- **Strong typing** - Type safety in TypeScript/Java
- **Better abstractions** - Can create higher-level constructs
- **Cloud provider support** - AWS CDK, CDK for Terraform, CDK for Kubernetes
- **Modern tooling** - Good IDE support

**Cons:**
- **AWS-focused** - AWS CDK is primarily for AWS (though CDKTF exists)
- **Less adoption** - Smaller community than Terraform
- **Complexity** - More complex than declarative IaC tools
- **Learning curve** - Must learn CDK patterns and cloud provider SDKs
- **Less transferable** - Skills less transferable than Terraform
- **CDKTF immaturity** - CDK for Terraform is newer and less mature

**Why not chosen:** While CDK offers advantages (general-purpose languages, better abstractions), Terraform's industry dominance, multi-cloud support, and higher transferability make it the better choice. CDKTF (CDK for Terraform) exists but adds complexity without clear benefits for our use case.

### Option 5: Bicep (Azure)

**Pros:**
- **Azure-native** - Deep integration with Azure
- **Simpler syntax** - More readable than ARM templates
- **Microsoft support** - Official Microsoft tooling

**Cons:**
- **Azure-only** - Only works with Azure
- **No multi-cloud** - Cannot use across GCP/AWS
- **Less adoption** - Smaller community than Terraform
- **Less transferable** - Skills less applicable outside Azure
- **Vendor lock-in** - Tied to Microsoft/Azure

**Why not chosen:** Azure-only tooling doesn't support our multi-cloud strategy. We're not focusing on Azure support (as documented in ADR-003), so Bicep is not relevant.

## Decision Rationale

Terraform was chosen because it best balances all our requirements:

1. **Multi-cloud support** - Native support for GCP, AWS, and 100+ other providers with consistent interface
2. **Industry standard** - Most widely adopted IaC tool, highly transferable skill for learners
3. **Strong ecosystem** - Extensive provider ecosystem, active community, rich documentation
4. **Modularity** - Excellent module system enabling reusable patterns (critical for our module-based architecture)
5. **Declarative model** - Infrastructure defined as desired state, not imperative scripts
6. **State management** - Built-in state tracking for infrastructure changes and rollbacks
7. **Plan/Apply workflow** - Preview changes before applying (safety and transparency)
8. **Mature and stable** - Battle-tested in production environments, reliable
9. **Learning value** - Teaches a genuinely useful, industry-standard tool

The choice prioritizes **transferability and industry adoption** over advanced features (like general-purpose languages in Pulumi/CDK). For a learning platform, it's more valuable to teach tools learners will encounter frequently in real-world projects.

## Implementation

Terraform is used throughout Implementation Studio:

- **Modules** - All infrastructure modules (`modules/gcp/`, `modules/aws/`) are Terraform modules
- **Labs** - Labs 01, 03, 04, 07 use Terraform to provision infrastructure
- **Version constraints** - All modules specify Terraform version requirements (`>= 1.5`)
- **Provider configuration** - Separate provider blocks for GCP and AWS
- **State management** - State files stored locally (for labs) or in remote backends (for production)
- **Validation** - GitHub Actions workflows validate Terraform syntax and formatting

### Module Structure

```
modules/
├── gcp/
│   ├── gke-cluster/
│   │   ├── main.tf          # Terraform resources
│   │   ├── variables.tf     # Input variables
│   │   ├── outputs.tf       # Output values
│   │   └── versions.tf      # Version constraints
│   └── ...
├── aws/
│   ├── eks-cluster/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   └── ...
```

### Lab Usage

Labs use Terraform with conditional module selection:

```hcl
variable "cloud_provider" {
  description = "Cloud provider: gcp or aws"
  type        = string
  validation {
    condition     = contains(["gcp", "aws"], var.cloud_provider)
    error_message = "Cloud provider must be 'gcp' or 'aws'."
  }
}

module "cluster" {
  source = var.cloud_provider == "gcp"
    ? "../../modules/gcp/gke-cluster"
    : "../../modules/aws/eks-cluster"
  # ...
}
```

## References

- [Terraform Documentation](https://www.terraform.io/docs)
- [Terraform Providers](https://registry.terraform.io/browse/providers)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [HashiCorp Configuration Language (HCL)](https://github.com/hashicorp/hcl)

---

**Date:** January 5, 2026  
**Author:** Ben Hankins  
**Status:** Accepted


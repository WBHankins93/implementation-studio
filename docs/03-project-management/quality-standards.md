# Quality Standards

## Code Standards

### Terraform

- Consistent formatting (`terraform fmt`)
- Variables have descriptions and types
- Outputs documented
- README in each module with examples
- Version constraints specified

### Kubernetes Manifests

- Valid against target API version
- Resource requests/limits specified
- Labels consistent across resources
- Namespace-scoped where appropriate
- Security contexts defined

### Shell Scripts

- Shebang and set options (`set -euo pipefail`)
- Functions for reusability
- Error handling
- Usage documentation
- Exit codes properly handled

## Documentation Standards

### Every Lab README Includes

1. Learning objectives (what you'll understand after completing)
2. Prerequisites (tools, knowledge, prior labs)
3. Architecture diagram or description
4. Step-by-step instructions
5. Validation steps (how to verify it worked)
6. Cleanup instructions
7. Troubleshooting section
8. Cost estimate
9. Time estimate

### Writing Style

- Direct and practical
- Explain "why" not just "how"
- Use real-world context
- Acknowledge tradeoffs
- Production-focused, not academic

### Module Documentation

Each module README includes:
- "What is This?" - Component explanation
- "When to Use This Module" - Guidance
- "How It Works" - Diagrams/flowcharts
- Usage examples with multiple scenarios
- Prerequisites and requirements
- Cost considerations
- Security best practices
- Troubleshooting sections
- Related modules and learn more links

## Validation Standards

### Local Validation

- All Kubernetes manifests validated with `kubeval` or `kubectl --dry-run`
- Helm charts validated with `helm template`
- Terraform validated with `terraform validate` and `tflint`
- Scripts tested in clean environments

### Documentation

- VALIDATION-STATUS.md in each lab
- Transparent about what's tested vs. reviewed
- Community validation encouraged

## Review Process

1. Code review for all changes
2. Documentation review for clarity
3. Validation checks pass
4. Examples tested
5. Links verified


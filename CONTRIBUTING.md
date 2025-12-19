# Contributing to Implementation Studio

Thank you for your interest in contributing to Implementation Studio! This document provides guidelines and processes for contributing.

## How to Contribute

### Reporting Issues

If you encounter issues with labs, modules, or documentation:

1. Check existing issues to avoid duplicates
2. Open an issue with:
   - Clear description of the problem
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment details (OS, tools versions)

### Contributing Code

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes following our [Quality Standards](#quality-standards)
4. Test your changes locally
5. Commit with clear messages (`git commit -m 'Add amazing feature'`)
6. Push to your branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Validation Requirements

Before submitting a PR:

- [ ] All Terraform code passes `terraform fmt` and `terraform validate`
- [ ] All Kubernetes manifests validate with `kubeval` or `kubectl apply --dry-run`
- [ ] Shell scripts follow best practices (`set -euo pipefail`)
- [ ] Documentation is updated
- [ ] `VALIDATION-STATUS.md` is updated if applicable

## Quality Standards

### Terraform

- Use `terraform fmt` for consistent formatting
- Variables must have descriptions and types
- Outputs must be documented
- Each module must have a README.md

### Kubernetes Manifests

- Valid against target API versions
- Resource requests/limits specified
- Consistent labels across resources
- Namespace-scoped where appropriate

### Shell Scripts

- Include shebang (`#!/bin/bash`)
- Use `set -euo pipefail`
- Include error handling
- Document usage in comments

### Documentation

- Clear, practical writing
- Explain "why" not just "how"
- Include examples where helpful
- Update `VALIDATION-STATUS.md` for labs

## Lab Contributions

When contributing new labs:

1. Follow the lab structure pattern (see README.md)
2. Include `VALIDATION-STATUS.md` with testing transparency
3. Provide setup, validate, and cleanup scripts
4. Document learning objectives clearly
5. Include troubleshooting section

## Questions?

Open an issue with the `question` label, or reach out to the project maintainer.

---

Thank you for contributing to Implementation Studio!


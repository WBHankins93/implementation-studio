# For Solutions Engineers

## 📝 Context

This repo teaches you **HOW to deploy** in constrained environments (air-gapped, private clusters, firewall-restricted).

For **operational SE guidance** (discovery, scoping, handoff, account strategy), see:
👉 **[SE Playbook](https://github.com/WBHankins93/se-playbook)**

## 🎯 Quick Mapping

**If customer says...**

| Customer Constraint | Start With | SE Playbook Guide |
|---------------------|------------|-------------------|
| "No internet access" | [Lab 02: Air-Gapped](../labs/02-airgapped-deployment/) | [Air-Gapped Environment](https://github.com/WBHankins93/se-playbook/tree/main/environments/air-gapped.md) |
| "Private cluster" | [Lab 03: Private Network](../labs/03-private-network-deployment/) | [Private Cluster Guide](https://github.com/WBHankins93/se-playbook/tree/main/environments/private-cluster.md) |
| "Strict firewall" | [Lab 04: Firewall-Restricted](../labs/04-firewall-restricted-deployment/) | [Firewall-Restricted](https://github.com/WBHankins93/se-playbook/tree/main/environments/restricted-network.md) |
| "Need POC in 1 week" | [Lab 05: POC Sprint](../labs/05-poc-sprint/) | [POC Scoping](https://github.com/WBHankins93/se-playbook/tree/main/pre-sales/poc-scoping.md) |

## 🔄 Your Workflow

1. **Discovery call** (se-playbook) → Identifies constraint
2. **Lab** (implementation-studio) → Practice deployment pattern
3. **Scoping** (se-playbook) → Define customer POC
4. **Lab** (implementation-studio) → Reference during execution
5. **Handoff** (se-playbook) → Operational transition

## 🎯 Lab → Customer Adaptation

Each lab includes "Real-World Application" sections showing how to adapt for production. For customer engagement frameworks (discovery questions, scoping templates, handoff checklists), see the [SE Playbook](https://github.com/WBHankins93/se-playbook).

## 📋 What's Where

**Implementation Studio (this repo):**
- ✅ Deployment patterns and Terraform modules
- ✅ Hands-on labs for constrained environments
- ✅ Technical implementation guides
- ✅ Multi-cloud patterns (GCP, AWS)

**SE Playbook:**
- ✅ Discovery frameworks and questions
- ✅ POC scoping and execution guides
- ✅ Customer handoff processes
- ✅ Account strategy and relationship building
- ✅ Recovery and escalation frameworks

## 🔗 Links

- [SE Playbook - START-HERE](https://github.com/WBHankins93/se-playbook/blob/main/START-HERE.md)
- [Lab 02: Air-Gapped Deployment](../labs/02-airgapped-deployment/)
- [Lab 03: Private Network Deployment](../labs/03-private-network-deployment/)
- [Lab 04: Firewall-Restricted Deployment](../labs/04-firewall-restricted-deployment/)
- [Lab 05: POC Sprint](../labs/05-poc-sprint/)

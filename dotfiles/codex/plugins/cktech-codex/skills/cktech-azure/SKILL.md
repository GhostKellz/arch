---
name: cktech-azure
description: "Use for CKTech Azure operations: Terraform/OpenTofu Azure resources, Azure CLI, subscriptions/resource groups, managed identity, service principals, networking/security groups, VM bootstrap, CI secrets, and monitoring onboarding."
---

# CKTech Azure

- Confirm subscription and resource group before mutations.
- Prefer managed identity where possible; treat service principal secrets as high-value credentials.
- Review NSGs, public IPs, DNS, identity assignments, and cost-impacting SKU/region choices.
- Keep Azure secrets in Key Vault, secret store, or CI variables; never in HCL or notes.
- For VMs, align cloud-init/bootstrap with monitoring and SSH access patterns.

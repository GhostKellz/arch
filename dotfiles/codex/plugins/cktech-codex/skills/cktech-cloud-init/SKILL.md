---
name: cktech-cloud-init
description: Author and review CKTech cloud-init for VM/bootstrap workflows, especially Terraform/OpenTofu and Proxmox templates. Use for user-data, SSH keys, package bootstrap, first boot scripts, and avoiding secrets in provisioning.
---

# CKTech Cloud-Init

- Keep user-data minimal, idempotent, and readable.
- Never embed long-lived secrets in cloud-init.
- Install SSH keys, base packages, users, and service bootstrap only where needed.
- Validate YAML and rendered user-data before provisioning.
- Pair cleanly with Terraform/OpenTofu and Proxmox templates.
- Debug with cloud-init logs and status before reprovisioning.

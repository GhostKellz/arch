---
name: infra-iac
description: Use for Terraform/OpenTofu, Proxmox, Proxmox Backup Server, Ansible, VM/container provisioning, remote state, provider pinning, and infrastructure plan/apply review. Enforce saved-plan discipline and explicit destructive-change review.
---

# Infra / IaC

- Terraform/OpenTofu: `fmt`, `validate`, `plan -out=tf.plan`, review, then `apply tf.plan`.
- Never `apply -auto-approve` outside disposable labs.
- Never destroy without a reviewed destroy plan and explicit user confirmation.
- Treat state as secret-bearing; do not commit or copy state files.
- Terraform provisions; Ansible configures.
- For Proxmox/PBS, inspect current VM/container/storage/backup state before changing it.
- Call out replacements, disks, networks, auth changes, and stateful resources.

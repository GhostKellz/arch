---
name: terraform
description: Author and operate Terraform/OpenTofu safely — module structure, plan/apply discipline, remote state (GitLab-managed HTTP backend), provider pinning, and secret handling — tuned to this stack (Proxmox via bpg/proxmox, GitLab CI). Use when writing or reviewing .tf, planning infrastructure changes, wiring state/backends, or provisioning VMs/containers/cloud resources as code. Triggers: "terraform", "opentofu", ".tf", "provision infra as code", "terraform plan/apply", IaC for Proxmox or the agent-deploy concept.
---

# Terraform / OpenTofu

Infrastructure as code, applied with discipline. House-authored (inspired by
`antonbabenko/terraform-best-practices`), tuned to this stack: state in the
self-hosted GitLab, targets often Proxmox (`bpg/proxmox` provider). Pairs with
Ansible — **Terraform provisions, Ansible configures**.

## The apply discipline (non-negotiable)
```bash
terraform fmt -recursive && terraform validate
terraform plan -out=tf.plan        # ALWAYS a saved, reviewed plan
terraform apply tf.plan            # apply the exact reviewed plan, nothing else
```
- **Never `apply` without reviewing the plan first.** No `-auto-approve` on
  anything that isn't a throwaway lab loop.
- **Never `destroy` without `terraform plan -destroy`** and an explicit confirm of
  what leaves. Targeted destroys (`-target`) are a last resort, not routine.
- Read the plan's `+/-/~` counts out loud before applying; a `-/+` (replace) on a
  stateful resource (disk, DB, VM) is a data-loss flag — stop and check.

## State — remote, locked, sensitive
- Use the **GitLab-managed Terraform state** HTTP backend (self-hosted instance),
  not local state, for anything shared:
  ```hcl
  terraform { backend "http" {} }   # address/lock/unlock + creds via -backend-config / CI
  ```
- State **contains secrets in plaintext** (provider creds, generated passwords).
  Treat the backend as secret-bearing: access-controlled, never committed, never
  copied to the mirror or a scratch file. Enable locking so parallel runs don't
  corrupt it.

## Structure
- Root module thin; real logic in reusable **modules** (`modules/<name>`), called
  with explicit inputs/outputs. Pin module sources to a tag/ref.
- **`for_each` over `count`** for named/keyed resources — `count` reindexes and
  destroys/recreates on list changes; `for_each` is stable by key.
- `variables.tf` (typed, described, validated) + `outputs.tf` + `locals` for
  derived values. Mark secret outputs `sensitive = true`.
- Pin providers in `required_providers` with a `~>` constraint, and **commit
  `.terraform.lock.hcl`** so CI resolves the same versions.

## Secrets — never in .tf or state-by-accident
- No hardcoded credentials in `.tf`. Feed them via `TF_VAR_*` from the keyring
  (see the `secrets` skill) or GitLab **masked + protected** CI/CD variables.
- Mark sensitive variables/outputs `sensitive = true` (keeps them out of logs) —
  but remember state still stores the value, so the backend must be secured.
- The Proxmox provider needs an API token, not root creds — least privilege.

## Provider notes (this stack)
- **Proxmox:** `bpg/proxmox` (actively maintained; prefer over the older
  `telmate/proxmox`). Auth with a scoped API token; define VMs/LXCs, then hand
  off to Ansible for in-guest config. Complements the `proxmox` skill's CLI ops.
- Run in GitLab CI with the plan as an artifact and apply gated on a protected
  branch / manual job (see `rules/ci.md`).

## Verify before done
- `terraform fmt` clean, `terraform validate` passes, `tflint` if the repo uses it.
- Security-scan IaC with `checkov`/`trivy config` for misconfigurations.
- The plan matches intent (no surprise replacements); state backend reachable + locked.

## See also
- `proxmox` — CLI operations on the resources Terraform provisions.
- `secrets` — `TF_VAR_*` from keyring, GitLab CI variables, state sensitivity.
- `rules/ci.md` — running plan/apply in GitLab pipelines.

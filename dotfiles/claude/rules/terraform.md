---
paths:
  - "**/*.tf"
  - "**/*.tfvars"
  - "**/.terraform.lock.hcl"
---

# Terraform / OpenTofu conventions

- **`for_each` over `count`** for named/keyed resources — `count` reindexes and destroys/recreates on list changes; `for_each` is stable by key.
- Pin providers in `required_providers` with a `~>` constraint, and **commit `.terraform.lock.hcl`** so CI resolves the same versions.
- Thin root module; real logic in reusable `modules/<name>` with explicit typed inputs/outputs. Pin module sources to a tag/ref.
- Typed, described, validated `variables.tf` + `outputs.tf` + `locals` for derived values. Mark secret outputs `sensitive = true`.
- **No hardcoded credentials in `.tf`.** Feed them via `TF_VAR_*` from the keyring or masked+protected CI variables (see the `secrets` skill). State stores values in plaintext, so the backend must be access-controlled and locked.
- `terraform fmt -recursive` + `terraform validate` before done; `tflint` and `checkov`/`trivy config` if the repo uses them.
- Proxmox target: `bpg/proxmox` with a scoped API token, not root — Terraform provisions, Ansible configures (don't duplicate in-guest config here; see the `ansible` rule).
- The plan/apply/destroy **workflow** (saved reviewed plan, no `-auto-approve`, `plan -destroy` before any destroy, remote locked state) lives in the `terraform` skill — invoke it for the how-to.

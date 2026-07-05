---
paths:
  - "**/ansible.cfg"
  - "**/playbooks/**/*.yml"
  - "**/playbooks/**/*.yaml"
  - "**/roles/**/tasks/*.yml"
  - "**/inventory/**"
---

# Ansible conventions

- **Idempotent by default.** Use real modules over `command`/`shell`; if you must
  shell out, gate it with `creates:`/`removed:`/`when:` so reruns are no-ops.
- Dry-run before applying to real hosts: `ansible-playbook --check --diff`; then run for real and confirm `changed=` counts make sense.
- `become:` only where needed, scoped per-task/play — not blanket root. Matches the least-privilege `agent` access pattern.
- Secrets live in **ansible-vault** (or pulled from the keyring at runtime), never plaintext in a play, inventory, or `group_vars`. See the `secrets` skill.
- Structure with **roles** (tasks/handlers/defaults/templates); keep inventories per-environment; use `tags:` so subsets can run.
- Handlers for restart-on-change; `notify:` rather than an unconditional restart.
- Pin collections/roles in `requirements.yml`; run `ansible-lint` before done.
- Terraform provisions the host, Ansible configures it — don't duplicate VM/resource creation in Ansible (see the `terraform` skill).

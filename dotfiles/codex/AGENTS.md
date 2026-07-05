# Global Working Agreement (Codex)

Durable defaults for the OpenAI Codex CLI (install to `~/.codex/AGENTS.md`; a
repo-local `AGENTS.md` overrides/extends it). The `##` sections below, down to the
runtime notes, are the **shared core** — kept identical in the Claude
[`CLAUDE.md`](../claude/CLAUDE.md). Codex-specific skill routing,
command-approval/sandbox rules, and access live in the Codex notes at the end.

## Workflow
- Plan any non-trivial task first (3+ steps or an architectural decision); write a short spec to remove ambiguity before editing.
- If evidence contradicts the plan, stop and re-plan rather than pushing forward.
- Keep the working context lean — pull in only what the task needs; watch the budget and compact early.

## Verification before done
- Never mark a task complete without proving it works: run tests, check logs, demonstrate correctness.
- Diff behavior against the baseline (e.g. `main`) when relevant.
- Ask "would a staff engineer approve this?" before presenting work.

## Bug fixing
- Given a bug report or failing CI, fix it directly — point at the logs/errors/failing tests and resolve them without hand-holding.

## Core principles
- Simplicity first: the smallest change that solves the problem; touch only what's necessary. Root cause over band-aid, senior-developer standards, no temporary hacks.
- For non-trivial changes, pause and ask if there's a more elegant approach. Don't over-engineer obvious fixes.
- Comments explain "why," not "what." No static version numbers in comments or docs — they rot; point at the source.
- Follow existing naming/conventions; no `file_v2`/`v1` suffixes.
- Documentation is accurate and concise — never marketing copy.
- Edit with the proper tools; never risk corrupting files with careless `sed`.

## Knowledge stores — reach for the right one
Four stores back the work; route to the correct one instead of freehanding a known workflow:
- **Skills** — repeatable *procedures / reflexes*. Only a skill's name+description are always-on; the body loads on invocation, so reach for a skill instead of improvising. Per-runtime routing table in the notes below.
- **Rules** — path-scoped stack conventions; load when you touch matching files.
- **Reference** — machine/cluster inventory; read on demand when a task targets a specific host.
- **Brain (`~/brain`)** — cross-project declarative knowledge (systems, dev ecosystem, MSP ops, runbooks), queried and never always-on. Use it when you need context **not** already in the current project; do NOT consult it for general coding or things already in-repo.

Capturing new knowledge, one home each: reflex/discipline → a skill (don't duplicate an existing skill, MCP, or brain runbook — encode the reflex and point to the deeper source); a repeatable multi-step procedure you'd do again (~2+ times, or "make this reusable") → propose a skill rather than silently redoing it freehand; correction → `tasks/lessons.md`; deep runbook/facts → brain; path-scoped stack convention → a rule.

## Brain read-order
When you need brain context, escalate in order: (1) `~/brain/wiki/hot.md` (recent, ~500 words); (2) `~/brain/wiki/index.md`; (3) `~/brain/wiki/<domain>/_index.md`; (4) only then individual pages or a search. Access mechanism in the runtime notes below.

## Client secrets & egress guardrail
When a tool or MCP can read secrets or client data (Hudu passwords/assets/docs, the brain private tier), treat what it returns as read-only, in-session context. It must NEVER flow outward: no commits, no push to the public mirror or tracked brain tier, no memory capture, no hand-off to another vendor, no scratch files. Pull the minimum, use it, don't persist it. Secrets rotate — never cache a fetched value for "later"; always fetch fresh. Prefer read-only, scoped access; if unsure whether surfacing a secret is warranted, stop and ask.

## Secrets
- Keyring at runtime (`secret-tool` / `pass`); masked+protected CI/CD variables; never commit or echo secrets. If one is exposed, rotate it. See the secrets skill.

## Clean up after yourself
- HARD RULE — NEVER write to `/tmp` (tmpfs/RAM-backed on this host; scratch there consumes memory and fills swap). No `/tmp/claude`, no `mktemp -d` defaults, nothing under `/tmp`.
- Scratch goes under the project: `./.scratch/` (gitignored) or `mktemp -d -p "$PWD/.scratch"`.
- Remove every scratch/temp/log/build/repro file you create before reporting done; re-list the exact paths to verify. Delete only files you created; never touch system/app state (`systemd-private-*`, sockets, other tools' dirs).

## Task management
- Plan first: write checkable items to `tasks/todo.md`; confirm before implementing. Track progress as you go; add a short review section when done. Capture lessons in `tasks/lessons.md` after corrections.

## Environment
- Primary dev host is Arch Linux; the Proxmox cluster is the secondary test environment. Read the machine/cluster inventory on demand when a task targets a specific host (path in the runtime notes below).

## Codex — runtime notes

**Reach for a skill, don't freehand** (`cktech-codex` skill names):
- Remote host / scp / remote sudo → `cktech-ssh`; general Linux ops → `cktech-linux-ops`; systemd units → `cktech-systemd`; networking → `cktech-networking`; containers → `cktech-containers`
- GitLab → `cktech-gitlab`; GitLab CI / pipelines → `cktech-gitlab-ci`
- IaC → `cktech-infra-iac`; cloud-init → `cktech-cloud-init`; Azure → `cktech-azure`; backup/storage → `cktech-backup-storage`; Wasabi → `cktech-wasabi`; Cloudflare / ACME → `cktech-cloudflare-acme`
- Observability → `cktech-observability` (Loki/syslog-ng → `cktech-loki-syslog-ng`, Wazuh → `cktech-wazuh`, CrowdSec → `cktech-crowdsec`)
- Arch packaging → `cktech-arch-packaging`; AUR audit → `cktech-aur-audit`; authorized pentest → `cktech-pentest-kali`
- Secrets → `cktech-secrets`; client docs → `cktech-hudu`; repo docs → `cktech-repo-docs`; brain → `cktech-brain-obsidian`
- Drift-check this Codex config → `codex-config-audit`
- No Proxmox skill in this set — for Proxmox nodes use `cktech-ssh` + the reference inventory.

**Runtime specifics (command approvals & sandbox):**
- Approve commands at least privilege; never add broad or credential-bearing entries. Prefer the read-only/auto sandbox for exploration; escalate to write/network only for the step that needs it.
- Never `sshpass -p`; use key-based SSH (`ssh -F /dev/null -i <key> -o IdentitiesOnly=yes …`). A plaintext credential in an approval rule is an exposure event — rotate it.
- `~/.codex/rules/`, `auth.json`, SQLite state, logs, sessions, and caches are private runtime state — never mirror them.

**Paths & access:**
- Machine/cluster inventory: `~/.claude/reference/infrastructure.md`.
- Brain: the `cktech-brain-obsidian` skill (or the `obsidian-vault` MCP if wired). Public tier `~/brain/wiki/` (tracked, pushed); private `~/brain/private/` (gitignored, local-only); clients in Hudu.

**Relationship to Claude Code:**
Same standards, different runtime and skill set. Codex runs standalone on its own `cktech-codex` plugin skills **and** is reached from Claude Code via the `codex` plugin for delegation / second-opinion review / rescue. Neither is subordinate; a delegate's output is evidence the driver reconciles.

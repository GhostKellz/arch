# Global Working Agreement

Personal defaults across all projects. The `##` sections below, down to the
runtime notes, are the **shared core** — kept identical in the Codex
[`AGENTS.md`](../codex/AGENTS.md). Runtime-specific skill routing, tooling, and
access live in the Claude Code notes at the end. Stack- and task-specific rules
load on demand from `~/.claude/rules/`; machine details from `~/.claude/reference/`.

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

## Claude Code — runtime notes

**Reach for a skill, don't freehand** (Claude skill names):
- Remote host / scp / remote sudo → `ssh`
- GitLab MR / issue → `gitlab`; watch a pipeline → `gitlab-pipeline-watch`; drive an MR green → `gitlab-babysit-mr`
- Proxmox VM/LXC/PBS → `proxmox`; TLS / Let's Encrypt → `acme`; Cloudflare zone/WAF/cache → `cloudflare`
- Terraform / OpenTofu → `terraform`; client docs → `hudu`; secrets handling → `secrets`
- Commit → `commit`; commit+push+PR → `commit-push-pr`; PR review → `review-pr`
- Adopt a 3rd-party skill/MCP → `skill-audit` FIRST; AUR package → `aur-audit`
- Security review / threat model → `security`; authorized testing → `pentest`
- New repeatable procedure → propose via `skill-creator`
- Docs / office → `repo-docs`, `pdf`, `docx`, `xlsx`; clean web read → `defuddle`; web-app testing → `webapp-testing`

**Runtime specifics:**
- Enter plan mode for non-trivial work; write the spec first.
- Use subagents liberally (Task tool) to keep the main context clean — one focused task each; prefer the Explore agent for open-ended search.
- Watch the context budget — attention degrades past ~40% fill; compact early (~50%).

**Paths & access:**
- Machine/cluster inventory: `~/.claude/reference/infrastructure.md`.
- Brain: `obsidian-vault` MCP (`search_notes` BM25, `read_note`, frontmatter) or `python3 ~/brain/scripts/retrieve.py "question" --top 5`. Public tier `~/brain/wiki/` (tracked, pushed); private `~/brain/private/` (gitignored, local-only); clients in Hudu.

# Global Working Agreement

Personal defaults that apply across all projects. Stack- and task-specific
rules live in `~/.claude/rules/` (loaded on demand when matching files are
touched). Machine/cluster details live in `~/.claude/reference/`.

## Workflow
- Enter plan mode for any non-trivial task (3+ steps or an architectural decision). Write a short spec first to remove ambiguity.
- If something goes sideways, stop and re-plan rather than pushing forward.
- Use subagents liberally to keep the main context clean: offload research, exploration, and parallel analysis. One focused task per subagent.
- Watch the context budget — attention degrades past ~40% fill. Compact early (~50%) to avoid drift.

## Verification before done
- Never mark a task complete without proving it works: run tests, check logs, demonstrate correctness.
- Diff behavior against the baseline (e.g. `main`) when relevant.
- Ask "would a staff engineer approve this?" before presenting work.

## Bug fixing
- Given a bug report or failing CI, fix it directly. Point at the logs/errors/failing tests and resolve them without hand-holding.

## Self-improvement
- After any correction from the user, record the pattern in the project's `tasks/lessons.md` as a rule that prevents the same mistake. Review it at the start of related work.
- Skill-worthiness: when a task is a repeatable, multi-step procedure you'd likely do again (you've done it ~2+ times, or the user says "make this reusable"), *propose* capturing it as a skill via the `skill-creator` skill instead of silently redoing it freehand. Keep proposed skills lean and don't duplicate an existing skill, MCP, or brain runbook — encode the reflex/discipline and point to the deeper source. Split: corrections → `lessons.md`; repeatable procedures → a skill.

## Core principles
- Simplicity first: smallest change that solves the problem; touch only what's necessary.
- Root cause over band-aid: senior-developer standards, no temporary hacks.
- For non-trivial changes, pause and ask if there's a more elegant approach. Skip this for obvious fixes — don't over-engineer.
- Comments explain "why," not "what." No static version numbers in comments or docs.
- Documentation is accurate and concise — never marketing copy.
- Follow naming conventions; never `file_v2`/`v1` suffixes when they don't make sense.
- Test everything testable before calling it done.
- Edit with the proper tools; never risk corrupting files with careless `sed`.

## Clean up after yourself
- HARD RULE — NEVER write to `/tmp`. `/tmp` is tmpfs (RAM-backed, zram swap) on this host; scratch files there consume memory and fill swap. Do not create `/tmp/claude`, `mktemp -d` defaults, or any other file/dir under `/tmp`. No exceptions.
- Scratch dirs go under the project: use `./.scratch/` (gitignored) or `mktemp -d -p "$PWD/.scratch"`. Never `mktemp` with its default `/tmp` location.
- Remove every scratch/temp/log/build/repro file you create before reporting done.
- Verify cleanup happened (re-list the exact paths); don't rely on shell globs. Delete only files you created. Never touch system/app state (`systemd-private-*`, sockets, other tools' dirs).

## Task management
- Plan first: write checkable items to `tasks/todo.md`; confirm before implementing.
- Track progress as you go; add a short review section when done.
- Capture lessons in `tasks/lessons.md` after corrections.

## Knowledge base (brain)
A cross-referenced markdown second brain lives at `~/brain`. One vault: public
content is tracked & pushed to GitHub; private notes live in gitignored `private/`
paths (local-only, never pushed); clients live in Hudu. It covers my systems, dev
ecosystem, MSP ops, and cross-platform notes — queryable, not authoritative.

Access:
- `obsidian-vault` MCP (MCPVault, user scope) exposes `search_notes` (BM25),
  `read_note`, and frontmatter tools — wired for both Claude Code and Codex.
- Local hybrid retrieval (BM25 + ollama `nomic-embed-text` rerank) runs from the
  vault: `python3 ~/brain/scripts/retrieve.py "question" --top 5`.

When you need context not already in the current project:
1. Read `~/brain/wiki/hot.md` first (recent context, ~500 words).
2. If not enough, read `~/brain/wiki/index.md`.
3. For domain specifics, read `~/brain/wiki/<domain or folder>/_index.md`.
4. Only then read individual wiki pages (or use `search_notes`/`retrieve.py`).

Do NOT consult the brain for general coding questions or things already in the
current project. Never commit private/home-lab/security/client content to the
tracked public tier — file it under a gitignored `private/` path in `~/brain`, or
in Hudu for clients.

## Client secrets & Hudu — egress guardrail
When a tool or MCP can read secrets or client data (e.g. a Hudu MCP: passwords,
assets, client documentation), treat what it returns as read-only, in-session
context. It must NEVER flow outward: no commits, no push to the public dotfiles
mirror or tracked brain tier, no memory/mempalace capture, no hand-off to Codex
or other third-party vendors, no scratch files. Pull the minimum needed, use it,
don't persist it. Secrets rotate on a cycle — never cache a fetched value for
"later", always fetch fresh. Prefer read-only, OAuth-scoped access; if unsure
whether surfacing a secret is warranted, stop and ask first.

## Environment
- Primary dev host is Arch Linux; the Proxmox cluster is the secondary test environment.
- Full hardware/VM/cluster inventory: `~/.claude/reference/infrastructure.md` — read it when a task targets a specific machine.

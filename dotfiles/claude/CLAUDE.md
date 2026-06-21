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
- Remove every scratch/temp/log/build/repro file you create before reporting done.
- Prefer a per-task scratch dir (`mktemp -d`) so cleanup is a single `rm -rf`.
- Never treat `/tmp` or any shared dir as a long-lived dump. Delete only files you created — identify each by exact path. Never touch system/app state (`systemd-private-*`, sockets, other tools' dirs).
- Verify cleanup happened (re-list / `find ... -delete`); don't rely on shell globs.

## Task management
- Plan first: write checkable items to `tasks/todo.md`; confirm before implementing.
- Track progress as you go; add a short review section when done.
- Capture lessons in `tasks/lessons.md` after corrections.

## Environment
- Primary dev host is Arch Linux; the Proxmox cluster is the secondary test environment.
- Full hardware/VM/cluster inventory: `~/.claude/reference/infrastructure.md` — read it when a task targets a specific machine.

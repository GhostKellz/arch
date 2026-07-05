---
name: codex-config-audit
description: Audit or update Codex configuration, Agent Skills, plugins, AGENTS.md, MCP entries, approval rules, marketplaces, or install docs. Use for checking whether Codex is up to date, porting Claude skills, cleaning unsafe approvals, or reconciling live ~/.codex with repo/dotfiles sources.
---

# Codex Config Audit

Check:

- `~/.codex/config.toml`
- `~/.codex/rules/default.rules`
- `~/.codex/skills`
- `~/.agents/skills`
- `~/plugins`
- `~/.agents/plugins/marketplace.json`
- `~/.codex/plugins/cache`

Flag plaintext credentials, broad destructive approvals, stale plugin caches, missing marketplace entries, and drift from `/data/projects/skills` or `~/arch/dotfiles/codex`.

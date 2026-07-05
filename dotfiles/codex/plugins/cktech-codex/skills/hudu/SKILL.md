---
name: hudu
description: Connect Claude Code to a self-hosted Hudu MSP documentation instance via MCP and work its data (companies, assets, passwords, articles/KB, procedures) safely. Use when wiring up the Hudu MCP, querying or drafting client documentation, or when a task needs Hudu asset/password/article context. Enforces read-only-egress discipline for the secrets Hudu holds. Instance and transport specifics live in this file; secrets are never stored here.
---

# Hudu (MSP documentation) via MCP

Hudu is the source of truth for client documentation: companies, assets,
passwords, articles / knowledge base, and procedures. This skill is the thin
discipline + wiring layer; the **MCP is the integration** that actually talks to
Hudu. No secrets live in this file — the API key stays in the MCP config /
secret store, and it rotates (see below).

Instance: `your-hudu-instance.example.com`.

## Two transports — do not conflate them
Hudu ships a built-in MCP endpoint at `https://<instance>/mcp`
(Admin → External Apps → MCP, OAuth).

1. **claude.ai / ChatGPT web (Custom Connectors)** — the built-in `/mcp` OAuth
   flow documented in Hudu's support article is for the **web apps**, added under
   Settings → Connectors. It requires a **Claude Organization plan**. This is
   NOT how Claude Code connects — don't follow that guide for the CLI.
2. **Claude Code (this CLI)** — add the MCP yourself:
   - Remote HTTP (same built-in endpoint):
     ```bash
     claude mcp add --transport http hudu https://your-hudu-instance.example.com/mcp
     ```
   - or local stdio server (e.g. a self-hosted Node MCP such as
     `DevSkillsIT/Skills-MCP-Hudu`, a 43-tool HTTP/Node server — an MCP server,
     not a Claude skill):
     ```bash
     claude mcp add hudu-mcp \
       -e HUDU_BASE_URL=https://your-hudu-instance.example.com \
       -e HUDU_API_KEY=... \
       -- node /path/to/hudu-mcp/entry.js
     ```
   Prefer read-only / least-privilege API scopes. Verify with `claude mcp list`.

## Egress guardrail (hard rule)
Hudu returns secrets and client data. Everything it returns is **read-only,
in-session context**. It must NEVER flow outward:
- no commits, no push to the public dotfiles mirror or the tracked brain tier;
- no memory / mempalace capture; no hand-off to Codex or other third-party
  vendors; no scratch files, no logs.
- Pull the **minimum** needed, use it, don't persist it.
If unsure whether surfacing a password/secret is warranted, stop and ask first.
(This mirrors the global guardrail in `~/.claude/CLAUDE.md`.)

## Secret rotation reality
Secrets/passwords rotate every few months. Consequences:
- Never cache a fetched value for "later" — always fetch fresh from Hudu.
- If the MCP key stops authenticating, assume it rotated: pull the current key
  from the secret store (`pass` / `secret-tool`) and update the MCP config; do
  not paste keys into this file, into git, or into chat history.

## Working the data (MSP discipline)
- **Search before create.** Companies, assets, and articles are easy to
  duplicate. Query first (by company, asset type, article title) and reuse the
  existing record.
- Scope every query to the right **company** — never leak one client's data into
  another's context or docs.
- New SOPs / KB → create as **drafts** for human review, don't auto-publish.
- Keep asset/field naming consistent with the existing Hudu layout; match the
  instance's conventions rather than inventing new ones.
- Read-heavy by default: prefer lookups and summaries; make writes only when
  explicitly asked, and confirm the target company + record first.

## Quick reference
| Task | Path |
|------|------|
| Add MCP (Claude Code, HTTP) | `claude mcp add --transport http hudu https://your-hudu-instance.example.com/mcp` |
| List / verify MCPs | `claude mcp list` |
| Built-in web connector | claude.ai/ChatGPT only (Org plan) — not Claude Code |
| API key storage | secret store (`pass`/`secret-tool`) — never this file, never git |
| Rotation | key rotates periodically; fetch fresh, update MCP config |

---
name: cktech-brain-obsidian
description: Use the CKTech Obsidian brain from Codex. Trigger when the user asks to query, save to, ingest into, or reason from the brain/wiki/Obsidian vault; mentions brain.ckelley.dev, Quartz, public/private brain tiers, wiki/hot.md, wiki/index.md, Obsidian MCP, or notes/cheatsheets. Enforces the public wiki vs private local tier vs Hudu client-confidential boundary.
---

# CKTech Brain / Obsidian

## Model

The Obsidian brain is the local vault and public knowledge base source.

Tiers:

- **Public tracked tier:** public wiki folder
  - Published through Quartz at `https://brain.ckelley.dev`.
  - Treat anything committed here as public.
  - Holds generalized cheatsheets, references, concepts, entities, and public-safe project notes.
- **Private local tier:** gitignored private folder
  - Gitignored and local-only.
  - Holds personal/home-lab/security details that should not publish.
- **Client-confidential tier:** Hudu at `hudu.cktechx.com`
  - Client documentation, client secrets, runbooks, assets, topologies, tenant details.
  - Do not copy client-specific facts into the public brain.

## Read Order

When using the brain for context:

1. Read the public wiki hot-cache note for recent context.
2. Read the public wiki index if more context is needed.
3. Read relevant pages under `wiki/domains/`, `wiki/references/`, `wiki/concepts/`, or `wiki/entities/`.
4. Read `~/brain/private/` only when the task is clearly local/private and not destined for publication.

Do not read the brain for ordinary repo-local coding facts already present in the current project.

## Writing Notes

Before writing, decide the tier:

- Public-safe generalized knowledge -> public wiki.
- Personal/home-lab/security/internal details -> private local tier.
- Client-specific documentation or secrets -> Hudu, not the brain repo.

Use Obsidian-style wikilinks: `[[Page Name]]`.

Prefer existing schema and folders:

- `wiki/concepts/` for ideas and patterns.
- `wiki/references/` for runbooks and how-tos.
- `wiki/entities/` for projects, tools, orgs, and systems.
- `wiki/domains/` for top-level topic hubs.
- `wiki/sources/` for source summaries.

## Public Leak Guard

Never put these in the public wiki:

- client names or identifiers unless already public marketing content,
- private hostnames, internal IPs, topology, VPN/tailnet details,
- credentials, keys, tokens, tenant IDs, OAuth secrets,
- Hudu-sourced client runbooks or asset configs,
- exploit details that should remain private,
- anything marked `tier: private`.

If generalizing from private/Hudu material, write only the reusable pattern and remove identifiers.

## MCP / Tools

Use the configured Obsidian/filesystem MCP when available. If MCP is unavailable, filesystem reads/writes are acceptable in the local vault, but preserve the tier boundary.

The public Quartz deployment builds only the public wiki tier. Keep private content structurally outside that path.

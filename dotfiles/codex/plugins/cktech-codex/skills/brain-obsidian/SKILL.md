---
name: brain-obsidian
description: Use the Obsidian brain/second-brain. Trigger when querying, saving to, ingesting into, or reasoning from the brain/wiki/Obsidian vault; mentions brain.example.com, Quartz, public/private brain tiers, wiki/hot.md, wiki/index.md, Obsidian MCP, notes, or cheatsheets. Enforces public wiki vs private local tier vs Hudu client-confidential boundary.
---

# Brain / Obsidian

Tiers:

- Public tracked tier: `~/brain/wiki/`, published at `https://brain.example.com`.
- Private local tier: `~/brain/private/`, gitignored and local-only.
- Client-confidential tier: Hudu at `your-hudu-instance.example.com`.

Read order: `wiki/hot.md` -> `wiki/index.md` -> relevant domain/reference/concept/entity pages.

Before writing, decide the tier. Public-safe generalized knowledge goes to `wiki/`; personal/home-lab/security details go to `private/`; client docs/secrets go to Hudu.

Never put client identifiers, private topology, internal IPs, credentials, Hudu-sourced runbooks, or `tier: private` content in the public `wiki/`.

Use Obsidian wikilinks and the existing schema. Prefer the `obsidian-vault` MCP when available; direct filesystem access is acceptable locally as long as the tier boundary is preserved.

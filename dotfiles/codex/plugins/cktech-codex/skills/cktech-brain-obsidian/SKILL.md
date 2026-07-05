---
name: cktech-brain-obsidian
description: Use the CKTech Obsidian brain from Codex. Trigger when querying, saving to, ingesting into, or reasoning from the brain/wiki/Obsidian vault; mentions brain.ckelley.dev, Quartz, public/private brain tiers, wiki/hot.md, wiki/index.md, Obsidian MCP, notes, or cheatsheets. Enforces public wiki vs private local tier vs Hudu client-confidential boundary.
---

# CKTech Brain / Obsidian

Tiers:

- Public tracked tier: the Obsidian public wiki, published at `https://brain.ckelley.dev`.
- Private local tier: the gitignored private Obsidian area, local-only.
- Client-confidential tier: Hudu at `hudu.cktechx.com`.

Read order: `wiki/hot.md` -> `wiki/index.md` -> relevant domain/reference/concept/entity pages.

Before writing, decide tier. Public-safe generalized knowledge goes to the public wiki; personal/home-lab/security details go to the private local tier; client docs/secrets go to Hudu.

Never put client identifiers, private topology, internal IPs, credentials, Hudu-sourced runbooks, or `tier: private` content in public `wiki/`.

Use Obsidian wikilinks and existing schema. Use MCP when available; filesystem access is acceptable locally if the tier boundary is preserved.

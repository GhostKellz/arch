---
name: cktech-repo-docs
description: Create or maintain CKTech repository documentation. Use for README, docs indexes, changelogs, release notes, packaging docs, advisories, issue templates, architecture diagrams, and repo metadata. Keep docs accurate, concise, linked, and synchronized with code/manifests.
---

# CKTech Repo Docs

- Root stays clean: README, CONTRIBUTING, SECURITY, CHANGELOG, LICENSE, minimal config.
- `docs/README.md` is the navigation hub.
- Use lowercase kebab-case filenames.
- Mermaid diagrams should document real architecture/flows, not decoration.
- Version source of truth is the manifest; sync changelog and packaging on bumps.
- Track advisories under `docs/advisories/` with rationale and verification.

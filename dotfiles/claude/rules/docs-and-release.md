---
paths:
  - "**/*.md"
  - "**/CHANGELOG.md"
  - "**/packaging/**"
  - "**/release/**"
  - "**/Cargo.toml"
  - "**/build.zig.zon"
  - "**/package.json"
---

# Documentation, packaging & release conventions

## Repository root
- Keep the root clean: `README.md`, `CONTRIBUTING.md`, `SECURITY.md`, `CHANGELOG.md`, `LICENSE`.
- README order: logo/title → badges → short overview → features → quick start → configuration → links to `docs/` → license/acknowledgments. Professional and accurate, never marketing copy. Put risk warnings up front when relevant.

## docs/ layout
- `docs/README.md` is the single navigation hub/index — the only `README.md` inside `docs/`.
- Organize by topic/subsystem in subfolders (e.g. `getting-started/`, `guides/`, `reference/`, `internals/`). Give each folder an `overview.md` landing page.
- Lowercase kebab-case filenames; no version suffixes (`file_v2`).
- `docs/` holds deep dives; the root README stays quick-start-focused. Cross-link instead of duplicating.

## Diagrams
- Use Mermaid for architecture/flows/sequences (fenced ` ```mermaid ` blocks), placed early in the doc and paired with a short "Reading the diagram" note.
- Standardize colors/fonts with an `%%{init: ...}%%` theme block when a project calls for it.
- Use tables or code blocks instead when a diagram wouldn't add clarity.

## Versioning & changelog
- Single source of truth in the manifest: workspace `Cargo.toml` / `build.zig.zon` / `package.json`. Never hardcode versions in source or comments.
- `CHANGELOG.md` follows Keep a Changelog + SemVer: dated, grouped (Added/Changed/Fixed/Security/…), user-focused entries.

## Packaging — prevent stale drift
- On EVERY version bump, re-sync packaging so it never drifts from the manifest/changelog:
  - Per-distro files under `release/` (Arch `PKGBUILD` + `.SRCINFO`, Debian `control`/`changelog`, Fedora `.spec`, etc.) and any `packaging/` metadata.
  - Bump pkgver/version plus any baseline requirements (driver/toolchain minimums) to match.
- After updating docs or packaging, check for drift: versions, commands, flags, and file references must match current code.
- Release flow: bump manifest version → update `CHANGELOG.md` → sync packaging → tag → CI builds/publishes.

## Commits
- Conventional Commits: `type(scope): description` (feat, fix, docs, refactor, test, chore). One logical change per commit; no secrets or build artifacts.

## SECURITY.md / CONTRIBUTING.md
- SECURITY.md: private reporting (no public issues), supported-versions table, security practices, dependency auditing (`cargo audit` / `cargo deny`), hardening checklist.
- CONTRIBUTING.md: dev setup, code style (fmt + lint `-D warnings`), Conventional Commits, PR/test process, release steps, project structure.

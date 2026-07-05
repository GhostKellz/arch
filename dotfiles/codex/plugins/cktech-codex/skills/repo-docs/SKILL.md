---
name: repo-docs
description: Author or standardize repository documentation to a fixed house style — colorful shields.io tech-stack badges (language, key deps, frameworks; NEVER CI/build/project-status), a single docs/README.md index (never scattered READMEs), docs/advisories/ security tracking, Mermaid diagrams of the real architecture/flows, YAML-form issue templates, and grouped dependabot.yml. Use when writing or cleaning up a README, setting up or reorganizing a docs/ folder, adding badges or mermaid diagrams, or scaffolding .github/ issue templates + dependabot for a project.
---

# Repo documentation (house style)

Reproduce the documentation conventions used consistently across these projects
(nexus, strix, zqlite, nvcontrol, ghostctl, archon, citadel, aventra). The goal is
clean, extensive, navigable docs — never a sprawl of half-written markdown.

Bulky copy-paste templates live beside this file:
- `badges.md` — shields.io colour palette + badge-block templates.
- `github-meta.md` — issue-template YAML, `config.yml`, and `dependabot.yml`.

## Non-negotiable rules
1. **Badges = tech, not status.** Badges represent the **language, important
   dependencies, tech stack, and frameworks** only. NEVER add CI/build,
   coverage, project-status, "maintained", or download-count badges. (Optional:
   one license badge, and feature/quality tags in a *second* block.)
2. **ONE `docs/README.md` index — no other README.md anywhere under `docs/`.**
   The single `docs/README.md` is the navigation hub. Do NOT create
   `docs/<folder>/README.md`. This is the most-repeated failure: given "clean
   folder structure" the reflex is to make folders each with their own
   `README.md` — that is exactly wrong here. A `docs/` folder that needs an
   overview gets a lowercase descriptive file (`overview.md`), never a `README.md`.
   Verified against strix: the ONLY `README.md` under `docs/` is `docs/README.md`;
   every other doc is `lowercase-hyphen.md`. README.md is allowed *only* as a
   directory entry point at the repo root and, if present, at the root of a
   top-level operational dir (`deploy/`, `release/`, `packaging/`) — never nested
   through `docs/`.
3. **Mermaid documents the real code.** Every architecture/flow doc carries
   diagrams of what the code actually does (data flow, request lifecycle, module
   deps, state machines) — not decoration.
4. **`docs/advisories/` is standard.** `accepted.md` + `resolved.md` track
   security/dependency advisories with rationale and verification evidence.
5. **Lowercase, descriptive filenames — no sprawl.** Every doc is
   `lowercase-hyphen.md` named for its content (`architecture.md`,
   `email-pipeline.md`, `sso-oidc.md`), one concept per file, hyperlinked from
   the index. Extensive but clean — never a pile of stubs, never a `README.md`
   in a subfolder, never `Docs.md`/`ReadMe.md`/CamelCase.

## README structure
Order: centered logo → `# Title` (centered) → tagline → **badge block(s)** →
`---` → optional status/PoC warning → Overview/Why → Features → Quick Start /
Install → Configuration → Architecture (or Project Structure) → Documentation
(link to `docs/`) → Contributing → Security → License → footer tagline.

Badges go in `<p align="center">` wrappers, `style=for-the-badge`,
`logoColor=white`, brand-hex colours, 6–9 per block. Optional second block for
libraries (chi, pgx, sqlc…), quality tags (Memory Safe, Zero Deps), or license.
See `badges.md` for the palette and the exact block to copy. Emoji-prefixed H2s
are an optional per-project flourish (ghostctl/archon use them) — match the
repo's existing style; don't impose it.

## Canonical docs/ layout
```
docs/
├── README.md              # THE index (1–3 mermaid diagrams; links every section)
├── advisories/
│   ├── triage.md          # (optional) triage-workflow flowchart + scan commands
│   ├── accepted.md        # known/accepted risks + rationale (ties to deny.toml/CI gate)
│   ├── resolved.md        # fixed advisories + verification evidence
│   └── vX.Y.Z-notes.md    # (optional) release/hotfix-specific evidence
├── getting-started/       # quickstart.md, installation.md|building.md, configuration.md, docker.md…
├── guides/                # feature & integration how-tos (one concept per file)
├── reference/             # api.md / cli.md / *-compatibility.md
└── internals/             # architecture.md (2–4 diagrams) + flow/design docs
```
Add domain folders only when warranted (`security/`, `project/`, `experimental/`,
`platforms/`, `hardware/`, `drivers/`…). Databases/libs may swap `advisories/`
for a root `SECURITY.md` — but prefer `advisories/` for app/server projects.

## docs/README.md index pattern
`# <Project> Documentation` + one-line description, then intent-ordered link
sections (Getting Started → Guides → Reference → Internals → Security/Advisories),
each link annotated with a short " - what it covers". Add a **Quick Links** table
(ports/services/commands) when useful. Embed 1–3 mermaid diagrams:
- a **flowchart TD** "documentation map" (routes a reader by role/task),
- a **flowchart LR** "runtime shape" (entrypoint → routers → backends),
- optionally a **flowchart TD** decision tree.

## Mermaid conventions
GitHub renders these — stick to them:

| Type | Use for |
|------|---------|
| `flowchart TD` | doc map, decision trees, scope, routing |
| `flowchart LR` | runtime shape, data flow, component/module deps |
| `sequenceDiagram` | protocol/interaction flows (auth, query, sync, probe) |
| `stateDiagram-v2` | lifecycles / state machines |
| `erDiagram` | data-model relationships |

`docs/internals/architecture.md` carries 2–4 diagrams (system overview + key
flows). Keep node labels short; verify the fence is ```` ```mermaid ````.

## docs/advisories/
- `accepted.md`: table of Advisory ID · crate/pkg · severity · source chain ·
  rationale · review date. Should mirror `deny.toml`/CI allowlist.
- `resolved.md`: table of advisory · pkg · issue · resolved-by (version/commit) ·
  date · verification (`cargo audit`/`cargo deny`/`npm audit`/`govulncheck`).
- Optional `triage.md` (not `README.md`): triage flowchart (signal → triage →
  blocker? → hotfix or accept → verify → resolved) + the scan commands for the stack.
- Optional `vX.Y.Z-notes.md` for release-critical hotfix evidence.

## .github/ meta — copy from `github-meta.md`
- **Issue templates** = modern YAML **form schema** (`ISSUE_TEMPLATE/*.yml` with
  `name/description/title/labels/body` form fields), not legacy markdown.
  Ship `bug_report.yml` (summary, repro, expected/actual, version, env inputs,
  a domain `dropdown`, diagnostics) + `feature_request.yml` (problem, proposal,
  context, alternatives) + `config.yml` (`blank_issues_enabled: true` +
  one `contact_links` entry to the support/diagnostics doc).
- **dependabot.yml**: `version: 2`, one `updates` entry per ecosystem present
  (`cargo`, `github-actions`, `gomod`, `npm`, `docker`), `interval: weekly`,
  named `groups`, and **`update-types: [minor, patch]` only — major is reviewed
  manually.** Always include a `github-actions` entry (pins deprecated actions).
  This is the step routinely forgotten — add it whenever a repo has CI.
- **SECURITY.md**: reporting (no public issues), supported-versions table,
  privilege matrix, audit command. **CONTRIBUTING.md**: workflow, fmt/clippy,
  Conventional Commits. No `PULL_REQUEST_TEMPLATE.md`/`CODEOWNERS` unless asked.

## Definition of done
- [ ] README badges are tech-only (no CI/status), for-the-badge, correct brand colours.
- [ ] Exactly one `docs/README.md` index; every doc linked from it; no stub sprawl.
- [ ] No `README.md` inside any `docs/` subfolder; all docs are `lowercase-hyphen.md`.
- [ ] `internals/architecture.md` has ≥2 accurate mermaid diagrams; index has ≥1.
- [ ] `advisories/{accepted,resolved}.md` present (or a justified `SECURITY.md`).
- [ ] `.github/` has YAML-form issue templates + `config.yml` + `dependabot.yml`
      (with a `github-actions` group, minor+patch only).
- [ ] All mermaid fences render on GitHub; all internal links resolve.

# build-repo.zsh

Interactive bootstrapper for **GhostKellz** (personal) GitHub repositories.
Scaffolds a new project locally with license, gitlab-style README, docs, security
policy, and advisory tracking, then creates the remote repo via the GitHub CLI,
pushes `main`, and enables Dependabot.

## Overview

Prompts for repo name, one-line description, language, license, and an optional
Actions stub, then:

- Builds a full local scaffold under `/data/projects/<repo>`
- Sets the **GitHub repo description** to the same one-line description used in the README
- Initializes git, creates the remote repo under `GhostKellz` (public), and pushes `main`
- Enables Dependabot vulnerability alerts and automated security fixes

**Script location:** `/data/scripts/build-repo.zsh` (backup/sync copy here in `~/arch/scripts`)
**Alias:** `ghostkellz` (see `~/.zshrc.d/repo-scripts.zsh`)
**Owner:** `GhostKellz`
**Base dir:** `/data/projects/<repo>`
**Visibility:** public (fixed)

## Dependencies

- `zsh`
- `git`
- `gh` (GitHub CLI, authenticated: `gh auth login`)
- Language toolchains when initializing (`cargo`, `go`, etc.)
- `/data/scripts/APACHE2.0-LICENSE` (only when choosing the Apache license)

## Interactive Prompts

1. **Repo name**
2. **One-line description** — used in the README (title + Overview) *and* the GitHub repo description
3. **Language** — `rust` / `go` / `zig` / `python` / `js` / `node` / `bun` / `none`
4. **License** — `mit` / `apache` (defaults to MIT); drives the README badge/label
5. **Actions workflow stub?** — `y`/`n` (creates empty `.github/workflows/main.yml`)

## What It Generates

- `LICENSE` — MIT inline, or a copy of `APACHE2.0-LICENSE` for Apache
- `.gitignore` — language section plus a shared scratch/editor block (`tasks/`, `CLAUDE.md`, `archive/`, editor/OS)
- `README.md` — centered title, description, shields.io License badge, Overview/Status/Quick Start/Documentation/Contributing/Security/License
- `CONTRIBUTING.md`, `SECURITY.md` (GitHub private vulnerability reporting)
- `docs/` — `README.md` (mermaid map), `development/roadmap.md`, `advisories/{README,dependencies,accepted,resolved}.md`
- `tasks/todo.md` — created locally but **gitignored** (scratch/planning only)

## Description & License Handling

The one-line description entered at prompt #2 is substituted into the README via
`render` (`__DESCRIPTION__` in the title block and Overview) and passed as
`--description` to `gh repo create`. The chosen license drives `__LICENSE_LABEL__`
(README footer) and `__LICENSE_BADGE__` (shields.io badge), so an Apache project
renders an Apache badge/label rather than always MIT.

## Post-Create Actions

- Remote is switched to SSH (`git@github.com:GhostKellz/<repo>.git`)
- Dependabot alerts: `gh api -X PUT repos/GhostKellz/<repo>/vulnerability-alerts`
- Dependabot fixes: `gh api -X PUT repos/GhostKellz/<repo>/automated-security-fixes`

## Setting Description On An Existing Repo

```bash
gh repo edit GhostKellz/<repo> --description "Your one-line description."
```

## Manual Execution

```bash
ghostkellz         # alias
/data/scripts/build-repo.zsh
```

## Troubleshooting

**`gh` not authenticated:** run `gh auth login`.

**Directory already exists:** the script `mkdir`s `/data/projects/<repo>`; remove
or rename an existing path first.

**Apache license missing:** ensure `/data/scripts/APACHE2.0-LICENSE` exists, or
choose MIT.

## Related

- `cktechrepit.sh` / `cktechrepit.md` — same scaffold for the **CK-Technology** GitHub org
- `gitlab.sh` / `gitlab.md` — same scaffold for self-hosted GitLab

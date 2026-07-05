# cktechrepit.sh

Interactive bootstrapper for **CK-Technology** GitHub org repositories. Scaffolds
a new project locally with license, gitlab-style README, docs, security policy,
and advisory tracking, then creates the remote repo via the GitHub CLI, pushes
`main`, and enables Dependabot.

## Overview

Prompts for repo name, one-line description, language, visibility, topics, and an
optional Actions stub, then:

- Builds a full local scaffold under `/data/projects/<repo>`
- Sets the **GitHub repo description** to the same one-line description used in the README
- Initializes git, creates the remote repo under `CK-Technology`, and pushes `main`
- Enables Dependabot vulnerability alerts and automated security fixes

**Script location:** `/data/scripts/cktechrepit.sh` (backup/sync copy here in `~/arch/scripts`)
**Alias:** `cktech` (see `~/.zshrc.d/repo-scripts.zsh`)
**Owner/org:** `CK-Technology`
**Base dir:** `/data/projects/<repo>`
**License:** MIT (fixed)

## Dependencies

- `zsh`
- `git`
- `gh` (GitHub CLI, authenticated: `gh auth login`)
- Language toolchains when initializing (`cargo`, `go`, etc.)

## Interactive Prompts

1. **Repo name**
2. **One-line description** — used in the README (title + Overview) *and* the GitHub repo description
3. **Language** — `rust` / `go` / `zig` / `python` / `js` / `node` / `bun` / `none`
4. **Private?** — `y`/`n` (sets `--private` / `--public`)
5. **Topics** — space-separated, optional (applied via `gh repo edit --add-topic`)
6. **Actions workflow stub?** — `y`/`n` (creates empty `.github/workflows/main.yml`)

## What It Generates

- `LICENSE` — MIT
- `.gitignore` — language section plus a shared scratch/editor block (`tasks/`, `CLAUDE.md`, `archive/`, editor/OS)
- `README.md` — centered title, description, shields.io License badge, Overview/Status/Quick Start/Documentation/Contributing/Security/License
- `CONTRIBUTING.md`, `SECURITY.md` (GitHub private vulnerability reporting)
- `docs/` — `README.md` (mermaid map), `development/roadmap.md`, `advisories/{README,dependencies,accepted,resolved}.md`
- `tasks/todo.md` — created locally but **gitignored** (scratch/planning only)

## Description Handling

The one-line description entered at prompt #2 is substituted into the README via
`render` (`__DESCRIPTION__` in the title block and Overview) and passed as
`--description` to `gh repo create`, so the GitHub repo page shows the same text
without a manual edit.

## Post-Create Actions

- Remote is switched to SSH (`git@github.com:CK-Technology/<repo>.git`)
- Dependabot alerts: `gh api -X PUT repos/CK-Technology/<repo>/vulnerability-alerts`
- Dependabot fixes: `gh api -X PUT repos/CK-Technology/<repo>/automated-security-fixes`
- Topics applied if provided

## Setting Description On An Existing Repo

```bash
gh repo edit CK-Technology/<repo> --description "Your one-line description."
```

## Manual Execution

```bash
cktech            # alias
/data/scripts/cktechrepit.sh
```

## Troubleshooting

**`gh` not authenticated:** run `gh auth login`.

**Directory already exists:** the script `mkdir`s `/data/projects/<repo>`; remove
or rename an existing path first.

**Repo not created under the org:** confirm your `gh` account has create rights on
`CK-Technology`.

## Related

- `build-repo.zsh` / `build-repo.md` — same scaffold for the personal **GhostKellz** GitHub account
- `gitlab.sh` / `gitlab.md` — same scaffold for self-hosted GitLab

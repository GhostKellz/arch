# gitlab.sh

Interactive bootstrapper for CK Technology GitLab repositories. Scaffolds a
new project locally with license, docs, security policy, advisory tracking, and
language-aware initialization, then creates the remote project via the GitLab
API and pushes the initial commit.

## Overview

Prompts for repo name, description, language, license, visibility, CI, and
topics, then:

- Builds a full local scaffold under `$BASE_DIR/<repo>`
- Initializes git, commits, creates the remote GitLab project, and pushes `main`
- Sets the GitLab **project description** to the same one-line description used
  in the README

**Script location:** `/data/scripts/gitlab.sh` (backup/sync copy here in `~/arch/scripts`)
**Default base dir:** `/data/projects/<repo>`
**Default host:** `git.cktechx.com`

## Dependencies

- `zsh`
- `git`
- `curl`
- `jq`
- `secret-tool` (libsecret) for token lookup
- Language toolchains when initializing: `cargo`, `go`, etc.

## Authentication

The GitLab personal access token is read from the keyring:

```bash
secret-tool store --label='GitLab CK-Arch' service gitlab account ck-arch
```

Or override via the `GITLAB_TOKEN` environment variable. The token needs `api`
scope to create projects.

## Environment Overrides

| Variable | Default | Purpose |
|----------|---------|---------|
| `GITLAB_TOKEN` | keyring lookup | Personal access token for project creation |
| `GITLAB_HOST` | `git.cktechx.com` | GitLab host |
| `GITLAB_NAMESPACE` | _(none)_ | Numeric `namespace_id` for a GitLab group |
| `BASE_DIR` | `/data/projects` | Local parent dir for the new repo |

## Interactive Prompts

1. **Repo name** — lowercased; refuses to overwrite an existing path
2. **One-line description** — used in the README *and* the GitLab project description
3. **Language** — `rust` / `go` / `zig` / `python` / `js` / `node` / `bun` / `none`
4. **License** — `mit` / `apache` / `proprietary` / `fsl` (defaults to `mit`)
5. **Private?** — `y`/`n` (sets project visibility)
6. **GitLab CI stub?** — `y`/`n`
7. **Topics** — comma-separated, optional

## How It Works

1. Reads config and prompts for project details
2. Creates `$BASE_DIR/<repo>` (aborts if it already exists)
3. `write_license` — writes `LICENSE` from the chosen template
4. `write_gitignore` — language-specific ignores plus a shared scratch/editor block (`tasks/`, `.env`, `archive/`, `CLAUDE.md`, editor/OS files)
5. `initialize_language` — language scaffold (e.g. `cargo init`, `go mod init`, `pyproject.toml`)
6. `write_docs` — `README.md`, `docs/` tree, `CONTRIBUTING.md`, `SECURITY.md`, advisory records, and a local-only `tasks/todo.md`
7. `write_ci` — optional `.gitlab-ci.yml` stub
8. `git init` / commit / create remote project via API / `git push -u origin main`

## Local vs Tracked

- `tasks/` is created locally but **gitignored** — scratch/planning only, never pushed
- `.env*` (except `.env.example`), `archive/`, `CLAUDE.md`, and editor/OS files are ignored

## Description Handling

The one-line description entered at prompt #2 is substituted into the README
(title block + Overview) via the `render` helper, and is also sent as the
`description` field in the project-creation API payload — so the GitLab project
page shows the same description without a manual Settings edit.

## Setting Description On An Existing Repo

If a repo predates the description-in-payload change:

```bash
TOKEN="$(secret-tool lookup service gitlab account ck-arch)"
curl -fsS --request PUT \
  --header "PRIVATE-TOKEN: $TOKEN" \
  --data-urlencode "description=Your one-line description." \
  "https://git.cktechx.com/api/v4/projects/<namespace>%2F<repo>"
```

## Manual Execution

```bash
/data/scripts/gitlab.sh
```

## Troubleshooting

**No token error:**
- Store the token: `secret-tool store --label='GitLab CK-Arch' service gitlab account ck-arch`

**"Refusing to overwrite existing path":**
- `$BASE_DIR/<repo>` already exists; remove it or choose another name

**GitLab did not return an SSH URL:**
- The API response is printed to stderr; usually a token scope/permission or
  namespace issue

**Project created in wrong namespace:**
- Set `GITLAB_NAMESPACE` to the numeric group `namespace_id`

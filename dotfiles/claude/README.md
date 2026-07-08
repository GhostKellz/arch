# Claude Code configuration

Personal Claude Code setup, mirrored from `~/.claude/`. Covers global
instructions, on-demand rules, machine reference, and the installed
plugins / skills / MCP servers.

## Layout

```
claude/
├── CLAUDE.md              # Global working agreement (loaded every session)
├── settings.json          # Model + ccusage status line + enabled plugins
├── .gitignore             # Excludes ephemeral/machine-local Claude state
├── rules/                 # Path-scoped rules, loaded ONLY when matching files are touched
│   ├── rust.md            #   *.rs, Cargo.toml
│   ├── zig.md             #   *.zig, build.zig.zon
│   ├── go.md              #   *.go, go.mod, go.sum
│   ├── python.md          #   *.py, pyproject.toml, requirements*.txt
│   ├── nix.md             #   *.nix, flake.nix, flake.lock
│   ├── systems-safety.md  #   *.rs/*.zig/*.c/*.cpp  (NASA Power-of-10, condensed)
│   ├── docker.md          #   Dockerfile, docker-compose*, docker/**
│   ├── docs-and-release.md#   *.md, packaging/**, release/**, manifests
│   ├── ansible.md         #   ansible.cfg, playbooks/**, roles/**/tasks/, inventory/**
│   └── ci.md              #   workflows, *-ci.yml (GitHub + GitLab), package.json, go.mod, Cargo.toml, Dockerfile
├── reference/
│   ├── infrastructure.md  # Hardware/cluster/VM inventory (read on demand)
│   ├── playwright.md      # Which Playwright toolchain (Python venv vs repo Node)
│   └── skill-audit-findings.md # Decision log: third-party skills evaluated + verdicts
└── skills/                # See "Skills" below (custom + vendored upstream)
```

> `lessons.md` (a running local corrections log) is intentionally **not** mirrored —
> it accrues host/secret detail over time and stays machine-local.

### Context model
`CLAUDE.md` loads in every session, so it stays lean (universal workflow and
principles only). Stack-specific guidance lives in `rules/*.md` with `paths:`
frontmatter and loads **on demand** when Claude touches a matching file — a
Rust rule never burns context during a Zig or docs session. `reference/` is not
auto-loaded; `CLAUDE.md` points to it for read-on-demand.

## Plugins

Installed from the official `claude-plugins-official` marketplace
(`anthropics/claude-plugins-official`), user scope.

| Plugin | Purpose |
|--------|---------|
| `rust-analyzer-lsp` | Rust language server integration |
| `clangd-lsp` | C/C++ language server (systems + Zig C-interop) |
| `code-review` | Automated code review |
| `pr-review-toolkit` | Pull-request review workflow |
| `commit-commands` | Commit helpers (pairs with Conventional Commits) |
| `feature-dev` | Structured feature-development workflow |
| `security-guidance` | Security best-practice guidance |
| `code-simplifier` | Refactor toward simpler code |

Installed from the `openai-codex` marketplace (`openai/codex-plugin-cc`), user scope:

| Plugin | Purpose |
|--------|---------|
| `codex` | Delegate to / get second-opinion reviews from Codex (GPT-5.x) without leaving Claude Code |

`codex` shells out to the local `codex` CLI and reuses its auth (`~/.codex/auth.json`)
and config (`~/.codex/config.toml`). Requires `codex` installed + logged in. Adds
`/codex:review`, `/codex:adversarial-review`, `/codex:rescue`, `/codex:status`,
`/codex:result`, `/codex:cancel`, `/codex:setup`. Leave the optional review gate
(`/codex:setup --enable-review-gate`) **off** — it loops Claude↔Codex and drains
both usage limits.

## Skills

`ssh`, `acme`, `cloudflare`, `hudu`, and `gitlab` are custom local skills
(sanitized here — host-specific values, real domains, instance URLs, and zone
plans stay machine-local). `gitlab-pipeline-watch` and `gitlab-babysit-mr` are
house-authored, inspired by the MIT-licensed `gitlab-org/ai/skills` (rewritten
lean, not vendored). `xlsx`, `docx`, and the Anthropic set are vendored from the
official `anthropics/skills` repo with their upstream `LICENSE.txt`; `defuddle`
is vendored from `kepano/obsidian-skills`. Vendored skills can be re-pulled via
bootstrap.

| Skill | Source | Purpose |
|-------|--------|---------|
| `ssh` | custom | SSH/SCP/rsync/remote-sudo discipline (key-first, PTY sudo, config traps) |
| `acme` | custom | acme.sh Let's Encrypt + Cloudflare DNS-01; the silent-deploy-failure reflex |
| `cloudflare` | custom | Cloudflare API v4 — AI-bot/SBFM, cache rules, WAF, rate limiting, purge |
| `repo-docs` | custom | House-style repo docs — tech badges, single docs/ index, mermaid, advisories, issue templates, dependabot |
| `hudu` | custom | Hudu MSP-docs MCP wiring + egress guardrail (Claude Code transport, secret-rotation, search-before-create) |
| `secrets` | custom | Secret handling — keyring fetch (secret-tool/pass), generation, rotation, leaked-secret scanning, CI-native stores |
| `security` | custom | Defensive review of own code — OWASP + LLM/agentic risks + per-language footguns (Rust/Zig/Go/Py/TS); read-only |
| `skill-audit` | custom | Vet third-party skills/MCPs before adopting — allowed-tools surface, exfil/injection/backdoor scan, adopt vs author-fresh |
| `pentest` | custom | Authorized pentest of own assets — recon→enumerate→validate→report; no payloads/persistence/exfil, feeds findings to `security` |
| `gitlab` | custom | Drive self-hosted GitLab via `glab` — MRs, pipelines/CI, issues, releases, the `glab api` pagination/escaping traps |
| `gitlab-pipeline-watch` | custom | Read-only poll of an MR/branch pipeline to completion; ships a bounded `glab` watch script (inspired by gitlab-org/ai/skills, MIT) |
| `gitlab-babysit-mr` | custom | Write-capable "drive the MR to green" loop — classify failure, minimal fix, retry; strict guardrails (inspired by gitlab-org/ai/skills, MIT) |
| `proxmox` | custom | Operate PVE + Proxmox Backup Server — qm/pct/pvesm/pvecm/pvesh, VFIO passthrough, vzdump/PBS backup-restore |
| `terraform` | custom | Terraform/OpenTofu with plan/apply discipline — GitLab HTTP state backend, provider pinning, `bpg/proxmox`, secret handling |
| `tui-dev` | custom | Headless TUI develop/debug — run in tmux, capture+see the screen, drive keys, golden-screen snapshots; Ratatui/Bubble Tea/Textual |
| `skill-creator` | upstream | Author, improve, and measure skills |
| `mcp-builder` | upstream | Build high-quality MCP servers |
| `webapp-testing` | upstream | Playwright-based local web-app testing (e.g. strix console) |
| `pdf` | upstream | Read / edit / create PDF files |
| `xlsx` | upstream | Read / edit / create spreadsheets (MSP deliverables) |
| `docx` | upstream | Read / edit / create Word documents (MSP deliverables) |
| `defuddle` | kepano | Clean-markdown web extraction (`defuddle parse <url> --md`); needs the CLI |

## MCP servers

| Server | Transport | Endpoint / Command | Scope |
|--------|-----------|--------------------|-------|
| `context7` | HTTP | `https://mcp.context7.com/mcp` | user |
| `mempalace` | stdio | `mempalace-mcp` | user |

`context7` provides up-to-date library/crate documentation in context. Works
unauthenticated (rate-limited).

`mempalace` is a local-first memory system (no API key, no cloud). Claude can
save, search, and recall across sessions via its MCP tools. Installed as a `uv`
tool (`mempalace`, `mempalace-mcp`); stores data locally (ChromaDB, ~300 MB
embedding model on first use).

Memory auto-capture (optional): raw Claude Code transcripts expire in ~30 days,
so capture them into the palace by either:
- periodic backfill — `mempalace mine ~/.claude/projects/` (run within 30 days), or
- auto-save hooks — see the official guide at `mempalaceofficial.com/guide/hooks`.

## Status line

`settings.json` sets a `ccusage` status line showing model, session/daily/block
cost, burn rate, and live context-window usage (🧠 %) — useful for staying under
the context-rot threshold. It runs as external UI and costs no session context.

```json
"statusLine": { "type": "command", "command": "bunx ccusage statusline" }
```

Optional next step — GitHub MCP (issues/PRs/CI), requires a personal access token:

```sh
claude mcp add --transport http github https://api.githubcopilot.com/mcp/ \
  -s user --header "Authorization: Bearer <YOUR_GITHUB_PAT>"
```

## Bootstrap on a fresh machine

```sh
# 1. Config — copy instructions, settings, rules, and reference into ~/.claude
mkdir -p ~/.claude/rules ~/.claude/reference
cp CLAUDE.md            ~/.claude/CLAUDE.md
cp settings.json        ~/.claude/settings.json
cp rules/*.md           ~/.claude/rules/
cp reference/*.md       ~/.claude/reference/

# 2. Plugins (official marketplace is added by default)
for p in rust-analyzer-lsp clangd-lsp code-review pr-review-toolkit \
         commit-commands feature-dev security-guidance code-simplifier; do
  claude plugin install "$p@claude-plugins-official" -s user
done

# 2b. Codex plugin (separate marketplace; needs the codex CLI + login)
#     npm install -g @openai/codex && codex login
claude plugin marketplace add openai/codex-plugin-cc
claude plugin install codex@openai-codex -s user

# 3. Skills — copy the set (custom ssh/acme/cloudflare + vendored xlsx/docx/etc.)
mkdir -p ~/.claude/skills
cp -r skills/* ~/.claude/skills/
# (upstream skills can instead be re-pulled fresh from github.com/anthropics/skills)
# defuddle needs its CLI:  npm install -g defuddle

# 4. MCP servers
claude mcp add --transport http context7 https://mcp.context7.com/mcp -s user

# 5. Memory (mempalace) — local-first, no API key
uv tool install mempalace
claude mcp add mempalace -s user -- mempalace-mcp

# 6. Status line (add to ~/.claude/settings.json):
#   "statusLine": { "type": "command", "command": "bunx ccusage statusline" }
```

## Maintenance

- Keep `CLAUDE.md` under ~150 lines; if Claude starts ignoring rules, it's too long.
- Every loaded skill's name + description costs context — add skills deliberately, not in bulk.
- Update plugins with `claude plugin update <plugin>`; refresh skills by re-running step 3.
- Re-sync this mirror after editing `~/.claude/` so the dotfiles don't drift.

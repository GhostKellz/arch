# Claude Code configuration

Personal Claude Code setup, mirrored from `~/.claude/`. Covers global
instructions, on-demand rules, machine reference, and the installed
plugins / skills / MCP servers.

## Layout

```
claude/
├── CLAUDE.md              # Global working agreement (loaded every session)
├── rules/                 # Path-scoped rules, loaded ONLY when matching files are touched
│   ├── rust.md            #   *.rs, Cargo.toml
│   ├── zig.md             #   *.zig, build.zig.zon
│   ├── systems-safety.md  #   *.rs/*.zig/*.c/*.cpp  (NASA Power-of-10, condensed)
│   ├── docker.md          #   Dockerfile, docker-compose*, docker/**
│   └── docs-and-release.md#   *.md, packaging/**, release/**, manifests
└── reference/
    └── infrastructure.md  # Hardware/cluster/VM inventory (read on demand)
```

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

Sourced from the official `anthropics/skills` repo, copied into
`~/.claude/skills/`. Not vendored here (upstream-maintained) — see bootstrap.

| Skill | Purpose |
|-------|---------|
| `skill-creator` | Author, improve, and measure skills |
| `mcp-builder` | Build high-quality MCP servers |
| `webapp-testing` | Playwright-based local web-app testing (e.g. strix console) |
| `pdf` | Read / edit / create PDF files |

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
# 1. Config — copy instructions, rules, and reference into ~/.claude
mkdir -p ~/.claude/rules ~/.claude/reference
cp CLAUDE.md            ~/.claude/CLAUDE.md
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

# 3. Skills — pull from the official repo, copy the selected set
tmp=$(mktemp -d)
git clone --depth 1 https://github.com/anthropics/skills.git "$tmp/skills"
mkdir -p ~/.claude/skills
for s in skill-creator mcp-builder webapp-testing pdf; do
  cp -r "$tmp/skills/skills/$s" ~/.claude/skills/
done
rm -rf "$tmp"

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

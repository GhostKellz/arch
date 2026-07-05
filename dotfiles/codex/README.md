# Codex configuration

Personal OpenAI Codex setup, mirrored from the safe/portable parts of
`$HOME/.codex`. This folder is a dotfiles-friendly Codex config and local plugin
mirror that can be installed on a new workstation.

## Layout

```text
codex/
├── AGENTS.md             # Global Codex working agreement
├── config.example.toml   # Sanitized config shape; not copied over live config blindly
├── skills/               # Portable Codex Agent Skills safe for this dotfiles mirror
├── plugins/              # Local plugin source mirrors
├── .gitignore            # Excludes auth, logs, cache, state, rules, sessions
└── README.md
```

## What belongs here

- Portable global instructions (`AGENTS.md`).
- Sanitized config shape and examples.
- Portable Codex skills that are safe for the dotfiles mirror.
- Notes on how to install Codex config on a fresh machine.
- A local Codex plugin mirror for portable CKTech workflows.

## What does not belong here

- `auth.json`
- `history.jsonl`
- SQLite state/log/memory files
- session transcripts
- shell snapshots
- generated images
- plugin caches
- MCP cache files
- Codex command approval rules
- plaintext hosts, passwords, API keys, PATs, or tokens

Codex command approval rules are intentionally machine-local. They can contain command
approval policy and must never be mirrored because stale approvals and
credential-bearing commands are security risk.

## Fresh-machine install

Install Codex itself and log in first:

```sh
npm install -g @openai/codex
codex login
```

Then copy only the portable files:

```sh
mkdir -p "$HOME/.codex"
cp AGENTS.md "$HOME/.codex/AGENTS.md"
cp config.example.toml "$HOME/.codex/config.toml"
```

Review `$HOME/.codex/config.toml` after copying. Add only the project trust entries
and MCP servers that make sense on that host.

Install the portable skills directly from this directory:

```sh
mkdir -p "$HOME/.codex/skills"
cp -r skills/* "$HOME/.codex/skills/"
```

Or install into the cross-agent location if that is the active Codex convention
on the target machine:

```sh
mkdir -p "$HOME/.agents/skills"
cp -r skills/* "$HOME/.agents/skills/"
```

## Included direct skills

| Skill | Purpose |
|-------|---------|
| `cktech-brain-obsidian` | Use the tiered Obsidian brain safely from Codex: public wiki, private local tier, Quartz at `brain.ckelley.dev`, and MCP/filesystem access. |
| `cktech-hudu` | Use self-hosted Hudu at `hudu.cktechx.com` via MCP while keeping client-confidential data out of the public brain. |

## Skills and plugins

Current Codex supports Agent Skills and plugins. This repo carries a local plugin
mirror at:

```text
plugins/cktech-codex/
```

Install this plugin by copying `plugins/cktech-codex/` to your preferred local
Codex plugin source directory, then adding it to a personal marketplace.

Example local plugin source:

```text
$HOME/plugins/cktech-codex/
```

Live install/cache path after `codex plugin add cktech-codex@personal`:

```text
$HOME/.codex/plugins/cache/personal/cktech-codex/<version>/
```

Personal marketplace:

```text
$HOME/.agents/plugins/marketplace.json
```

The plugin source in this dotfiles tree is safe to inspect and copy on another
machine. Live Codex cache directories remain generated state and should not be
edited by hand.

## Maintenance

- Keep `AGENTS.md` lean. It loads often and should not become a runbook.
- Keep private or host-specific skills out of this public mirror.
- Keep live rules local and reviewed.
- When live Codex behavior changes, update this mirror only with portable,
  secret-free config and skills.

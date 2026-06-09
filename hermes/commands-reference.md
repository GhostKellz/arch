# Command Reference

Cheatsheet for the `hermes` CLI. Run `hermes --help` for the authoritative list on
your installed version; `hermes version` to check it.

## Chat / sessions

| Command | Purpose |
|---------|---------|
| `hermes` | Start chatting (classic CLI) |
| `hermes --tui` | Modern TUI (recommended) |
| `hermes --continue` | Resume last session |
| `hermes chat -q "…"` | One-shot query (good for connectivity tests) |
| `hermes sessions list` | List past sessions |

## Setup / config

| Command | Purpose |
|---------|---------|
| `hermes setup` | Full configuration wizard |
| `hermes setup --portal` | Fast path: configure Nous Portal |
| `hermes model` | Choose/switch LLM provider + model (**interactive, needs a TTY**) |
| `hermes tools` | Enable/disable tools |
| `hermes config set <key> <value>` | Set an individual config value |
| `hermes config reset` | Reset config (keeps data) |
| `hermes auth` | Authenticate a provider (OAuth/keys) |
| `hermes status` | Current config + running daemons |
| `hermes version` | Print installed version |
| `hermes dump` | Debug info (config, git commit, versions) |

## Skills

| Command | Purpose |
|---------|---------|
| `hermes skills browse` | Browse the Skills Hub |
| `hermes skills search <term>` | Search skills by keyword |
| `hermes skills info <name>` | View skill details |
| `hermes skills install <name>` | Install a skill |

## Gateway (messaging)

| Command | Purpose |
|---------|---------|
| `hermes gateway setup` | Connect Telegram/Discord/Slack/etc. |
| `hermes gateway start` | Run the message broker (foreground) |
| `hermes gateway install` | Install gateway as a service (messaging + cron) |
| `hermes gateway status` | Gateway health |

## Cron / automation

| Command | Purpose |
|---------|---------|
| `hermes cron list` | View scheduled jobs |
| `hermes daemon start` | Start the scheduler daemon |

## Diagnostics

| Command | Purpose |
|---------|---------|
| `hermes doctor` | Full system health check |
| `hermes portal info` | Nous Portal status |

## Migration

| Command | Purpose |
|---------|---------|
| `hermes claw migrate` | Import from OpenClaw |

> Some subcommands (notably `hermes model`) refuse to run through a pipe — they
> require an interactive terminal. Run them directly in your shell.

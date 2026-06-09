# Getting Started

Assumes Hermes is installed and `hermes doctor` is green. If not, see
[install-arch-local.md](install-arch-local.md).

## 1. Pick a model/provider

`hermes model` is an **interactive** picker — it needs a real TTY (it errors if
piped). Run it in your terminal:

```bash
hermes model
```

Four paths:

1. **Nous Portal** (easiest) — one subscription routes across Claude, GPT, GLM,
   MiniMax, and Nous models via OAuth. Fast path: `hermes setup --portal`.
2. **API key (BYO)** — paste a key from Anthropic (`sk-ant-…`), OpenAI (`sk-…`),
   z.AI, MiniMax, DeepSeek, OpenRouter, etc.
3. **Local model** — point at Ollama / LM Studio / vLLM (see
   [models-and-providers.md](models-and-providers.md) and
   [proxmox-4090-vfio.md](proxmox-4090-vfio.md)).
4. **Skip** — configure later.

> **Hard requirement:** the model must expose **≥ 64,000 tokens** of context.
> Below that, Hermes won't run reliably.

Config is written to `~/.hermes/config.yaml`; secrets to `~/.hermes/.env`.

## 2. First chat

```bash
hermes              # classic CLI
hermes --tui        # modern TUI (recommended)
hermes --continue   # resume last session
```

Start with a small verifiable prompt ("what tools do you have available?") to
confirm connectivity.

## 3. Configure everything at once (optional)

```bash
hermes setup        # full wizard: provider, tools, gateway, etc.
hermes tools        # enable/disable specific tools
```

## 4. Install a few skills

```bash
hermes skills browse
hermes skills install llm-wiki
```

See [essential-skills.md](essential-skills.md) for a recommended day-one set.

## 5. (Optional) Always-on messaging + automation

```bash
hermes gateway setup     # connect Telegram/Discord/Slack/etc.
```

Then schedule recurring jobs in natural language — see
[cron-automation.md](cron-automation.md).

## Recovery sequence

When something's off, walk this ladder:

```
hermes doctor  →  hermes model  →  hermes setup  →  hermes sessions list
              →  hermes --continue  →  hermes gateway status
```

## Three ways people use it

1. **CLI developer** — in-terminal coding agent alongside Claude Code; leans on
   skills + memory.
2. **Automation operator** — recurring reporting/monitoring/triage; leans on cron
   + gateways.
3. **Mobile-first** — Telegram bot with voice; leans on the messaging gateway.

All three coexist in one Hermes instance.

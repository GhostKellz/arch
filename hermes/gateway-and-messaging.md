# Gateway & Messaging

The **gateway** is Hermes's second entry point: run a broker and talk to the *same*
agent (same memory, skills, sessions) from messaging platforms instead of the
terminal.

## Supported channels

Telegram, Discord, Slack, WhatsApp, Signal, Email, Home Assistant, Microsoft Teams,
Google Chat, plus webhooks for external systems. 14+ surfaces total.

## Setup

```bash
hermes gateway setup      # interactive: pick platform(s), provide tokens
hermes gateway start      # run broker in the foreground
hermes gateway install    # install as a background service (messaging + cron)
hermes gateway status     # health check
```

Messaging libraries (`python-telegram-bot`, `discord.py`, etc.) are **lazy-installed
on first use** — that's why `hermes doctor` lists them as "not installed" on a fresh
box.

### Telegram example

1. Create a bot with @BotFather, copy the token.
2. `hermes gateway setup` → choose Telegram → paste token.
3. `hermes gateway install` (or `hermes daemon start`) to keep it running.
4. Message your bot; it drives the same agent. Voice messages are supported.

## Profiles (multi-user / team)

For shared instances, **profile isolation** gives each profile its own memory,
sessions, skills, and cron state. Access is controlled by an allowlist, so a shared
VPS can host multiple isolated agents safely.

## Where to run the gateway

- **This Arch box** — fine for personal always-on if the machine stays up.
- **A VPS / PVE 7 (EPYC, public)** — better for a persistent, internet-reachable
  gateway. Pair with the Docker deploy ([docker-deployment.md](docker-deployment.md))
  for isolation; the compose file already binds the dashboard to localhost and uses
  host networking.

## Combine with cron

The real payoff is gateway + scheduler: "every morning at 8am, summarize my GitHub
notifications and send it to Telegram." See [cron-automation.md](cron-automation.md).

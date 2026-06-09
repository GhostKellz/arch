# Cron & Automation

Hermes has a built-in scheduler. You describe recurring work in natural language;
it stores the preference in memory and maintains the cron schedule itself.

## Commands

```bash
hermes cron list        # view scheduled jobs
hermes daemon start     # start the scheduler daemon
hermes gateway install  # installs the service that runs cron + messaging
```

Cron state lives under `~/.hermes/cron/`.

## How you schedule

Just ask, in a chat or via a gateway:

- "Every morning at 8am, summarize my GitHub notifications and send it to Telegram."
- "Every weekday at 7:30am, collect: (1) top 10 HN posts overnight, (2) my unread
  GitHub notifications, (3) weather for <location>. Send as one email."

The agent translates that into a cron entry and persists your preferences, so it
keeps doing it without re-prompting.

## Patterns

- **Scheduled briefing** — daily digest emailed without any interactive chat.
- **Monitoring/triage** — periodic checks that ping you only when something needs
  attention.
- **Reporting** — recurring repo/audit reports (pairs well with skills that get
  generated on the second run).

## Requirements

- A running daemon/service (`hermes daemon start` or `hermes gateway install`).
- A delivery channel for output (email/Telegram/etc.) — see
  [gateway-and-messaging.md](gateway-and-messaging.md).
- The host must be up when jobs fire — a good reason to run automation on an
  always-on box (VPS / PVE) rather than the workstation. See
  [docker-deployment.md](docker-deployment.md) and
  [proxmox-4090-vfio.md](proxmox-4090-vfio.md).

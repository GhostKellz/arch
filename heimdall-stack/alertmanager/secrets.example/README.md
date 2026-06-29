# Alertmanager notification secrets

These are **example placeholders**. The real files live in `secrets/alertmanager/`
at the repo root, which is gitignored and mounted read-only into the container at
`/etc/alertmanager/secrets` (see `docker-compose.yml`).

## Setup

```bash
mkdir -p secrets/alertmanager
cp alertmanager/secrets.example/smtp-auth-password    secrets/alertmanager/
cp alertmanager/secrets.example/discord-monitoring-url secrets/alertmanager/
$EDITOR secrets/alertmanager/smtp-auth-password        # SMTP2Go SMTP password, no trailing newline issues
$EDITOR secrets/alertmanager/discord-monitoring-url    # Discord channel webhook URL
chmod 600 secrets/alertmanager/*
```

| File | Contents |
|------|----------|
| `smtp-auth-password`    | SMTP2Go SMTP password for `alertmanager@example.com` |
| `discord-monitoring-url`| Discord webhook URL for the `#monitoring` channel |

Referenced from `alertmanager/alertmanager.yml` via `smtp_auth_password_file` and
`webhook_url_file`. Never inline these values into the YAML. See
[docs/alerting.md](../../docs/alerting.md).

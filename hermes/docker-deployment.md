# Docker Deployment

For an isolated, always-on Hermes (gateway + dashboard) without touching the host
Python environment. The repo ships a ready compose file at
`/data/repo/hermes-agent/docker-compose.yml`.

## Run it

```bash
cd /data/repo/hermes-agent
HERMES_UID=$(id -u) HERMES_GID=$(id -g) docker compose up -d
```

`HERMES_UID`/`HERMES_GID` remap the container's internal `hermes` user (default UID
10000) to your host user so files created in the mounted `~/.hermes` stay
owner-correct. The s6-overlay stage2 hook does the remap; each service drops
privileges via `s6-setuidgid`.

## What's in the compose

Two services, both `image: hermes-agent`, both `network_mode: host`,
both mounting `~/.hermes:/opt/data`:

| Service | Command | Notes |
|---------|---------|-------|
| `gateway` | `gateway run` | The message broker (Telegram/Discord/etc.) |
| `dashboard` | `dashboard --host 127.0.0.1 --no-open` | Web UI, **localhost-only** |

PID 1 is s6-overlay's `/init` (entrypoint `["/init", "/opt/hermes/docker/main-wrapper.sh"]`)
— it runs init hooks (chown, profile reconcile) and the supervision tree. Don't
bypass it.

## Host networking (matches our workstation policy)

The compose already uses `network_mode: host` — exactly what we want on this
Arch box and the PVE nodes. It sidesteps the DNS/connectivity problems we
repeatedly hit with Docker bridge networks. **Don't** convert this to a custom
bridge network.

## Security defaults (don't loosen blindly)

- **Dashboard binds `127.0.0.1`** — it stores API keys. For remote access, tunnel:
  `ssh -L 9119:localhost:9119 <host>`. Never `--insecure --host 0.0.0.0`.
- **Gateway API server is off** unless you uncomment both `API_SERVER_HOST` and
  `API_SERVER_KEY` (key is mandatory auth). Read `docs/user-guide/api-server.md`
  before exposing on an internet-facing host (e.g. PVE 7).
- Teams / Google Chat blocks are commented stubs — fill in only what you use.

## Lifecycle

```bash
docker compose ps
docker compose logs -f gateway
docker compose down                 # stop
docker compose up -d --build        # rebuild after a git pull
```

## When to use this vs native

- **Native dev install** ([install-arch-local.md](install-arch-local.md)) — for
  hacking on the agent on the workstation.
- **Docker** — for a persistent gateway/dashboard you don't want entangled with the
  host venv, ideally on an always-on node (PVE 7) so cron jobs actually fire.

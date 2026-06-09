# Troubleshooting

First move is always `hermes doctor`. Then walk the recovery ladder:

```
hermes doctor → hermes model → hermes setup → hermes sessions list
             → hermes --continue → hermes gateway status
```

## Common issues

| Symptom | Fix |
|---------|-----|
| `command not found: hermes` | New shell or `source ~/.zshrc`; confirm `~/.local/bin` on PATH |
| `'hermes model' requires an interactive terminal` | Run it directly in a real terminal, not via pipe/subprocess |
| `Provider error: invalid API key` | Strip trailing whitespace; confirm key matches the selected provider |
| Python version mismatch | We hit this — system Python 3.14 is unsupported; uv must provision 3.11 (see [install-arch-local.md](install-arch-local.md)) |
| `uv: command not found` | Re-run setup (idempotent), or install uv: `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| Messaging libs missing (telegram/discord) | Expected — lazy-installed on first gateway use; or install the extra |
| `agent-browser not installed` | Optional: `npm install` in `/data/repo/hermes-agent` |
| Model rejected / context errors | Model must expose **≥ 64,000 tokens** of context |
| `direnv: .envrc is blocked` | It's the Nix flake env we don't use — leave blocked or `rm .envrc` (do **not** `direnv allow` without Nix) |

## Arch-specific notes

- **Never downgrade system Python** to satisfy Hermes — let `uv` own the 3.11 venv.
  System 3.14 stays for the rest of the OS.
- Docker: prefer `network_mode: host` (see [docker-deployment.md](docker-deployment.md)).
- Build errors during dep install → ensure `base-devel` (gcc, make) and `libffi`.

## Inspecting state

```bash
hermes dump                 # config + git commit + versions
hermes status               # active config + daemons
ls ~/.hermes/logs/          # runtime logs
cat ~/.hermes/config.yaml   # current config (secrets are in ~/.hermes/.env)
```

## Clean reset (destructive)

```bash
rm -rf ~/.hermes/           # wipes memory, skills, config, sessions
# then re-run setup-hermes.sh from the repo
```

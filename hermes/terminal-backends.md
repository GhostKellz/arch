# Terminal Backends, Checkpoints & Sandboxing

How Hermes actually *executes* commands, and the safety rails around it. The agent
runs real shell commands — this article is about controlling *where* and *how safely*.

> Grounded in the `terminal:` and `checkpoints:` config sections in
> `/data/repo/hermes-agent/hermes_cli/config.py`, plus approval/policy behavior.

## Execution backends

The `terminal.backend` setting decides where commands run:

| Backend | Where commands run | Use when |
|---------|--------------------|----------|
| `local` | Directly on this host | Trusted dev work on the Arch box |
| `docker` | Inside a container | Isolating risky/automated runs from the host |
| `ssh` | On a remote host | Driving a Proxmox VM or the EPYC box remotely |

`terminal:` also covers container image/name, mounted volumes, and shell config. For
our workstation, host-networked Docker is the default container convention (DNS and
local-service reachability are reliable that way).

### Docker backend sketch

```yaml
terminal:
  backend: docker
  # container image / name, volumes, and shell live here too
```

Putting the agent's shell in a container is the cleanest way to let it run
freely-generated commands without touching your real filesystem. Pair with host
networking so it can still reach local model endpoints and services.

### SSH backend

Point `terminal.backend: ssh` at a Proxmox VM (e.g. the 4090 VFIO box or a throwaway
PVE guest) when you want the agent operating on a remote target while the CLI/UI stays
on your workstation.

## Checkpoints — filesystem snapshots

The `checkpoints:` section makes Hermes snapshot the filesystem **before destructive
operations**, so you can roll back. Controls include max snapshots kept and
auto-prune.

```bash
hermes checkpoints status   # see snapshot state
hermes checkpoints list     # list snapshots
hermes checkpoints prune    # trim old snapshots
hermes checkpoints clear    # remove them
```

This is your undo button when an automated run or a skill does something you didn't
want.

## Approval policy & sandboxing

- **Destructive-command approval** — by default the agent prompts before dangerous
  operations. In delegated subagents this flips to **auto-deny** unless
  `delegation.subagent_auto_approve: true` — a runaway child can't `rm -rf`
  unattended. See [subagents-delegation.md](subagents-delegation.md).
- **Toolset gating** — `hermes tools disable <name>` removes whole capability groups
  (e.g. take away code execution for a locked-down profile).
- **Session logging** — everything is logged under `~/.hermes/sessions/`; review with
  `hermes sessions` (`list/export/browse/stats`).
- **Profiles** — isolate a public/team agent's state from your personal one.

## Layered safety for untrusted automation

When running unattended (cron, gateway bots), stack the rails:

1. `terminal.backend: docker` (host networking) — contain the blast radius.
2. `checkpoints` enabled — roll back filesystem changes.
3. Keep `subagent_auto_approve: false` — children can't self-approve danger.
4. Trim `toolsets` / disable `execute_code` for the profile if it doesn't need it.
5. Separate `profile` so a public bot can't read your personal memory/sessions.

## Our recommended posture

| Context | Backend | Notes |
|---------|---------|-------|
| Interactive dev on Arch | `local` | You're watching it; approvals on. |
| Unattended cron / gateway | `docker` (host net) | Containerized, checkpoints on. |
| Remote ops on PVE guests | `ssh` | Drive a VM without exposing the workstation. |

> The agent runs real commands. Treat an enabled gateway bot like handing someone a
> shell — sandbox accordingly. See [security](troubleshooting.md) and
> [gateway-and-messaging.md](gateway-and-messaging.md).

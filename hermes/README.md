# Hermes Agent — Local Knowledgebase

Personal knowledgebase for running [Hermes Agent](https://github.com/NousResearch/hermes-agent)
(Nous Research's self-improving AI agent) across this Arch workstation and the
Proxmox lab.

Cloned repo lives at `/data/repo/hermes-agent`. Runtime data lives in `~/.hermes/`.

## Articles

| File | Topic |
|------|-------|
| [overview.md](overview.md) | What Hermes is, harness engineering, the learning loop, architecture |
| [install-arch-local.md](install-arch-local.md) | **Our actual install** on this Arch box (uv + Python 3.11, the 3.14 gotcha) |
| [getting-started.md](getting-started.md) | First run, picking a model, first chat, core workflow |
| [models-and-providers.md](models-and-providers.md) | Provider options, context requirement, cost tiers, local Ollama/vLLM |
| [skills-and-memory.md](skills-and-memory.md) | Skills system, memory architecture, the Curator |
| [essential-skills.md](essential-skills.md) | Skills to install first + how to discover more |
| [ecosystem-projects.md](ecosystem-projects.md) | Notable Hermes Atlas projects, skill packs, MCP tooling |
| [mcp-servers.md](mcp-servers.md) | Connecting Hermes to external tools via MCP (and serving MCP) |
| [subagents-delegation.md](subagents-delegation.md) | Spawning child agents, parallel work, the `delegation` config |
| [config-reference.md](config-reference.md) | `~/.hermes/config.yaml` top-level keys and common edits |
| [terminal-backends.md](terminal-backends.md) | local/docker/ssh execution, checkpoints, approval/sandboxing |
| [gateway-and-messaging.md](gateway-and-messaging.md) | Telegram/Discord/Slack/etc. gateway, profiles |
| [cron-automation.md](cron-automation.md) | Scheduled jobs and automation workflows |
| [docker-deployment.md](docker-deployment.md) | Docker Compose path (host networking) |
| [proxmox-4090-vfio.md](proxmox-4090-vfio.md) | **Our deployment**: RTX 4090 VFIO passthrough VM in Proxmox serving Hermes |
| [commands-reference.md](commands-reference.md) | Full `hermes` CLI cheatsheet |
| [troubleshooting.md](troubleshooting.md) | `hermes doctor`, common issues, recovery sequence |
| [resources.md](resources.md) | Official docs, Hermes Atlas, machine-readable doc dumps |

## Sections

| Directory | Topic |
|-----------|-------|
| [skills/](skills/README.md) | Locally-cloned skill repos at `/data/repo/hermes/`, install methods, and how to author your own `SKILL.md` |

## Quick orientation

- **Official docs:** https://hermes-agent.nousresearch.com/docs
- **Hermes Atlas** (community ecosystem map, "Ask the Atlas" RAG bot): https://hermesatlas.com
- **Repo:** https://github.com/NousResearch/hermes-agent (local clone: `/data/repo/hermes-agent`)
- **Two entry points:** `hermes` (terminal UI) and the **gateway** (talk to it from Telegram/Discord/etc.)
- **Check version:** `hermes version` — don't hardcode versions in these notes; ask the binary.

## Our environments at a glance

| Host | Role for Hermes |
|------|-----------------|
| Arch workstation (9950X3D / 64GB / RTX 5090) | Primary dev + native `hermes` CLI install |
| PVE 3 (14900K / 128GB / RTX 4090) | VFIO-passthrough VM serving a local model endpoint for Hermes — see [proxmox-4090-vfio.md](proxmox-4090-vfio.md) |
| PVE 7 (EPYC / 128GB ECC / public) | Candidate for always-on gateway (Telegram/Discord) |

> These are working notes, not marketing. Keep them accurate; correct drift as the
> agent and our setup evolve.

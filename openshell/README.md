# OpenShell on Arch — Knowledge Base

Local notes for running NVIDIA OpenShell on this Arch host. OpenShell provides
sandboxed, policy-governed runtimes for autonomous AI agents. A gateway control
plane manages sandbox lifecycle; each sandbox runs in its own container with
policy-enforced egress.

This KB documents how it was actually set up here: **built from source** out of a
cloned repo and run as a **standalone host gateway** using the Docker compute
driver.

## Why build from source (not the installer)

The official one-liner installer does not work on Arch:

```sh
curl -LsSf https://raw.githubusercontent.com/NVIDIA/OpenShell/main/install.sh | sh
```

`install.sh` only supports Debian (`dpkg`) and RPM (`rpm`) package managers. Arch
uses `pacman`, so the installer hard-errors with
`Linux installs require either dpkg or rpm`. The supported paths on Arch are:

- **Build from source via `mise`** — the maintainer dev workflow. This is what we use.
- **PyPI**: `uv tool install -U openshell` — installs the CLI but leaves gateway
  start/registration to you.

## Files in this KB

| File | What it covers |
|------|----------------|
| [install.md](install.md) | Prerequisites and from-source build/run on Arch |
| [configuration.md](configuration.md) | Gateway config, state dirs, ports, env vars |
| [howto.md](howto.md) | Day-to-day commands: sandboxes, providers, policy, gateway |
| [guide.md](guide.md) | How the pieces fit together (gateway vs driver vs sandbox) |
| [troubleshooting.md](troubleshooting.md) | The cargo target-triple gotcha and other fixes |

## Current state (verified)

- Gateway: `docker-dev`, `http://127.0.0.1:18080`, status **Connected**.
- Gateway runs as a host process (`target/debug/openshell-gateway`), not a container.
- Compute driver: `docker`. Containers only appear once sandboxes are created.
- Repo: `/data/repo/OpenShell`.

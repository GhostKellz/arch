# Install (from source, Arch)

How OpenShell was built and started on this host.

## Prerequisites

Already present on this machine: `docker` (daemon running), `rust`/`cargo`,
`python`, `uv`, `git`.

Installed for OpenShell:

```sh
sudo pacman -S --needed z3 mise
```

- **z3** — required by the `openshell-prover` crate (links system Z3 via pkg-config).
- **mise** — dev environment + task runner OpenShell uses. Provisions a pinned
  toolchain (protoc, node, sccache, its own rust/python, etc.).

Requirements per the project: Rust 1.88+, Python 3.12+, a running Docker (or
Podman) daemon, and the Z3 solver library.

## Repo

```sh
git clone https://github.com/NVIDIA/OpenShell.git
cd OpenShell
```

Here it lives at `/data/repo/OpenShell`.

## Provision the toolchain

```sh
mise trust
mise install
```

`mise install` is user-local (no sudo). It downloads the pinned tools defined in
`mise.toml` and creates the project `.venv`. The toolchain versions are pinned in
`mise.toml` — treat that file as the source of truth, not this doc.

## Build and run the gateway

```sh
mise run gateway
```

This script (`tasks/scripts/gateway.sh` → `gateway-docker.sh` when only Docker is
present):

1. Detects the compute driver (order: kubernetes → podman → docker). Here: **docker**.
2. Builds `openshell-gateway` (`cargo build -p openshell-server`).
3. Builds the `openshell-sandbox` supervisor for the native target.
4. Generates local TLS/JWT credentials under the state dir.
5. Writes `gateway.toml`, registers the gateway metadata as `docker-dev`.
6. Runs the gateway in the foreground on `127.0.0.1:18080` (plaintext, unauthenticated — local dev only).

Leave it running in its own terminal. It is a long-lived process.

## Activate the CLI

`mise` adds `scripts/bin` to `PATH` once activated, exposing the `openshell`
shortcut (builds the debug CLI if needed, then runs it).

```sh
# Add to your shell once (zsh shown)
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
exec zsh
```

From inside the repo:

```sh
openshell gateway select docker-dev   # set the active gateway
openshell status                      # should report Connected
```

Without activation you can call the script directly: `./scripts/bin/openshell <cmd>`.

## Confirming it works

```sh
openshell status         # Gateway: docker-dev, Status: Connected
openshell sandbox list   # "No sandboxes found." until you create one
```

## Known Arch gotcha

If `mise run gateway` fails with
`target/debug/openshell-gateway: No such file or directory` even though the build
succeeded, see [troubleshooting.md](troubleshooting.md#cargo-target-triple). It is
caused by a global `~/.cargo/config.toml` that pins a build target, and is fixed
with two symlinks.

## Alternative: PyPI (CLI only)

```sh
uv tool install -U openshell
```

Installs the `openshell` CLI but does not start or register a gateway — you would
run/register one yourself. Not used here.

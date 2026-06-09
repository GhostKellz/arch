# Troubleshooting

Issues hit on this Arch host and how they were resolved.

## cargo target-triple: "target/debug/openshell-gateway: No such file or directory" {#cargo-target-triple}

**Symptom.** `mise run gateway` compiles successfully, then fails:

```
gateway-docker.sh: line 132: /data/repo/OpenShell/target/debug/openshell-gateway: No such file or directory
```

The same happens for the CLI via `./scripts/bin/openshell`:

```
./scripts/bin/openshell: target/debug/openshell: No such file or directory
```

**Cause.** This host's global `~/.cargo/config.toml` pins an explicit build
target:

```toml
[build]
target = "x86_64-unknown-linux-gnu"

[target.x86_64-unknown-linux-gnu]
linker = "cc"
```

When a build target is set, cargo nests output under
`target/<triple>/debug/` instead of `target/debug/`. Normal `cargo build` and
every other Rust project work fine with this. The breakage is specific to
OpenShell's helper scripts, which hardcode `target/debug/openshell-gateway`
(`gateway-docker.sh`) and `target/debug/openshell` (`scripts/bin/openshell`).
They are not target-triple aware.

**Fix used here (non-invasive — no global config or repo edits).** Symlink the
expected paths to the real binaries:

```sh
cd /data/repo/OpenShell
ln -sf ../x86_64-unknown-linux-gnu/debug/openshell-gateway target/debug/openshell-gateway
ln -sf ../x86_64-unknown-linux-gnu/debug/openshell         target/debug/openshell
```

The symlink targets are relative and point at the stable triple directory, so
they survive rebuilds. The sandbox supervisor build is unaffected because that
step already passes `--target` explicitly.

**Alternatives (not used):**

- Remove `[build] target = ...` from `~/.cargo/config.toml`. This is the root
  cause but changes global behavior for all projects.
- Build with the target unset for just these invocations.

If you ever delete `target/`, recreate the two symlinks.

## `openshell: command not found`

`openshell` is provided by the repo's `scripts/bin` shim, which `mise` only adds
to `PATH` when activated. Either activate mise (`eval "$(mise activate zsh)"`) and
run from inside the repo, or call `./scripts/bin/openshell` directly.

## `status` says "No gateway configured"

`mise run gateway` (Docker path) registers the gateway metadata but does not flip
the active-gateway pointer. Select it:

```sh
openshell gateway select docker-dev
openshell status
```

## `docker ps` shows nothing

Expected. The gateway is a host process, not a container. Containers only exist
per sandbox. Run `openshell sandbox create`, then check `docker ps`. See
[guide.md](guide.md).

## Port 18080 already in use

```sh
ss -ltnp | grep 18080         # find the holder
OPENSHELL_SERVER_PORT=19080 mise run gateway   # or pick another port
```

## The curl installer fails on Arch

`install.sh` requires `dpkg` or `rpm`. Arch has neither by default. Build from
source (see [install.md](install.md)) or use `uv tool install -U openshell`.

## z3 / prover build errors

Ensure `z3` is installed and discoverable:

```sh
pkg-config --modversion z3
```

The repo's `.cargo/config.toml` also sets
`BINDGEN_EXTRA_CLANG_ARGS = "-I/usr/include/z3"` for distros that place the
headers there.

## Inspecting the running gateway

```sh
ps -C openshell-gateway -o pid,etime,cmd       # host process
ss -ltnp | grep 18080                          # listeners
tail -f /data/repo/OpenShell/.cache/gateway-docker/gateway.db  # (state db, not logs)
```

Gateway logs go to the foreground terminal running `mise run gateway`.

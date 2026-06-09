# Configuration

Settings for the standalone Docker gateway as run here. The dev gateway is
configured entirely by `tasks/scripts/gateway-docker.sh` and the generated
`gateway.toml`.

## Paths

| Item | Location |
|------|----------|
| Generated gateway config | `/data/repo/OpenShell/.cache/gateway-docker/gateway.toml` |
| TLS/JWT credentials | `/data/repo/OpenShell/.cache/gateway-docker/tls/` |
| Gateway SQLite state | `/data/repo/OpenShell/.cache/gateway-docker/gateway.db` |
| Sandbox supervisor binary | `/data/repo/OpenShell/.cache/gateway-docker/supervisor/<arch>/openshell-sandbox` |
| CLI gateway registry | `~/.config/openshell/gateways/<name>/metadata.json` |
| Active gateway pointer | `~/.config/openshell/active_gateway` |

## Generated gateway.toml (dev defaults)

```toml
[openshell]
version = 1

[openshell.gateway]
compute_drivers = ["docker"]
disable_tls = true

[openshell.gateway.auth]
allow_unauthenticated_users = true   # local dev only

[openshell.gateway.gateway_jwt]
# signing/public/kid paths under the tls/ dir, gateway_id = "docker-dev", ttl 3600s

[openshell.drivers.docker]
default_image     = "ghcr.io/nvidia/openshell-community/sandboxes/base:latest"
image_pull_policy = "IfNotPresent"
sandbox_namespace = "docker-dev"
grpc_endpoint     = "http://host.openshell.internal:18080"
supervisor_bin    = ".cache/gateway-docker/supervisor/<arch>/openshell-sandbox"
```

`disable_tls` and `allow_unauthenticated_users` are appropriate only for trusted
local development. Do not expose this gateway on a network.

## Ports

- `18080` — gateway HTTP (plaintext). Bound to `127.0.0.1` and the Docker bridge
  IP (`172.18.0.1`) so sandbox containers can reach the host via
  `host.openshell.internal`.

## Useful environment overrides

Pass before `mise run gateway` to change defaults:

| Variable | Effect |
|----------|--------|
| `OPENSHELL_SERVER_PORT` | Gateway port (default `18080`) |
| `OPENSHELL_DOCKER_GATEWAY_NAME` | Gateway name (default `docker-dev`) |
| `OPENSHELL_SANDBOX_NAMESPACE` | Sandbox namespace (default `docker-dev`) |
| `OPENSHELL_SANDBOX_IMAGE` | Default sandbox image |
| `OPENSHELL_SANDBOX_IMAGE_PULL_POLICY` | `Always` / `IfNotPresent` / `Never` |
| `OPENSHELL_LOG_LEVEL` | `info`, `debug`, etc. |
| `OPENSHELL_DRIVERS` | Force a driver (`docker`, `podman`, `kubernetes`, `vm`) |

Example:

```sh
OPENSHELL_SERVER_PORT=19080 OPENSHELL_LOG_LEVEL=debug mise run gateway
```

## Telemetry

OpenShell collects anonymous operational telemetry. Disable it on the gateway:

```sh
OPENSHELL_TELEMETRY_ENABLED=false mise run gateway
```

## Resetting state

Stop the gateway, then remove its state dir for a clean slate:

```sh
rm -rf /data/repo/OpenShell/.cache/gateway-docker
```

The CLI-side registration lives separately under `~/.config/openshell/`.

# Guide — how the pieces fit

A mental model for what is running and why, so the `docker ps` question doesn't
come up again.

## Three layers

1. **Gateway** — the control plane. Here it is the native binary
   `openshell-gateway` running on the host (PID on the host, listening on
   `127.0.0.1:18080`). It coordinates sandbox lifecycle and is the auth boundary.
   It is **not** a container.

2. **Compute driver** — how the gateway creates sandboxes. We use the **docker**
   driver. The driver name is what gives the gateway its default name
   (`docker-dev`). The driver only acts when you create a sandbox.

3. **Sandbox** — an isolated runtime. Each sandbox is a **Docker container**
   launched by the gateway via the driver, supervised by the `openshell-sandbox`
   binary, with policy-enforced egress.

So:

```
host process: openshell-gateway (docker-dev)  ->  127.0.0.1:18080
       |
       | (docker driver, on `sandbox create`)
       v
docker container: sandbox  <-- appears in `docker ps`
```

## Why `docker ps` is empty right now

No sandboxes exist, so no containers exist. The gateway itself is a host process.
Create a sandbox and the container shows up:

```sh
openshell sandbox create
docker ps    # now shows the sandbox container
```

## Naming recap

- `docker-dev` = the gateway's registered name (driver-derived default), not a
  container name.
- The sandbox namespace is also `docker-dev` by default — that scopes sandbox
  resources, again not a single container.

## Egress model

Every outbound connection from a sandbox is intercepted by the policy engine,
which does one of three things:

- **Allow** — destination + binary match a policy block.
- **Route for inference** — strip caller credentials, inject backend
  credentials, forward to the managed model.
- **Deny** — block and log.

## Policy domains (defense in depth)

| Layer | Protects | When applied |
|-------|----------|--------------|
| Filesystem | Reads/writes outside allowed paths | Locked at sandbox creation |
| Network | Unauthorized outbound connections | Hot-reloadable at runtime |
| Process | Privilege escalation / dangerous syscalls | Locked at sandbox creation |
| Inference | Reroutes model API calls to controlled backends | Hot-reloadable at runtime |

## Lifecycle summary

1. `mise run gateway` — gateway up on the host.
2. `openshell gateway select docker-dev` — CLI points at it.
3. `openshell sandbox create` — driver launches a container.
4. `openshell policy set` — open or tighten access live.
5. `openshell sandbox connect` — work inside the sandbox.

# How-To (commands)

Common tasks. Assumes `mise` is activated so `openshell` is on `PATH`; otherwise
prefix with `./scripts/bin/openshell` from inside the repo.

## Gateway

```sh
mise run gateway                 # build + run the standalone dev gateway (foreground)
openshell gateway list           # list registered gateways
openshell gateway select docker-dev   # set the active gateway
openshell status                 # show active gateway connection status
```

The gateway runs in the foreground. Keep it in its own terminal/tmux pane, or run
the `mise run gateway` task in the background and tail its output.

## Sandboxes

```sh
openshell sandbox create                 # minimal sandbox
openshell sandbox create -- claude       # create and launch an agent (claude/codex/opencode/copilot)
openshell sandbox create --from ollama   # from the community catalog
openshell sandbox create --from ./dir    # from a local Dockerfile (BYOC)
openshell sandbox list                   # list sandboxes
openshell sandbox connect <name>         # SSH into a running sandbox
openshell logs <name> --tail             # stream sandbox logs
```

After creating a sandbox, `docker ps` will show its container. Before that,
`docker ps` is empty even though the gateway is up.

## Providers (credentials)

Providers are named credential bundles injected into sandboxes as env vars at
runtime (never written to the sandbox filesystem).

```sh
openshell provider create --type <type> --from-existing   # from shell env vars
```

Recognized agents (Claude, Codex, OpenCode, Copilot) auto-discover credentials
from your environment (e.g. `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `GITHUB_TOKEN`).

## Policy

Sandboxes start with minimal outbound access. Open access with a YAML policy; the
network/inference sections hot-reload without restart.

```sh
openshell policy set <name> --policy file.yaml --wait
openshell policy get <name>
```

## Inference routing

```sh
openshell inference set --provider <p> --model <m>   # configure inference.local
```

## Terminal UI

```sh
openshell term     # live dashboard for gateways/sandboxes/providers
```

## Quick policy demo (from the repo)

```sh
bash examples/sandbox-policy-quickstart/demo.sh
```

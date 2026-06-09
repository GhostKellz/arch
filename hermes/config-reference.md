# Config Reference — `~/.hermes/config.yaml`

Hermes keeps settings in `~/.hermes/config.yaml` and secrets in `~/.hermes/.env`.
This is the map of the top-level keys and what each controls.

> Grounded in `/data/repo/hermes-agent/hermes_cli/config.py` (DEFAULT_CONFIG and the
> `_KNOWN_ROOT_KEYS` list). Don't hand-edit blind — prefer `hermes config`.

## Editing config the safe way

```bash
hermes config              # view current config
hermes config edit         # open in $EDITOR
hermes config set <key> <value>
hermes config wizard       # guided setup
hermes doctor              # validate after changes
```

Secrets (API keys, tokens) belong in `~/.hermes/.env`, not the YAML. Config values
reference them with `${VAR}` interpolation.

## Top-level keys

These are the known root keys (`_KNOWN_ROOT_KEYS`):

| Key | Controls |
|-----|----------|
| `model` | Primary model id for the main agent loop |
| `providers` | Provider config / ordering for the primary model |
| `fallback_model` / `fallback_providers` | What to fall back to when the primary fails |
| `credential_pool_strategies` | How pooled credentials are selected/rotated (`hermes auth`) |
| `custom_providers` | User-defined OpenAI-compatible endpoints |
| `toolsets` | Which tool groups are enabled |
| `agent` | Iteration budget, API retries, tool enforcement, env probes, timeouts |
| `terminal` | Execution backend (local/docker/ssh), containers, volumes, shell — see [terminal-backends.md](terminal-backends.md) |
| `display` | TUI/CLI interface, themes, tool-progress rendering |
| `compression` | Context compression triggers and limits |
| `context` | Context window management |
| `memory` | Conversation history + memory behavior — see [skills-and-memory.md](skills-and-memory.md) |
| `delegation` | Subagent settings — see [subagents-delegation.md](subagents-delegation.md) |
| `auxiliary` | Secondary models (e.g. vision) + their fallbacks |
| `gateway` | Messaging platform settings (Telegram/Discord/etc.) — see [gateway-and-messaging.md](gateway-and-messaging.md) |
| `sessions` | Session storage/retention |
| `streaming` | Token streaming behavior |
| `updates` | Auto-update behavior |
| `_config_version` | Internal schema version (used by `hermes migrate`) |

Additional nested sections present in DEFAULT_CONFIG worth knowing:

| Key | Controls |
|-----|----------|
| `web` | Search/extraction backends (searxng, native, …) |
| `browser` | CDP, Chromium/Firefox/Camofox, dialog policies |
| `checkpoints` | Filesystem snapshots before destructive ops (max snapshots, auto-prune) |
| `mcp_servers` | MCP server definitions — usually managed via `hermes mcp`, see [mcp-servers.md](mcp-servers.md) |

## Common edits

**Switch the main model** (or use `hermes model` interactively):

```yaml
model: "<provider>/<model-id>"
```

**Add a fallback chain** (also `hermes fallback add/remove/list`):

```yaml
fallback_model: "<cheaper-or-local-model>"
```

**Define a custom OpenAI-compatible provider** (e.g. local vLLM on the 4090):

```yaml
custom_providers:
  local4090:
    base_url: "http://10.0.0.x:8000/v1"
    api_key: "${LOCAL4090_KEY}"
```

**Disable a toolset** you don't want the agent reaching for:

```bash
hermes tools list
hermes tools disable <name>
```

## Profiles

Profiles isolate `memory`, `sessions`, `skills`, and `cron` state for separate agents
(personal vs. a shared team bot). Manage with `hermes profile`. Useful so a Telegram
team bot doesn't share memory with your CLI agent.

## Backup & migrate

```bash
hermes backup              # create/restore config + session backups
hermes migrate             # apply config schema migrations (bumps _config_version)
```

## Don't put these in YAML

- API keys / bot tokens / OAuth secrets → `~/.hermes/.env`.
- Anything you'd be unhappy to see in a git diff. The whole `~/.hermes/` dir is
  personal runtime state, not source control.

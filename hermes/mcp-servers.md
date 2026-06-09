# MCP Servers — Connecting Hermes to External Tools

Hermes speaks the **Model Context Protocol (MCP)**, so it can pull in tools from
external servers — Notion, Linear, GitHub, your internal APIs — and can also expose
*itself* as an MCP server to other clients.

> Grounded in `/data/repo/hermes-agent/hermes_cli/mcp_config.py` and
> `tools/mcp_tool.py`. Run `hermes mcp` with no args for the interactive picker.

## Two transports

| Transport | When | How you add it |
|-----------|------|----------------|
| **HTTP** | Hosted/remote MCP endpoints | `hermes mcp add <name> --url <endpoint>` |
| **stdio** | Local process (npx/python launched per session) | `hermes mcp add <name> --command <cmd> --args <...>` |

You can also install from the Nous-approved catalog by preset/name:

```bash
hermes mcp add <name> --preset <preset>   # known preset, e.g. codex
hermes mcp catalog                         # list curated catalog MCPs
hermes mcp install <name>                  # install a catalog MCP
```

## Command reference

```bash
hermes mcp                 # interactive catalog picker (default)
hermes mcp add <name>      # add + configure a server (with tool discovery)
hermes mcp list            # list configured servers + status
hermes mcp test <name>     # connect temporarily and probe its tools
hermes mcp configure <name># toggle which of the server's tools are enabled
hermes mcp remove <name>   # remove server + clean up OAuth tokens
hermes mcp login <name>    # force OAuth re-auth
hermes mcp serve           # run Hermes ITSELF as an MCP server
```

In chat/gateway, `/reload-mcp` re-reads servers without a restart.

## Where it's stored

MCP servers live in `~/.hermes/config.yaml` under the `mcp_servers:` map. Shape:

```yaml
mcp_servers:
  github:
    command: "npx"                     # stdio transport
    args: ["@modelcontextprotocol/server-github"]
    enabled: true
    env:
      GITHUB_TOKEN: "${GITHUB_TOKEN}"  # env interpolation from ~/.hermes/.env
    tools:
      include: ["create_issue", "search_repos"]   # whitelist (or use exclude:)

  notion:
    url: "https://mcp.notion.example/mcp"          # HTTP transport
    enabled: true
    auth: "oauth"                                  # or "header" (default)
    headers:
      Authorization: "Bearer ${MCP_NOTION_API_KEY}"
```

Key fields:

- `url` **or** `command`+`args` — pick one (HTTP vs stdio).
- `enabled` — flip a server off without deleting it.
- `tools.include` / `tools.exclude` — narrow which tools the agent sees (token-saving
  and safety; do this with `hermes mcp configure`).
- `auth: oauth` — Hermes runs the OAuth flow and stores tokens via its token store
  (`hermes mcp login` to re-auth).
- `headers` / `env` — `${VAR}` interpolates from `~/.hermes/.env`.

## Secrets

- HTTP bearer keys go in `~/.hermes/.env` as `MCP_<SERVERNAME>_API_KEY`.
- OAuth tokens are managed by Hermes' token storage, not the YAML.
- Never commit `~/.hermes/.env`.

## Exposing Hermes as an MCP server

`hermes mcp serve` turns this instance into an MCP endpoint other agents/editors can
call. Pair with the `acp` subcommand if you want editor (ACP) integration instead.

## Tips

- Start with `hermes mcp test <name>` before enabling — it lists the tools the server
  actually exposes so you can decide what to `include`.
- Trim tool lists aggressively. A chatty MCP server can dump dozens of tools into the
  prompt; `configure` to keep only what you use.
- For delegated subagents, MCP tools can be inherited — see
  [subagents-delegation.md](subagents-delegation.md) (`delegation.inherit_mcp_toolsets`).

# Subagents & Delegation — Multi-Agent Work

Hermes can spawn **child agents** to handle focused subtasks. The parent calls a
`delegate_task` tool; each child runs its own agent loop with an isolated context, a
restricted toolset, and its own iteration budget, then returns just a summary.

> Grounded in `/data/repo/hermes-agent/tools/delegate_tool.py`,
> `agent/agent_init.py`, and the `delegation:` config block in
> `hermes_cli/config.py`. In chat, `/agents` (or `/tasks`) shows active children.

## Why delegate

- **Context hygiene** — the child's intermediate tool calls never pollute the
  parent's history. The parent sees only the delegation call and the result.
- **Parallelism** — independent subtasks run concurrently (default 3 at a time).
- **Scoping** — hand a child only the toolsets it needs (e.g. `["web", "browser"]`).

This mirrors the "one orchestrator + researcher + writer + debugger" pattern the
Atlas handbook describes — each with their own memory and skills.

## How a delegation call works

The parent invokes `delegate_task` with roughly:

```
delegate_task(
  task="Research X and return a 5-bullet summary with sources",
  toolsets=["web", "browser"],     # what the child is allowed to use
  context="...extra grounding...", # optional
  role="worker"                    # or "orchestrator" to allow nesting
)
```

Then:

1. The child spawns in a worker thread with a fresh conversation and a focused system
   prompt built from `task`.
2. It inherits the parent's model/provider unless `delegation.model`/`provider`
   override it.
3. It runs the full agent loop, capped by `delegation.max_iterations` and
   `child_timeout_seconds`.
4. The parent blocks until the child finishes, then receives the summary.

### Tools children can never use

By design, child agents are blocked from: `delegate_task` (no recursion unless
orchestrator depth allows), `clarify`, `memory`, `send_message`, and `execute_code`.
This keeps subagents from talking to the user, mutating long-term memory, or running
arbitrary code behind the parent's back.

## Configuration (`delegation:` in `~/.hermes/config.yaml`)

```yaml
delegation:
  model: ""                    # empty = inherit parent's model
  provider: ""                 # empty = inherit parent's provider
  base_url: ""                 # or point children at a direct OpenAI-compatible endpoint
  api_key: ""
  api_mode: ""                 # chat_completions | anthropic_messages | ...

  inherit_mcp_toolsets: true   # keep parent's MCP tools when narrowing toolsets
  max_iterations: 50           # per-child cap, independent of the parent
  child_timeout_seconds: 600   # wall-clock per child (floor 30s)
  reasoning_effort: ""         # empty = inherit parent's level
  max_concurrent_children: 3   # parallel children (floor 1, no ceiling)

  max_spawn_depth: 1           # 1 = flat (default); 2+ = orchestrator trees
  orchestrator_enabled: true   # kill switch for role="orchestrator"
  subagent_auto_approve: false # false = auto-DENY dangerous cmds; true = auto-approve
```

### Knobs that matter most

- **`max_concurrent_children`** — raise it to fan out more research/QA tasks in
  parallel. Your provider rate limits and budget are the real ceiling.
- **`max_spawn_depth`** — keep at `1` for simple worker fan-out. Set `2+` only when
  you want an orchestrator child to itself delegate (agent trees).
- **`subagent_auto_approve`** — leave `false` (safe). Children auto-deny destructive
  commands rather than prompting, so a runaway child can't `rm -rf` unattended.
- **Point children at a cheaper model** — set `delegation.model`/`provider` (or a
  `base_url` to a local endpoint) so bulk subtasks don't burn frontier tokens. A
  local RTX-4090/5090 endpoint is a natural fit — see
  [proxmox-4090-vfio.md](proxmox-4090-vfio.md).

## Local-model delegation idea for our setup

Run the heavy "thinking" parent on a strong API model, but route children to the
local 4090 VFIO endpoint via `delegation.base_url`. Cheap parallel research/QA with
no per-token cost, while the orchestrator stays sharp.

## Watching it run

- `/agents` or `/tasks` in chat — list active children and their tasks.
- Per-child budgets are tracked separately (`agent/iteration_budget.py`), so one
  stuck child won't drain the parent's iteration budget.

## When NOT to delegate

- Tiny tasks — spawn overhead isn't worth it.
- Anything needing the user mid-task — children can't `clarify` or `send_message`.
- Stateful work that must write to long-term `memory` — that's parent-only.

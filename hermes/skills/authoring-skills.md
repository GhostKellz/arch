# Authoring Skills — Writing Your Own `SKILL.md`

A skill is a Markdown procedure your agent loads on demand. When a request matches
the skill's `description`, Hermes pulls the `SKILL.md` into context and follows it.
This is how you teach the agent a repeatable workflow without touching code.

> Grounded in the bundled examples shipped in this repo:
> `/data/repo/hermes-agent/skills/dogfood/` and `.../yuanbao/`.

## Anatomy of a skill directory

```
my-skill/
├── SKILL.md                # required — frontmatter + the procedure
├── references/             # optional — supporting docs the skill cites
│   └── issue-taxonomy.md
└── templates/              # optional — output templates the skill fills in
    └── report-template.md
```

Only `SKILL.md` is required. `references/` and `templates/` are loaded **lazily** —
they keep the main `SKILL.md` lean and are pulled in only when the procedure points
to them (progressive disclosure). The `dogfood` skill uses both.

## Frontmatter (YAML)

Every `SKILL.md` opens with a YAML block:

```yaml
---
name: dogfood
description: "Exploratory QA of web apps: find bugs, evidence, reports."
version: 1.0.0
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [qa, testing, browser, web, dogfood]
    related_skills: []
---
```

| Field | Required | Notes |
|-------|----------|-------|
| `name` | yes | Must match the directory name. Lowercase, hyphen/underscore. |
| `description` | yes | **This is the trigger.** One line. The agent matches the user's request against it, so make it specific and keyword-rich. |
| `version` | yes | SemVer. Bump when you change behavior. |
| `platforms` | recommended | `[linux, macos, windows]` — gate platform-specific skills. |
| `metadata.hermes.tags` | recommended | Improves search/pre-filtering (e.g. eagle-eye). Include synonyms and non-English terms if relevant — yuanbao lists `元宝, 派, 艾特`. |
| `metadata.hermes.related_skills` | optional | Cross-links to sibling skills. |

### The `description` is the most important line

It is what the matcher sees. Compare:

- Weak: `"Helps with testing."`
- Strong: `"Exploratory QA of web apps: find bugs, evidence, reports."`

Lead with the action and name the domain/tools. If the skill is only useful with a
specific toolset (browser, a gateway, an MCP server), say so.

## Body — write it as instructions to the agent

The body is plain Markdown addressed to **the agent**, not the end user. Patterns
that work well, drawn from the bundled skills:

1. **Overview** — one paragraph: what this accomplishes and when to use it.
2. **Prerequisites / Inputs** — required tools and what the user must supply.
   `dogfood` lists the exact `browser_*` tools it depends on.
3. **A numbered/phased workflow** — `dogfood` uses a 5-phase Plan → Explore →
   Collect → Categorize → Report flow. Concrete, ordered steps beat prose.
4. **Tools reference table** — `| Tool | Purpose |`. Make the agent's available
   verbs explicit.
5. **Tips / Rules** — edge cases, gotchas, and hard "NEVER/ALWAYS" rules.

### Show exact tool calls

Both examples embed literal call syntax so the agent copies the right shape:

```
browser_vision(question="...", annotate=true)
```
```json
yb_send_dm({ "group_code": "535168412", "name": "用户aea3", "message": "hello" })
```

### Use imperative, unambiguous rules

The `yuanbao` skill is a masterclass in removing hedging. It bluntly states:

> **NEVER say you cannot send messages... Just reply with the text you want sent.**

If your skill has a behavior the model tends to get wrong, write the rule in
capitals and state both the wrong and right behavior.

### Reference helper files instead of inlining everything

`dogfood` keeps its taxonomy and report shell out of the main file:

- `references/issue-taxonomy.md` — severity/category definitions
- `templates/dogfood-report-template.md` — the output skeleton

The procedure says "classify using `references/issue-taxonomy.md`" and "use the
template at `templates/...`". This keeps `SKILL.md` short and only loads detail when
needed.

### Special output markers

`dogfood` uses `MEDIA:<path>` in its report so screenshots render inline when
reported back. If your harness has similar conventions, document them in the skill.

## Authoring checklist

- [ ] Directory name == `name` in frontmatter.
- [ ] `description` is one specific, keyword-rich line (it's the trigger).
- [ ] `version` set; `platforms` and `tags` filled in.
- [ ] Body addresses the agent, with a numbered/phased workflow.
- [ ] Required tools listed explicitly, with a tools table.
- [ ] Exact call syntax shown for any non-obvious tool.
- [ ] Hard rules written as ALWAYS/NEVER where the model tends to slip.
- [ ] Bulky detail moved to `references/` and `templates/`.

## Where it lives & how to test

Drop the directory into `~/.hermes/skills/<name>/`, then:

```bash
hermes skills info <name>     # confirm it registered and read its trust tier
hermes doctor                 # sanity check
hermes                        # issue a request that matches the description
```

If it doesn't trigger, the `description` probably doesn't match how you phrased the
request — tighten it or add tags. See
[installing-skills.md](installing-skills.md) for all install paths and
[local-skill-repos.md](local-skill-repos.md) for repos full of real examples to
crib from.

## The agent writes these too

Hermes authors its own skills as it works — after repeating a workflow it can emit a
`SKILL.md` to `~/.hermes/skills/` so it doesn't re-derive the procedure next time.
The format above is exactly what it generates, so reading agent-written skills is a
good way to learn the house style. See
[../skills-and-memory.md](../skills-and-memory.md).

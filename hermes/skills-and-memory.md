# Skills & Memory

The learning loop is what makes Hermes "grow with you." This is how it works in
practice and where the files live.

## Skills

Skills are **executable procedures**, stored as markdown in `~/.hermes/skills/`.
Each contains: trigger description, execution steps, tool sequence, required
context, and I/O examples. Unlike systems that just store facts, a skill directly
executes a workflow.

### Lifecycle

1. **Generated** — after a task completes or ~5 similar tool calls, or when a user
   correction teaches a generalizable pattern, the agent writes a new skill.
2. **Prioritized** — later similar requests use the skill, speeding execution.
3. **Patched** — skills found outdated/incomplete/wrong are edited in place.
4. **Curated** — the **Autonomous Curator** reviews agent-created skills,
   consolidates overlaps, and archives stale ones.

### Trust tiers

`Builtin → Official → Trusted → Community`. The Skills Hub has hundreds of
community skills. Our install seeded **74 bundled skills** into `~/.hermes/skills/`.

```bash
hermes skills browse
hermes skills search <term>
hermes skills info <name>
hermes skills install <name>
```

See [essential-skills.md](essential-skills.md) for a day-one set and
[ecosystem-projects.md](ecosystem-projects.md) for notable community skill packs.

## Memory

Memory is intentionally **bounded** to force consolidation and avoid context bloat.

| Layer | Approx. size | File / store | Purpose |
|-------|-------------|--------------|---------|
| Working memory | ~2,200 chars | `~/.hermes/memories/MEMORY.md` | Active context |
| User model | ~1,375 chars | `~/.hermes/memories/USER.md` | Facts/preferences about you |
| Session archive | Unlimited | `~/.hermes/state.db` (FTS5) | Searchable conversation history |

`MEMORY.md`, `USER.md`, and `state.db` are created lazily on first session/first
memory write — `hermes doctor` will note them as "not created yet" until then.

`SOUL.md` (`~/.hermes/SOUL.md`) defines the agent's persona/system prompt and is
seeded at install.

### Unlimited / semantic memory (optional)

Community memory backends plug in for users who want unlimited semantic recall:
**Honcho, Mem0, Hindsight, Supermemory**. These are optional plugins, not required.

## Why bounded memory is a feature

The size caps push the agent to *consolidate* rather than hoard, keeping the active
context sharp while the FTS5 session DB preserves everything for retrieval. The
result is recall without context rot.

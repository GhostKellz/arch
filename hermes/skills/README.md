# Skills — Knowledgebase Section

Everything about Hermes skills: the repos we've cloned locally, how to install/wire
them, and how to author our own.

> **Scope split (no overlap):**
> - This `skills/` section = **our locally cloned repos** at `/data/repo/hermes/`
>   plus practical install/authoring howtos.
> - [`../ecosystem-projects.md`](../ecosystem-projects.md) = the broader **Hermes
>   Atlas** discovery map (community projects we may or may not have cloned).

## Articles

| File | Topic |
|------|-------|
| [local-skill-repos.md](local-skill-repos.md) | Catalog of the ~19 skill/plugin repos cloned at `/data/repo/hermes/` |
| [installing-skills.md](installing-skills.md) | How to install skills/plugins into Hermes (`hermes skills`, `npx skills`, git, taps) |
| [authoring-skills.md](authoring-skills.md) | How skills are structured and how to write your own `SKILL.md` |

## Fast facts

- Installed/created skills live in `~/.hermes/skills/`; plugins in `~/.hermes/plugins/`.
- Our install seeded **74 bundled skills** there already.
- The agent also **writes its own skills** as it learns — see
  [../skills-and-memory.md](../skills-and-memory.md).
- Trust tiers: **Builtin → Official → Trusted → Community.** Vet anything that runs
  code or touches credentials.

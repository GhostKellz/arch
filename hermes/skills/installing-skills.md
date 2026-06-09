# Installing Skills & Plugins

Where they live, and the install methods you'll actually use.

## Locations on disk

| Path | Holds |
|------|-------|
| `~/.hermes/skills/` | Installed + agent-created **skills** (74 bundled here from our install) |
| `~/.hermes/plugins/` | **Plugins** (eagle-eye, prompt-optimizer, icarus, etc.) |
| `~/.hermes/prisms/` | Prisms (super-hermes analytical lenses), if installed |

## Method 1 — Hermes Skills Hub (preferred)

```bash
hermes skills browse            # explore the hub
hermes skills search <term>     # keyword search
hermes skills info <name>       # read details + trust tier BEFORE installing
hermes skills install <name>    # install
```

Install straight from a GitHub path (e.g. a hub repo):

```bash
hermes skills install github:amanning3390/hermeshub/skills/<name>
```

## Method 2 — Taps (third-party skill sources)

```bash
hermes skills tap add <owner/repo>     # register a source, e.g. mag3nt-com/openclaw-skill
```

## Method 3 — `npx skills add` (agentskills.io standard)

Many community repos publish via the cross-agent `skills` CLI:

```bash
npx skills add mukul975/Anthropic-Cybersecurity-Skills
npx skills add wondelai/skills
npx skills add ZeroPointRepo/youtube-skills --skill youtube-full
```

These target the agentskills.io `SKILL.md` layout that Hermes also understands.

## Method 4 — Manual git clone

For repos without a packaged installer, drop them into the skills dir:

```bash
git clone <repo> ~/.hermes/skills/<name>
```

Some repos ship `install.sh` (eagle-eye, super-hermes, hermes-skill-factory,
SkillClaw) — run those instead; they wire up plugin hooks/config for you.

## Method 5 — Plugins

```bash
hermes plugins install <owner/repo>     # e.g. Sahil-SS9/hermes-multichannel-prompt-optimizer
```

Then enable in `~/.hermes/config.yaml` if the plugin's README says so. Plugins that
add hooks (pre-LLM/post-LLM/session) generally need an enable flag.

## Wiring our local clones in

Our repos are already on disk at `/data/repo/hermes/`. To use one without
re-downloading, either run its `install.sh`, or symlink it into the skills dir:

```bash
ln -s /data/repo/hermes/<repo> ~/.hermes/skills/<repo>
```

> Symlinking keeps a single source of truth and lets you `git pull` the repo in
> place. Use a real copy instead if a skill expects to write into its own dir.

## After installing

```bash
hermes skills info <name>     # confirm it registered
hermes doctor                 # sanity check
hermes                        # the skill triggers when its description matches your request
```

## Safety

- Prefer **Builtin/Official/Trusted** tiers for anything sensitive.
- Read `SKILL.md` / README before installing community skills — a skill is someone
  else's procedure that your agent will execute.
- Network/payment skills (mag3nt-pay, skilldock, SkillClaw server) and anything
  running shell/scripts deserve a real look first.

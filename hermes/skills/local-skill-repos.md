# Local Skill Repos — `/data/repo/hermes/`

Catalog of the skill/plugin repositories cloned on this box at `/data/repo/hermes/`
(distinct from `/data/repo/hermes-agent/`, which is the agent itself). ~19 repos,
~950+ skills represented. This is the **practical, locally-grounded** companion to
the [Atlas discovery map](../ecosystem-projects.md).

> Install paths vary per repo (see [installing-skills.md](installing-skills.md)).
> Common patterns: `hermes skills install …`, `npx skills add <owner/repo>`, git
> clone into `~/.hermes/skills/`, or `hermes plugins install …` for plugins.

## A. Multi-skill collections

| Repo | What it is | Install |
|------|-----------|---------|
| **Anthropic-Cybersecurity-Skills** | 754 skills across 26 security domains (threat hunting, DFIR, malware, cloud, OT/ICS), each mapped to MITRE ATT&CK / NIST CSF / ATLAS / D3FEND / NIST AI RMF. Markdown + YAML frontmatter. | `npx skills add mukul975/Anthropic-Cybersecurity-Skills` or clone into `~/.hermes/skills/` |
| **open-design** | Agent-native design system: 100+ skills, 150 `DESIGN.md` systems, 261 plugins; web/mobile/desktop prototypes, decks, HyperFrames (HTML→MP4). Also a CLI + MCP server. | Desktop app, or `curl https://open-design.ai/install.sh \| sh -s hermes` |
| **skills** (Wondel.ai) | 37 business/product framework skills (JTBD, CRO, Refactoring UI, Lean Startup, Clean Code, DDD, DDIA…), 8 collections. | `npx skills add wondelai/skills` (selective installs) |
| **youtube-skills** | 12 skills: transcripts, captions, search, channel/playlist data (TranscriptAPI backend, free tier). | `npx skills add ZeroPointRepo/youtube-skills` (or `--skill youtube-full`) |
| **hermes-agent-idea-workflow** | 4 chained skills: idea → design doc → UI brief → implementation spec → build handoff. | Copy dirs into `~/.hermes/skills/idea-workflow/` |

## B. Single skills

| Repo | What it is | Install |
|------|-----------|---------|
| **avoid-ai-writing** | Detects/rewrites "AI-isms" (109-pattern detector, 0–100 scoring, detect/rewrite/in-place modes). Node detector + Markdown skill. | Clone into `~/.hermes/skills/`, or marketplace `curl \| sh` |
| **drawio-skill** | Natural language → `.drawio` XML; exports PNG/SVG/PDF; visualizes codebases (import graphs, class hierarchies); 10k+ shapes. Python helpers + draw.io CLI. | `npx skills add Agents365-ai/365-skills -g` or git clone |
| **openclaw-skill** (mag3nt-pay) | Teaches the agent to autonomously pay HTTP 402 APIs (x402/MPP/AP2/Pay Link) via Mag3nt virtual cards. | `hermes skills tap add mag3nt-com/openclaw-skill` |

## C. MCP / standards tooling

| Repo | What it is | Install |
|------|-----------|---------|
| **Agentic-MCP-Skill** | MCP server wrapper with 3-layer progressive disclosure (metadata→tools→schemas); claims ~86% token reduction. Node/TS. | `npm i -g @cablate/agentic-mcp` or clone |
| **pydantic-ai-skills** | Implements the Agent Skills spec for Pydantic AI via tool-calling; SKILL.md-compatible progressive disclosure. Python. | `pip install pydantic-ai-skills` |
| **skilldock.io** | OpenAPI-driven Python SDK + CLI for the SkillDock marketplace (search/install/upload, dependency resolution, payments). | `pip install skilldock` |

## D. Plugins / meta-tools (enhance the agent itself)

| Repo | What it is | Install |
|------|-----------|---------|
| **eagle-eye** | 5-layer skill pre-filter (hard triggers → FTS5 BM25 → synonyms → embeddings → RRF) that narrows 50+ skills to top-5, saving 5–10k tokens/turn. Python. | `git clone` + `bash scripts/install.sh` |
| **hermes-multichannel-prompt-optimizer** | Rewrites prompts before they hit the LLM across CLI/TUI/Discord/Telegram; model-aware; logs to SQLite. Python. | `hermes plugins install Sahil-SS9/hermes-multichannel-prompt-optimizer` |
| **hermes-skill-factory** | Watches workflows, detects repeatable patterns, proposes new skills (generates SKILL.md + plugin.py). | `bash install.sh` or copy to `~/.hermes/skills/meta/` + `~/.hermes/plugins/` |
| **icarus-plugin** | Cross-instance shared memory + training-data extraction + model-replacement pipeline (16 tools, 4 hooks). Needs Hermes ≥0.6.0. | clone → `~/.hermes/plugins/icarus/` |
| **super-hermes** | Generates analytical "prisms" before code/text analysis and reports blind spots; ships 7 prisms + 5 slash commands. | `bash install.sh` (skills→`~/.hermes/skills/`, prisms→`~/.hermes/prisms/`) |
| **SkillClaw** | Collective skill evolution: client proxy + optional server that dedupes/improves/merges skills across agents/devices/teams. Python. | `bash scripts/install_skillclaw.sh` |
| **maestro** | Local-first Rust harness for agent-built codebases — durable features/tasks/QA/self-improvement tracked as files under `.maestro/`, proof-gated transitions. | `cargo install --git https://github.com/ReinaMacCredy/maestro --locked` |

## E. Hubs / registries

| Repo | What it is | Notes |
|------|-----------|-------|
| **hermeshub** | Curated marketplace (22 vetted skills, automated security scanning, creator payouts, x402/MPP payments). React + Vercel + Neon Postgres. | Browse `hermeshub.xyz`; install via `hermes skills install github:amanning3390/hermeshub/skills/<name>` |
| **open-design** | Also acts as a design-system hub (150 `DESIGN.md` + 261 plugins). | See section A |

## What's worth wiring into our setup first

Given our work (security testing, dev, automation):

- **Anthropic-Cybersecurity-Skills** — directly relevant to authorized security work.
- **eagle-eye** — practical token saver once we have 50+ skills installed.
- **drawio-skill** — fast architecture/codebase diagrams.
- **super-hermes** / **hermes-skill-factory** — meta-tools that improve analysis +
  auto-grow our skill library.
- **maestro** — if we want a durable, git-reviewable harness for agent-built code.

> Before installing any of these: `hermes skills info <name>` (for hub skills) and
> skim the repo's own README/SKILL.md. Several run code or open network/payment
> paths (mag3nt-pay, skilldock, SkillClaw server) — vet accordingly.

## Caveat

These are community repos cloned to disk; versions and install commands drift.
Treat each repo's own README as the source of truth at install time. Confirm Hermes
compatibility (some target OpenClaw/Cursor/Claude Code too).

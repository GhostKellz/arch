# Ecosystem & Notable Projects

Curated from [Hermes Atlas](https://hermesatlas.com) — the community map of the
Hermes Agent ecosystem (built by @ksimback; not officially affiliated with Nous).
Atlas security-reviews repos before inclusion and has an "Ask the Atlas" RAG bot.

> The live, authoritative list is the Atlas itself — this is a snapshot of projects
> we flagged as relevant. Verify trust/security before installing anything that runs
> code or touches credentials.

## Official Nous Research projects

| Project | What it is |
|---------|-----------|
| [Hermes-Function-Calling](https://hermesatlas.com/projects/NousResearch/Hermes-Function-Calling) | Framework for the Hermes Pro LLM to execute schema-based function calls via recursive tool-call loops; foundational toolkit Hermes Agent builds on |
| [atropos](https://hermesatlas.com/projects/NousResearch/atropos) | Environment microservice framework for **async RL** on LLMs — standardized trajectory collection/eval across interactive settings |
| [hermes-agent-self-evolution](https://hermesatlas.com/projects/NousResearch/hermes-agent-self-evolution) | Evolutionary optimization of Hermes' skills/prompts/code using DSPy + GEPA; analyzes traces, proposes improvements, guardrailed, no GPU training |

## Interfaces & control surfaces

| Project | What it is |
|---------|-----------|
| [hermes-telegram-miniapp](https://hermesatlas.com/projects/clawvader-tech/hermes-telegram-miniapp) | React terminal-style **Telegram Mini App**: streaming chat, system monitoring, cron management, agent spawning; dual-layer auth |
| [hermes-control-interface](https://hermesatlas.com/projects/xaspx/hermes-control-interface) | Self-hosted **web dashboard** centralizing agents, files, system metrics, and MCP servers; password-auth |
| [super-hermes](https://hermesatlas.com/projects/Cranot/super-hermes) | Skill registry that has the agent write custom "prisms" (thinking frameworks) before deep code/document inspection |
| [hermes-multichannel-prompt-optimizer](https://hermesatlas.com/projects/Sahil-SS9/hermes-multichannel-prompt-optimizer) | Plugin that rewrites prompts for clarity/token-savings across CLI/TUI/Discord/Telegram, tailored to the target model |

## Skill packs & meta-skills

| Project | What it is |
|---------|-----------|
| [nexu-io/open-design](https://hermesatlas.com/projects/nexu-io/open-design) | Local-first, open-source **Claude Design alternative**; 259+ design skills, MCP integration with 21+ agent CLIs; web/desktop/mobile prototypes |
| [mukul975/Anthropic-Cybersecurity-Skills](https://hermesatlas.com/projects/mukul975/Anthropic-Cybersecurity-Skills) | **754 cybersecurity skills** across 26 domains, mapped to MITRE ATT&CK, NIST CSF 2.0, MITRE ATLAS, D3FEND, NIST AI RMF |
| [black-forest-labs/skills](https://hermesatlas.com/projects/black-forest-labs/skills) | Official **FLUX** image-generation skills; structured JSON prompting, text→image / image→image |
| [Agents365-ai/drawio-skill](https://hermesatlas.com/projects/Agents365-ai/drawio-skill) | Natural language → **draw.io** diagram XML (UML, ERD presets) |
| [AMAP-ML/SkillClaw](https://hermesatlas.com/projects/AMAP-ML/SkillClaw) | Background **skill dedup + quality-improvement** evolution loops |
| [Romanescu11/hermes-skill-factory](https://hermesatlas.com/projects/Romanescu11/hermes-skill-factory) | Meta-skill that monitors workflows to **auto-propose reusable skills** |
| [ZeroPointRepo/youtube-skills](https://hermesatlas.com/projects/ZeroPointRepo/youtube-skills) | Extract **transcripts/captions/timestamps** from YouTube |

## Standards & MCP tooling

| Project | What it is |
|---------|-----------|
| [cablate/Agentic-MCP-Skill](https://hermesatlas.com/projects/cablate/Agentic-MCP-Skill) | Experimental TS client with **3-layer progressive disclosure** for MCP (loads metadata/tools/schemas only when needed) |
| [PederHP/skillsdotnet](https://hermesatlas.com/projects/PederHP/skillsdotnet) | **C#/.NET** implementation of the agentskills.io standard; `skill://` URIs, integrates with Microsoft.Extensions.AI |

## Skill-related notes

- Many packs follow the **agentskills.io** standard, increasingly bridged into
  **MCP** — relevant if we wire Hermes to MCP servers (`[mcp]` extra is installed).
- Security-domain packs (cybersecurity-skills, security-audit builtin) are useful
  for our authorized testing work — see [essential-skills.md](essential-skills.md).
- **Trust tiers still apply** to community repos. Read the source / `hermes skills
  info` before installing; prefer Builtin/Official/Trusted for anything sensitive.

## The Atlas itself

- Map: https://hermesatlas.com — 80+ quality-filtered repos across 12 categories,
  live GitHub star counts, trending badges, "Ask the Atlas" RAG chatbot.
- Top skills list: https://hermesatlas.com/lists/top-skills

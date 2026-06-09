# Essential Skills to Install First

Install format: `hermes skills install <name>`. Discover more with
`hermes skills browse` / `search` / `info`.

## Day-one set (from the Atlas guide)

| Skill | Tier | What it does |
|-------|------|--------------|
| **llm-wiki** | builtin | Karpathy-style condensed reference for any topic; quick primers |
| **gstack** | trusted | Browser automation, QA testing, design review; website dogfooding |
| **OpenAI taps** | trusted | Exposes OpenAI function-calling primitives as tools across providers |
| **Manim** | official | Generates mathematical animations from text descriptions |
| **security-audit** | official | Scans a repo for common vulnerabilities — run before shipping public code |

```bash
hermes skills install llm-wiki
hermes skills install security-audit
# …etc
```

## Discovering more

```bash
hermes skills browse           # full hub
hermes skills search <term>    # keyword search
hermes skills info <name>      # details before installing
```

Tiers: **builtin → official → trusted (verified contributors) → community.** Prefer
higher tiers for anything that touches credentials or runs code.

## Trending community skill packs

Pulled from the Atlas top-skills list — see
[ecosystem-projects.md](ecosystem-projects.md) for full descriptions:

- **nexu-io/open-design** — local-first Claude Design alternative, 259+ design skills
- **mukul975/Anthropic-Cybersecurity-Skills** — 754 cybersecurity skills mapped to
  MITRE ATT&CK / NIST / ATLAS / D3FEND
- **Agents365-ai/drawio-skill** — natural language → draw.io diagrams (UML, ERD)
- **AMAP-ML/SkillClaw** — background skill dedup + quality-improvement loops
- **Romanescu11/hermes-skill-factory** — meta-skill that proposes reusable skills
  from your workflows
- **ZeroPointRepo/youtube-skills** — transcripts/captions/timestamps from YouTube
- **black-forest-labs/skills** — official FLUX image-generation skills

> Security note: every install runs someone else's procedure. Stick to higher trust
> tiers, and read `hermes skills info <name>` before installing community skills —
> several community hubs advertise automated security scanning, but verify anyway.

# Resources & Links

## Official (Nous Research)

- **Docs home:** https://hermes-agent.nousresearch.com/docs
- **Quickstart:** https://hermes-agent.nousresearch.com/docs/getting-started/quickstart
- **Termux guide:** https://hermes-agent.nousresearch.com/docs/getting-started/termux
- **Landing page:** https://hermes-agent.nousresearch.com/
- **GitHub:** https://github.com/NousResearch/hermes-agent
- **License:** MIT

### Machine-readable doc dumps (for feeding an LLM)

- `/llms.txt` — curated index of every doc page with short descriptions (~17 KB,
  safe to load into context). Also at `/docs/llms.txt`.
- `/llms-full.txt` — every doc page concatenated into one markdown file (~1.8 MB)
  for one-shot ingestion. Also at `/docs/llms-full.txt`.

> Note: these resolved inconsistently when we tried them (a 404 on the bare
> `/llms.txt`). If one path 404s, try the `/docs/`-prefixed variant.

## Community

- **Hermes Atlas** (ecosystem map + "Ask the Atlas" RAG bot): https://hermesatlas.com
  - Top skills: https://hermesatlas.com/lists/top-skills
  - Guide: https://hermesatlas.com/guide/
  - Install guide: https://hermesatlas.com/guide/install/
  - Built by @ksimback — community project, **not** officially affiliated with Nous.
- **Community docs** (mudrii): https://github.com/mudrii/hermes-agent-docs
- See [ecosystem-projects.md](ecosystem-projects.md) for notable repos/skill packs.

## Local paths on our systems

| Path | What |
|------|------|
| `/data/repo/hermes-agent` | Cloned source repo (native dev install lives here) |
| `/data/repo/hermes-agent/venv` | uv-managed Python 3.11 venv |
| `~/.local/bin/hermes` | CLI symlink (→ `venv/bin/hermes`) |
| `~/.hermes/` | Runtime data root |
| `~/.hermes/config.yaml` | Config (non-secret) |
| `~/.hermes/.env` | Secrets / API keys |
| `~/.hermes/skills/` | Installed + agent-created skills |
| `~/.hermes/memories/` | `MEMORY.md`, `USER.md` |
| `~/.hermes/state.db` | FTS5 session archive |
| `~/.hermes/SOUL.md` | Persona / system prompt |
| `~/arch/hermes/` | **This knowledgebase** |

## Useful repo files

| File | What |
|------|------|
| `setup-hermes.sh` | Native dev installer (what we used) |
| `docker-compose.yml` | Gateway + dashboard deploy (host networking) |
| `Dockerfile` | Multi-stage image (Debian, Python 3.13, Node 22, s6-overlay) |
| `.env.example` | Extensive provider/key template |
| `cli-config.yaml.example` | Full config reference |
| `flake.nix` / `.envrc` | Nix flake dev env (we don't use it — see install notes) |
| `CONTRIBUTING.md` / `AGENTS.md` | Architecture + dev process |

## Key facts to remember

- Requires Python **≥3.11, <3.14** — Arch's 3.14 is too new; uv provisions 3.11.
- Model needs **≥64,000 tokens** of context.
- Two entry points: `hermes` (terminal) and the **gateway** (messaging).
- Memory/skills live in `~/.hermes/`, decoupled from the model — swap models freely.
- Check the installed version with `hermes version` (don't hardcode it in notes).

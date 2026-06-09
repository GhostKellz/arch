# Models & Providers

Switch any time with `hermes model` (interactive). Config lands in
`~/.hermes/config.yaml`; secrets in `~/.hermes/.env`. No code changes, no lock-in —
that's the harness-engineering payoff (see [overview.md](overview.md)).

## The one hard rule

**The model must expose ≥ 64,000 tokens of context.** Below that, Hermes won't run
reliably. Tool-calling reliability is the other practical gate: small models
(Gemma 2B, Llama 8B) fail multi-step workflows; use frontier or strong mid-tier
models for real agent work.

## Provider options

18+ providers supported, including:

- **Nous Portal** — one subscription routes across Claude, GPT, GLM, MiniMax, Nous
  models. Easiest path (`hermes setup --portal`).
- **Anthropic** (Claude), **OpenAI** (GPT), **OpenRouter** (200+ models),
  **z.AI/GLM**, **MiniMax**, **DeepSeek**, **Google Gemini**, **NovitaAI**,
  **NVIDIA NIM**, **Kimi/Moonshot**, **Hugging Face**, **Azure OpenAI**, **Bedrock**.
- **Local** — Ollama, LM Studio, vLLM, or any OpenAI-compatible endpoint.

## Cost tiers (rough)

| Tier | Examples | Cost |
|------|----------|------|
| Frontier | Claude, GPT | ~$100+/mo at volume |
| Mid-tier | GLM, MiniMax, DeepSeek | $–$$ |
| Local | Ollama / vLLM | Free (hardware only) |
| Portal | Nous Portal | Flat monthly across providers |

## Local inference

Offline operation works with Ollama / LM Studio / vLLM, but effectiveness degrades
as tool-calling complexity rises. Single-shot chat/coding is fine; long multi-step
automation wants a stronger model.

For a recommended local tool-calling model, Qwen 2.5 Coder 32B is a common pick.
Mind the 64k context floor — set the model's context window accordingly.

**Pointing Hermes at a local endpoint:** choose the local/OpenAI-compatible option
in `hermes model` and give it the base URL (e.g. `http://localhost:11434/v1` for
Ollama, or your vLLM server). For our GPU box serving this over the network, see
[proxmox-4090-vfio.md](proxmox-4090-vfio.md).

## Switching mid-stream

```bash
hermes model      # re-pick provider/model interactively
```

Because memory and skills live in `~/.hermes/` (not tied to the model), switching
providers keeps your accumulated context and learned skills intact.

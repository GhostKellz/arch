# Hermes Integration

How this Ollama instance plugs into the Hermes agent CLI.

> STATUS: Ollama side is ready (64k context served, OpenAI-compatible endpoint at
> `http://127.0.0.1:11434`). The Hermes `config.yaml` wiring below is **not yet
> applied** — documented here as the intended setup.

## Provider priority

Hermes uses a primary model plus an ordered fallback chain. Intended order:

1. **Claude Opus 4.8** — default / primary brain
2. **GPT-5.5 (Codex)** — second
3. **Ollama (`qwen3-coder:30b`, 64k)** — last-resort local fallback

Ollama is the **3rd** entry only — never the default. A 24–30B local model won't
match Claude on complex orchestration; its value is high-volume, zero-token-cost
grunt work and as a fallback when the cloud providers are unavailable.

## Why the 64k context work was required

Hermes hard-rejects any model serving < 64,000 tokens of context. Ollama's default
(~4096) fails that gate, so `OLLAMA_CONTEXT_LENGTH=65536` had to be set first (see
`context-length.md`). Hermes reads the served context from the loaded model's
config, so once Ollama serves 64k, Hermes detects it automatically.

## Config schema notes

- Custom providers live under `providers:` / `custom_providers:` in
  `~/.hermes/config.yaml`. A custom entry is `name` + `base_url`; transport is
  forced to `openai_chat` (Ollama's `/v1` is OpenAI-compatible).
- Fallbacks live in the top-level `fallback_providers:` list; entries are tried in
  order.
- Ollama's `/v1/models` does **not** report context length — Hermes resolves it
  from the loaded model, which is why serving 64k matters.

## Intended config (to apply)

Custom provider for Ollama:

```yaml
custom_providers:
  - name: ollama
    base_url: http://127.0.0.1:11434/v1
```

Fallback chain (Ollama last):

```yaml
fallback_providers:
  - provider: anthropic        # Claude Opus 4.8 (primary)
  - provider: openai-codex     # GPT-5.5
  - provider: ollama           # qwen3-coder:30b, local last resort
    model: qwen3-coder:30b
```

> Verify exact key names against the live `hermes_cli/providers.py` /
> `fallback_cmd.py` schema before applying — the repo is the source of truth.

## Quick connectivity check

```bash
# OpenAI-compatible endpoint Hermes will use
curl -s http://127.0.0.1:11434/v1/models | python3 -m json.tool
```

## Delegation pattern

Keep Claude Max as the primary brain; use a local model (`qwen3-coder` or
`devstral`) as a fallback + delegation target for cheap parallel grunt work
(research/QA subagents) at zero token cost — not as a Claude replacement. See the
project's `subagents-delegation.md` (`delegation.base_url` pattern).

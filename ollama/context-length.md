# Context Length (the 64k requirement)

## TL;DR

Ollama's default served context is ~4096 tokens. Agent harnesses (Hermes,
OpenCode, Cursor-style tools) burn 10–20k tokens on system prompt + tool schemas
**before** the user says anything. At 4096 the model never sees the full
instructions/tools, so it flails, ignores tools, or loops — with **no error**.
This is the silent killer of local models in agent harnesses.

Fix: serve a large context globally.

```ini
# in /etc/systemd/system/ollama.service.d/override.conf
Environment="OLLAMA_CONTEXT_LENGTH=65536"
```

`65536` (64k) clears Hermes' hard 64k floor with headroom.

## Why this value

- Hermes **hard-rejects** any model serving < 64,000 tokens of context.
- The models themselves (qwen3, etc.) support large contexts, but Ollama won't
  *serve* them that large until told to via `OLLAMA_CONTEXT_LENGTH`.
- `65536` = 64 Ki, just over the floor, round power of two.

## VRAM cost

Bigger context = bigger KV cache resident in VRAM. This is why the
`OLLAMA_KV_CACHE_TYPE=q8_0` + `OLLAMA_FLASH_ATTENTION=1` settings matter — they
roughly halve KV-cache VRAM, which is what makes 64k fit on a 32 GB card.

Measured (`qwen3-coder:30b`, Q4_K_M, at 64k):

| Metric | Value |
|--------|-------|
| Context served | 65536 |
| Resident VRAM | ~25 GB |
| Fit on RTX 5090 (32 GB) | Yes, with headroom |
| Fit on 24 GB cards (4090 / 3070) | Tight-to-impossible at 64k |

> When delegating to the 24 GB Proxmox boxes (PVE3 4090, PVE4 3070), either use a
> smaller model or a smaller per-request `num_ctx`. 64k + a 30B model will not fit
> in 24 GB.

## Verifying the served context

```bash
# warm a model
curl -s http://localhost:11434/api/generate \
  -d '{"model":"qwen3-coder:30b","prompt":"hi","stream":false,"keep_alive":"5m"}' >/dev/null

# check the loaded context window
curl -s http://localhost:11434/api/ps | python3 -c \
  "import sys,json; [print(m['name'], m.get('context_length')) for m in json.load(sys.stdin)['models']]"
# expect: qwen3-coder:30b 65536
```

If `context_length` shows `4096`, the env var didn't take — re-check
`systemctl show ollama -p Environment` and that the service was restarted.

## Per-request override

`OLLAMA_CONTEXT_LENGTH` sets the **default**. A client can still request a
smaller window per call via `options.num_ctx` (useful on the 24 GB boxes):

```json
{ "model": "qwen3-coder:30b", "options": { "num_ctx": 16384 } }
```

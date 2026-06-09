# Model Inventory & Selection

Installed models on `/data/ollama` (~176 GB total). Sizes are on-disk.

| Model | Size | Role |
|-------|------|------|
| `qwen3-coder:30b` | 18.6 GB | **Primary agent driver** — agentic coding + tool use |
| `qwen3-vl:30b` | 19.6 GB | Vision-language (auxiliary vision model, not main loop) |
| `qwen3.6:27b` | 17.4 GB | General |
| `qwen3.6:latest` | 23.9 GB | General (larger tag) |
| `deepseek-r1:32b` | 19.9 GB | Reasoning (emits `<think>`) |
| `gemma3:27b` | 17.4 GB | General |
| `mistral-small3.2:24b` | 15.2 GB | Reliable general tool-caller |
| `devstral:24b` | 14.3 GB | Tool-calling tuned for agent harnesses |
| `codestral:22b` | 12.6 GB | Code completion / FIM |
| `deepseek-coder-v2:16b` | 8.9 GB | Code completion / FIM |
| `qwen3:14b` | 9.3 GB | General, lighter tool-calling |
| `qwen3:8b` | 5.2 GB | General, light |
| `llama3.1:8b` | 4.9 GB | General, light |
| `llama3.2:1b` | 1.3 GB | Tiny / draft |
| `nomic-embed-text:latest` | 0.3 GB | Embeddings |

## Choosing a model to drive an agent harness

Two things sink local models in agent harnesses (Hermes, OpenCode):

1. **Context starvation** — fixed globally via `OLLAMA_CONTEXT_LENGTH=65536`
   (see `context-length.md`).
2. **Tool-calling capability** — the harness drives everything through structured
   tool/function calls. A model that does unreliable tool-calling, or a reasoning
   model that wraps output in `<think>` tags, breaks the harness's parser. This is
   a model-choice problem, not a config one.

### Recommended for driving the loop

| Model | Why |
|-------|-----|
| `qwen3-coder:30b` | Built for agentic coding + tool use. Best all-round local driver. |
| `devstral:24b` | Mistral model specifically tuned for tool-calling in agent harnesses. |
| `mistral-small3.2:24b` | Solid, reliable general tool-caller. |
| `qwen3:14b` | Good tool-calling, lighter / faster. |

### Avoid for driving the loop

| Model | Reason |
|-------|--------|
| `deepseek-r1:32b` | Reasoning model, emits `<think>`, flaky tool-calling in harnesses. |
| `gemma3:27b` | Weak/no native tool-calling. |
| `codestral:22b`, `deepseek-coder-v2:16b` | FIM/completion-oriented, not agentic. |
| `qwen3-vl:30b` | Vision model — use as an auxiliary vision model, not the main loop. |

## Bulk re-pull

```bash
for m in nomic-embed-text:latest llama3.2:1b llama3.1:8b qwen3:8b qwen3:14b \
         deepseek-coder-v2:16b codestral:22b devstral:24b mistral-small3.2:24b \
         gemma3:27b qwen3.6:27b qwen3-coder:30b qwen3-vl:30b deepseek-r1:32b; do
  ollama pull "$m"
done
```

## Inspect

```bash
ollama list            # installed
ollama ps              # loaded + VRAM split
ollama show <model>    # template, params, context window
```

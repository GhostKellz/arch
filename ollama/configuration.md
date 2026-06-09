# Ollama Configuration

Authoritative reference for this workstation's Ollama service config. All settings
are applied via a **systemd drop-in**, never by editing the packaged unit (the
drop-in survives `ollama-cuda` package updates).

## Service facts

| Item | Value |
|------|-------|
| Package | `ollama-cuda` (extra repo) |
| Version | 0.30.6 (auto-updates with pacman) |
| Service user / group | `ollama` / `ollama` |
| Packaged unit | `/usr/lib/systemd/system/ollama.service` |
| Drop-in (our config) | `/etc/systemd/system/ollama.service.d/override.conf` |
| Models dir | `/data/ollama` (2 TB NVMe) |
| API endpoint | `http://127.0.0.1:11434` |

## The drop-in

`/etc/systemd/system/ollama.service.d/override.conf`:

```ini
[Service]
# Models stored on the 2TB NVMe at /data
Environment="OLLAMA_MODELS=/data/ollama"

# Default served context window (Hermes requires >=64k)
Environment="OLLAMA_CONTEXT_LENGTH=65536"

# --- Performance tuning (RTX 5090, 32GB VRAM) ---
# Flash attention: faster + lower VRAM on attention
Environment="OLLAMA_FLASH_ATTENTION=1"
# Quantize KV cache to q8_0 (requires flash attention) - big VRAM savings, critical at 64k ctx
Environment="OLLAMA_KV_CACHE_TYPE=q8_0"
# Keep small models (e.g. embeddings) resident alongside one large model
Environment="OLLAMA_MAX_LOADED_MODELS=2"
# Concurrent requests per loaded model
Environment="OLLAMA_NUM_PARALLEL=2"
# Keep models hot for 30m instead of unloading after 5m
Environment="OLLAMA_KEEP_ALIVE=30m"
# Local only; change to 0.0.0.0:11434 to expose to LAN/Proxmox
Environment="OLLAMA_HOST=127.0.0.1:11434"
```

## Environment variable reference

| Variable | Value | Purpose |
|----------|-------|---------|
| `OLLAMA_MODELS` | `/data/ollama` | Blob + manifest store on the 2 TB NVMe. **This is the models dir itself**, not a parent — blobs live at `/data/ollama/blobs`, manifests at `/data/ollama/manifests`. |
| `OLLAMA_CONTEXT_LENGTH` | `65536` | Default served context. Without it Ollama defaults to ~4096, which silently breaks agent harnesses. See `context-length.md`. |
| `OLLAMA_FLASH_ATTENTION` | `1` | Faster attention, lower VRAM. **Required** for q8_0 KV cache. |
| `OLLAMA_KV_CACHE_TYPE` | `q8_0` | Quantizes the KV cache to 8-bit — roughly halves KV-cache VRAM vs f16 with negligible quality loss. Critical at 64k context. |
| `OLLAMA_MAX_LOADED_MODELS` | `2` | Lets a small model (e.g. `nomic-embed-text`) stay resident next to one large model. Two ~30B models won't co-reside in 32 GB regardless. |
| `OLLAMA_NUM_PARALLEL` | `2` | Concurrent requests per loaded model. |
| `OLLAMA_KEEP_ALIVE` | `30m` | Keep models hot for 30 min instead of unloading after 5 min. |
| `OLLAMA_HOST` | `127.0.0.1:11434` | Bind address. Set `0.0.0.0:11434` to expose to LAN / Proxmox cluster. |

## Applying changes

```bash
sudo systemctl daemon-reload
sudo systemctl restart ollama
# verify the env actually took:
systemctl show ollama -p Environment
```

> WARNING: When editing the drop-in, edit the **existing** file — do not overwrite
> it wholesale. A blind `tee > override.conf` that omits a line silently drops that
> setting (this is exactly how `OLLAMA_MODELS` and the perf block were once lost;
> see `troubleshooting.md`). Always re-read the file first, then append/modify.

## Permissions

The models dir is owned by the service user; `/data` must be world-traversable so
`ollama` can reach it:

```bash
sudo chown -R ollama:ollama /data/ollama
# /data should be drwxrwxr-x
```

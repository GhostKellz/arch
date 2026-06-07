# Ollama — Native Arch Setup (RTX 5090)

Native install of Ollama on this Arch/CachyOS workstation, replacing the previous
Docker container. Native was chosen for direct Blackwell GPU access (no
`nvidia-container-toolkit` layer), simpler driver alignment, and lower latency.

## System

| Component | Value |
|-----------|-------|
| GPU       | NVIDIA RTX 5090 (Blackwell, sm_120 / compute 12.0), 32 GB VRAM |
| Driver    | 610.43.02 (open/beta) |
| CUDA      | 13.3 (Ollama uses `cuda_v13` libdir) |
| Package   | `ollama-cuda` (extra repo) |
| Ollama    | 0.30.5 |
| Kernel    | CachyOS LTO |

## Install

```bash
sudo pacman -S ollama-cuda
```

Use `ollama-cuda`, not plain `ollama` (which is CPU-only).

## Paths

| Item | Path |
|------|------|
| Models (blobs + manifests) | `/data/ollama` (2 TB NVMe, `nvme1n1p2`) |
| Service user | `ollama` (uid/gid 944) |
| systemd unit | `/usr/lib/systemd/system/ollama.service` |
| Override (our config) | `/etc/systemd/system/ollama.service.d/override.conf` |

The models dir is owned by the service user:

```bash
sudo chown -R ollama:ollama /data/ollama
```

`/data` is world-traversable (`drwxrwxr-x`), so the `ollama` user can reach it.

## systemd Override

Configured via a drop-in (survives package updates — never edit the packaged unit):

```bash
sudo systemctl edit ollama   # or write the file below directly
```

`/etc/systemd/system/ollama.service.d/override.conf`:

```ini
[Service]
# Models stored on the 2TB NVMe at /data
Environment="OLLAMA_MODELS=/data/ollama"

# --- Performance tuning (RTX 5090, 32GB VRAM) ---
# Flash attention: faster + lower VRAM on attention
Environment="OLLAMA_FLASH_ATTENTION=1"
# Quantize KV cache to q8_0 (requires flash attention) - big VRAM savings
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

Apply:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now ollama
```

### Tuning notes

- `OLLAMA_FLASH_ATTENTION=1` + `OLLAMA_KV_CACHE_TYPE=q8_0` cut KV-cache VRAM
  substantially with negligible quality loss, letting larger context fit in 32 GB.
  The q8 cache type **requires** flash attention.
- `OLLAMA_MAX_LOADED_MODELS=2`: two ~30B models won't co-reside in 32 GB; this
  mainly lets `nomic-embed-text` stay hot next to one large model. Ollama evicts
  by VRAM pressure regardless.
- To expose on the LAN / Proxmox cluster, set `OLLAMA_HOST=0.0.0.0:11434`.

## Verify

```bash
ollama --version
systemctl is-active ollama
journalctl -u ollama -n 40 | grep -iE 'gpu|cuda|inference compute'
# Expect: library=CUDA compute=12.0 name="NVIDIA GeForce RTX 5090" libdirs=ollama,cuda_v13
ollama ps        # shows loaded models + GPU/CPU split (want 100% GPU)
```

## Models

Re-pulled after the Docker → native migration:

```
nomic-embed-text:latest    # embeddings
llama3.2:1b
llama3.1:8b
qwen3:8b
qwen3:14b
deepseek-coder-v2:16b
codestral:22b
devstral:24b
mistral-small3.2:24b
gemma3:27b
qwen3.6:27b
qwen3-coder:30b
qwen3-vl:30b               # vision-language
deepseek-r1:32b
```

Bulk re-pull:

```bash
for m in nomic-embed-text:latest llama3.2:1b llama3.1:8b qwen3:8b qwen3:14b \
         deepseek-coder-v2:16b codestral:22b devstral:24b mistral-small3.2:24b \
         gemma3:27b qwen3.6:27b qwen3-coder:30b qwen3-vl:30b deepseek-r1:32b; do
  ollama pull "$m"
done
```

## Operations

```bash
systemctl status ollama          # service state
journalctl -u ollama -f          # live logs
ollama list                      # installed models
ollama ps                        # loaded/running models + VRAM
ollama run <model>               # interactive
sudo systemctl restart ollama    # after config changes
```

## Migration History

- Removed Docker `ollama` container, `ollama/ollama:latest` image, and
  `ollama_ollama-data` volume (Docker data root was `/data/docker`).
- Other Docker stacks (cipher, ghostport, nexus, veritas) left untouched.
- Reclaimed ~157 GB on `/data`.
- Models re-pulled fresh into `/data/ollama` rather than migrating blobs.

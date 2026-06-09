# Ollama Troubleshooting

## Incident: all models "vanished" after a service restart

### Symptom

- `curl http://localhost:11434/api/tags` returns an empty model list.
- `ollama run <model>` reports `model '<name>' not found`.
- Happened immediately after editing the systemd drop-in and restarting.

### Root cause

The drop-in `/etc/systemd/system/ollama.service.d/override.conf` was **overwritten
wholesale** (a `tee > override.conf` that wrote only the new setting). That dropped
the existing `OLLAMA_MODELS=/data/ollama` line, so the service fell back to its
default `/var/lib/ollama` — an empty dir. The models were never deleted; the
service was just looking in the wrong place.

The same overwrite also silently dropped the entire performance-tuning block
(flash attention, q8_0 KV cache, keep-alive, etc.).

### Diagnosis steps

```bash
# 1. What is the service actually configured with?
systemctl show ollama -p Environment
# look for OLLAMA_MODELS — if it's /var/lib/ollama, that's the bug

# 2. Where do the models really live? (they're on disk, not deleted)
sudo find /data/ollama/manifests -type f | wc -l   # manifests
sudo find /data/ollama/blobs -name 'sha256-*' | wc -l  # blobs

# 3. Confirm the drop-in contents
sudo cat /etc/systemd/system/ollama.service.d/override.conf
```

### Fix

Restore the full drop-in (see `configuration.md` for the canonical contents),
then:

```bash
sudo systemctl daemon-reload
sudo systemctl restart ollama
systemctl show ollama -p Environment   # verify OLLAMA_MODELS=/data/ollama
curl -s http://localhost:11434/api/tags | python3 -m json.tool   # models back
```

### Prevention

- **Never** overwrite the drop-in wholesale. Read it first, then edit in place.
- After any restart, run `systemctl show ollama -p Environment` and confirm every
  expected variable is present, not just the one you changed.
- Treat `override.conf` as the single source of truth; keep it mirrored in
  `~/arch/ollama/` so it can be restored verbatim.

## Models not loading on GPU (CPU fallback)

```bash
journalctl -u ollama -n 40 | grep -iE 'gpu|cuda|inference compute'
# want: library=CUDA compute=12.0 name="NVIDIA GeForce RTX 5090" libdirs=ollama,cuda_v13
ollama ps   # want 100% GPU, not a CPU/GPU split
```

If CPU-only: confirm `ollama-cuda` is installed (not plain `ollama`), and the
NVIDIA driver/CUDA libs match (see `README.md`).

## Context window stuck at 4096

The model ignores long prompts / loops. Cause: `OLLAMA_CONTEXT_LENGTH` not applied.
See `context-length.md` — verify via `/api/ps` `context_length` field.

## Out of VRAM at 64k

- Confirm `OLLAMA_FLASH_ATTENTION=1` and `OLLAMA_KV_CACHE_TYPE=q8_0` are active
  (`systemctl show ollama -p Environment`). Without them the KV cache is ~2x.
- On 24 GB cards, drop per-request `num_ctx` or use a smaller model.

## General service ops

```bash
systemctl status ollama
journalctl -u ollama -f
sudo systemctl restart ollama
```

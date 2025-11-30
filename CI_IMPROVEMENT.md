# CI_IMPROVEMENT.md — GPU-Aware, Reliable CI for Arch + NVIDIA

> Improving self-hosted GitHub Actions runners for **Arch Linux**,  
> **NVIDIA-accelerated builds**, and **Proxmox-backed infra**.

---

## 1. Current Situation & Pain Points

### What we have now

- GitHub Actions runners running as **long-lived Docker containers** on an Ubuntu host
- Each runner folder contains:
  - `Dockerfile`
  - `docker-compose.yml`
  - `entrypoint.sh` that:
    - Downloads/configures the GitHub runner
    - Starts `run.sh`
- NVIDIA container runtime is enabled so jobs can access RTX GPUs for:
  - Zig builds
  - LLVM/GCC builds
  - CUDA / GPU workloads

### Pain points

1. **Runner config is not persistent**
   - `/runner` is *inside* the container FS
   - When the container is rebuilt or recreated, `.runner` is lost
   - The baked-in registration token is one-shot + expires → CI fails

2. **NVIDIA stack is partially duplicated**
   - Some NVIDIA bits are installed inside the container and on the host
   - The `deploy` section in `docker-compose` is Swarm-only and ignored by regular `docker compose`

3. **Limited scaling/flexibility**
   - Single long-lived runner per repo / per host
   - No ephemeral runners per job
   - Failures sometimes require manual reconfig of the runner

4. **Not clearly positioned vs Proxmox / VFIO**
   - Unclear when to:
     - Use a full Proxmox VM with GPU passthrough
     - Use containers with NVIDIA runtime
     - Mix both (VM host + containerized runners inside)

---

## 2. Short-Term Fix: Make Runners Persistent & Less Fragile

Goal: **Keep the current pattern, but make it reliable.**

### 2.1 Persist `/runner`

Change `docker-compose.yml` to mount a host volume:

```yaml
services:
  zquic:
    build: .
    container_name: zquic
    restart: unless-stopped

    gpus: all
    environment:
      - RUNNER_ALLOW_RUNASROOT=1
      - NVIDIA_VISIBLE_DEVICES=all
      - NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics

    volumes:
      - ./runner-data:/runner
      - /var/run/docker.sock:/var/run/docker.sock
```

### Why this matters

- `./runner-data` on the host will now contain:
  - `.runner/` → GitHub runner registration config
  - `_work/` → job workspaces, caches
- Rebuilds / container recreates no longer lose runner configuration
- `restart: unless-stopped` actually works as intended

---

### 2.2 Stop baking registration token into the image

Instead of hardcoding a short-lived token, simplify `entrypoint.sh`:

```bash
#!/bin/bash
set -e

cd /runner

if [ ! -f ".runner/config.toml" ]; then
  echo "Runner is not configured. Configure once with:"
  echo "docker exec -it zquic ./config.sh --url <url> --token <token>"
  exit 1
fi

exec ./run.sh
```

---

### 2.3 Move NVIDIA tooling to the host

- Remove `nvidia-container-toolkit` installation inside the container.
- Ensure host controls NVIDIA runtime versions.

---

## 3. Medium-Term Improvements

### 3.1 Ephemeral runners (job-scoped, auto-created)

Design a small control plane (`nv-runnerd`) to:

- Request GitHub registration tokens dynamically
- Spin up containers per-job
- Tear them down afterward

---

### 3.2 Proxmox VM + VFIO vs Containerized Host

#### Option A — Proxmox VM with VFIO
- Best isolation  
- Dedicated GPU passthrough  
- VM snapshots for CI appliance consistency  

#### Option B — Single Host with GPU Containers
- No VFIO complexity  
- Run multiple GPU runners side-by-side  

### Recommended Hybrid Approach
- A dedicated **Proxmox CI VM** with GPU passthrough  
- Inside it, run Docker-based GPU runners  
- Easier rollback, clear isolation, scalable

---

## 4. CI Strategy for the Arch Repository

Use self-hosted runners with specific labels:

- `gpu,nvidia,arch`
- `cpu-only,arch`
- `gpu,ubuntu`

Workflows target them:

```yaml
runs-on: [self-hosted, gpu, nvidia, arch]
```

---

## 5. Action Items Checklist

### Immediate
- [ ] Add persistent `/runner` volume
- [ ] Remove baked tokens from images
- [ ] Delegate NVIDIA runtime to host
- [ ] Document reconfiguration workflow

### Medium-Term
- [ ] Create Proxmox CI VM with VFIO GPU
- [ ] Implement ephemeral runners (`nv-runnerd`)
- [ ] Add monitoring for runner uptime & GPU usage

---

## 6. Summary

- The main failure point was **non-persistent runner state**.  
- Persisting `/runner` fixes 80% of your CI issues immediately.  
- Proxmox + VFIO VM provides clean isolation for CI.  
- Long-term: adopt ephemeral GPU runners for maximal reliability.


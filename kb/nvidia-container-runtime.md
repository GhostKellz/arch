# NVIDIA Container Runtime & Docker

Managing the NVIDIA container toolkit on Arch Linux with Docker and containerd. This covers configuration, common breakage after driver updates, and the fix workflow.

## Architecture Overview

The nvidia container stack on Arch:

```
Docker Engine
  └─ containerd (shimv2)
       └─ nvidia-container-runtime (OCI runtime wrapper)
            └─ runc (actual container execution)
                 └─ libnvidia-container (mounts GPU libs/devices into container)
```

Key packages:
- `nvidia-container-toolkit` — CLI tools + runtime binary
- `containerd` — container lifecycle manager
- `docker` — high-level daemon

Key config files:
- `/etc/docker/daemon.json` — registers nvidia runtime with Docker
- `/etc/containerd/conf.d/99-nvidia.toml` — registers nvidia runtime with containerd
- `/etc/cdi/nvidia.yaml` — CDI (Container Device Interface) spec mapping driver libs/devices

## Configuration Commands

### Register nvidia runtime with Docker

```bash
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

### Register nvidia runtime with containerd

```bash
sudo nvidia-ctk runtime configure --runtime=containerd
sudo systemctl restart containerd
```

### Regenerate CDI spec (maps current driver version's libs)

```bash
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
```

### Verify runtime works

```bash
# Basic test (runc only)
docker run --rm hello-world

# GPU test
docker run --rm --runtime=nvidia --gpus all nvidia/cuda:12.6.3-base-ubuntu24.04 nvidia-smi
```

## Common Breakage: Driver Version Mismatch

### Symptom

```
OCI runtime create failed: runc create failed: unable to start container process:
error during container init: failed to fulfil mount request:
open /usr/lib/libEGL_nvidia.so.<OLD_VERSION>: no such file or directory
```

### Cause

NVIDIA driver was updated (e.g. `595.58.03` → `595.71.05`) but the CDI spec at `/etc/cdi/nvidia.yaml` still references the old version's `.so` paths.

### Fix

```bash
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
sudo systemctl restart docker
```

## Common Breakage: TTRPC Shim Error

### Symptom

```
failed to create task for container: failed to start shim: start failed:
failed to create TTRPC connection: unsupported protocol: Yunix
```

### Cause

Containerd was upgraded (e.g. to v2.3.0) and the nvidia shim config is stale or missing. The nvidia-container-runtime shim registration doesn't match the new containerd version.

### Fix

```bash
sudo nvidia-ctk runtime configure --runtime=containerd
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart containerd
sudo systemctl restart docker
```

If the container was left in a broken state, remove it first:

```bash
docker rm -f <container_name>
```

## Full Recovery Workflow (Nuclear Option)

When docker GPU containers are completely broken after system updates:

```bash
# 1. Remove broken containers
docker rm -f ollama  # or whatever container is stuck

# 2. Reconfigure runtimes
sudo nvidia-ctk runtime configure --runtime=containerd
sudo nvidia-ctk runtime configure --runtime=docker

# 3. Regenerate CDI spec for current driver
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml

# 4. Restart everything
sudo systemctl restart containerd
sudo systemctl restart docker

# 5. Verify
docker run --rm --runtime=nvidia --gpus all nvidia/cuda:12.6.3-base-ubuntu24.04 nvidia-smi
```

## Pacman Hook (Auto-fix on Driver Update)

To prevent the CDI mismatch from happening silently, create a pacman hook:

```ini
# /etc/pacman.d/hooks/nvidia-container-toolkit.hook
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = nvidia-utils
Target = nvidia-open-dkms

[Action]
Description = Regenerating NVIDIA CDI spec for container toolkit...
When = PostTransaction
Exec = /usr/bin/nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
NeedsTargets
```

## Docker Compose Template (GPU container with host networking)

```yaml
services:
  ollama:
    image: ollama/ollama:latest
    container_name: ollama
    restart: unless-stopped
    network_mode: host
    environment:
      - OLLAMA_HOST=0.0.0.0:11434
      - NVIDIA_VISIBLE_DEVICES=all
      - NVIDIA_DRIVER_CAPABILITIES=compute,utility
    volumes:
      - ollama-data:/root/.ollama
      - /etc/localtime:/etc/localtime:ro
    runtime: nvidia

volumes:
  ollama-data:
```

Note: The `version` key in compose files is deprecated and ignored by modern docker compose. Omit it.

## Useful Diagnostic Commands

```bash
# Check current driver version
nvidia-smi | head -5

# Check package versions
pacman -Q nvidia-container-toolkit containerd docker

# Check what CDI spec thinks the driver version is
grep "driver" /etc/cdi/nvidia.yaml | head -3

# Check daemon.json runtime config
cat /etc/docker/daemon.json

# Test runc alone (bypasses nvidia runtime)
docker run --rm --runtime=runc hello-world

# Check containerd nvidia config
cat /etc/containerd/conf.d/99-nvidia.toml
```

## Affected Versions (Verified)

- **Kernel:** 7.0.x (CachyOS LTO)
- **NVIDIA Driver:** 595.71.05 (nvidia-open)
- **containerd:** 2.3.0
- **Docker:** 29.4.1
- **nvidia-container-toolkit:** 1.19.0

# Docker Storage on btrfs (data-root relocation)

Why Docker's data-root lives on `/data` instead of the primary drive, and how it was migrated. This exists to stop Docker image/build churn from silently bloating snapper snapshots and filling the primary NVMe.

## The Problem

The primary drive (`/dev/nvme0n1p2`, btrfs) hit 78% with `/var/lib/docker` consuming **~536G**, almost all of it in `overlay2`. Two compounding issues:

1. **Reclaimable garbage.** `docker system df` showed 170 images (only 7 active) = ~333G reclaimable, plus ~111G of build cache. Heavy build/CI work accumulates dead layers fast.
2. **Snapshot pinning (the real trap).** `/var/lib/docker` sat *inside* the snapshotted `@` subvolume. snapper's `root` config snapshots `/`, so every image pull and `docker build` was captured into timeline + pre/post-pacman snapshots. Pruning images frees nothing on `df` until **every snapshot that referenced the deleted layers** is also gone.

### Diagnosing snapshot pinning

```bash
# du says one thing, df another, and pruning doesn't move df -> suspect snapshots
sudo btrfs filesystem usage /
sudo btrfs subvolume list /            # look for @snapshots/NNNN/snapshot
sudo snapper -c root list
```

Deleted-but-pinned space only releases as btrfs-cleaner processes removed snapshots. Newly-created snapshots still pin data deleted *after* they were taken, so recent rollback points hold the most freshly-pruned data until they expire.

## The Decision: data-root on /data

Move Docker's entire data-root to `/data/docker`.

- `/data` is a **separate btrfs filesystem** (`/dev/nvme1n1p2`, `compress=zstd:3`) with ~1.3T free. Also NVMe, so no speed penalty.
- snapper only manages `/`, so Docker on `/data` is **never snapshotted** — image/build churn can no longer bloat snapshots. This is a stronger root-cause fix than making `/var/lib/docker` its own subvolume on the primary drive, and it also moves the storage off the smaller disk entirely.
- Named volumes (incl. ollama models) move with it, so a large model library lands on the big disk automatically.

### Critical: pin the overlay2 storage driver

Both `/` and `/data` are btrfs. On a btrfs-backed data-root, Docker's auto-detection can select the **btrfs storage driver**, which would not recognize the existing `overlay2` image data. The driver must be pinned explicitly or the migrated images effectively vanish.

## Configuration

`/etc/docker/daemon.json`:

```json
{
    "data-root": "/data/docker",
    "storage-driver": "overlay2",
    "dns": [
        "10.0.0.2",
        "1.1.1.1"
    ],
    "insecure-registries": [
        "127.0.0.1:8080"
    ],
    "iptables": true,
    "runtimes": {
        "nvidia": {
            "args": [],
            "path": "nvidia-container-runtime"
        }
    }
}
```

## Migration Procedure

Prune first so far less data is copied.

```bash
# 1. Reclaim dead images + build cache (volumes are NOT touched)
docker system prune -a -f
docker builder prune -a -f

# 2. Stop the daemon (and socket so it can't be re-triggered)
sudo systemctl stop docker docker.socket

# 3. Copy the data-root, preserving hardlinks/xattrs/ACLs (required for overlay2)
sudo rsync -aHAX --numeric-ids /var/lib/docker/ /data/docker/

# 4. Install daemon.json with data-root + storage-driver pinned (see above)
sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.bak
#   ...write new daemon.json...

# 5. Start and verify BEFORE deleting the old dir
sudo systemctl start docker
docker info | grep -E 'Storage Driver|Docker Root Dir'   # expect overlay2 + /data/docker
docker ps
docker exec ollama ollama list                            # models intact

# 6. Only after verification, remove the old data-root
sudo rm -rf /var/lib/docker
```

`rsync -aHAX` is mandatory: overlay2 relies on hardlinked layers and xattrs. A plain `cp` corrupts the image store.

## Permissions Note (expected behavior)

`/data/docker` is `drwx--x--- root:root` (mode `0710`) — `rsync` preserves Docker's default. A non-root user gets:

```
ls /data/docker  ->  Permission denied (code 13)
```

This is **intentional and correct**. The data-root can contain secrets (volume contents, build args); only root and the daemon should read it. Never `chmod` it open — interact via `docker` commands.

## Maintenance

```bash
# Where things physically live now
docker info | grep 'Docker Root Dir'                 # /data/docker
docker volume inspect ollama_ollama-data | grep Mountpoint
#   -> /data/docker/volumes/ollama_ollama-data/_data

# Periodic reclaim (safe: leaves volumes/models alone)
docker system prune -a -f
docker builder prune -a -f

# Full usage breakdown
docker system df
```

Because Docker now lives off the snapshotted subvolume, these prunes free space on `/data` immediately — no snapshot-pinning lag.

## Verified Environment

- **Kernel:** 7.0.11-1-cachyos-lto
- **Docker:** 29.5.2
- **containerd:** 2.3.1
- **Filesystem:** btrfs (`/data` = `/dev/nvme1n1p2`, `compress=zstd:3`), storage driver pinned to `overlay2`
- **Related:** `kb/nvidia-container-runtime.md` (GPU runtime), `system/docker.md` (kernel module requirements)

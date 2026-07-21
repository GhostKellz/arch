# io.md

Disk I/O tuning and scheduler configuration.

---

## I/O Scheduler Tuning

Linux supports multiple I/O schedulers that influence how read/write requests are handled. Selecting the right scheduler can significantly improve performance based on the device type:

The two Samsung NVMe devices on this workstation currently use `mq-deadline`.
Btrfs upstream warns that idle `ionice` priority is not reliable with this
scheduler. Maintenance must use Btrfs `--limit` and systemd cgroup
`IOReadBandwidthMax=` controls; `Nice=` or `IOSchedulingClass=idle` alone is not
an adequate scrub safeguard.

### Scheduler Types

| Scheduler     | Best For                      | Notes                                                                 |
|---------------|-------------------------------|-----------------------------------------------------------------------|
| `none`        | NVMe SSDs                     | Minimal overhead, assumes device handles its own queueing            |
| `mq-deadline` | SATA SSDs, modern drives      | Balanced latency and throughput                                       |
| `bfq`         | HDDs, desktops with many apps | Good for interactive workloads, fair queueing                        |

### Check Current Scheduler
```bash
cat /sys/block/<device>/queue/scheduler
```
Replace `<device>` with your disk identifier (e.g., `nvme0n1`, `sda`).

### Set Default Scheduler (udev rule)
Create a file like `/etc/udev/rules.d/60-ioschedulers.rules`:
```bash
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/scheduler}="mq-deadline"
```
Then reload udev:
```bash
sudo udevadm control --reload && sudo udevadm trigger
```

---

## Readahead Settings

Disk readahead affects how much data the system pre-loads during sequential reads.

### Check Current Value:
```bash
blockdev --getra /dev/<device>
```

### Optimize Value:
```bash
sudo blockdev --setra 4096 /dev/<device>
```
Higher values (like 8192) may benefit HDDs for large file loads.

To persist readahead, you can add it to a systemd service or tuning script.

---

## Writeback ceilings

See `memory.md` for the fixed dirty-byte and background-writeback ceilings.

---

## Filesystem Mount Options

- Use `noatime` to avoid updating access timestamps on every read.
- Example for `/etc/fstab`:
  ```bash
  UUID=xxxx-xxxx / ext4 defaults,noatime,commit=60 0 1
  ```
- Consider `commit=60` to flush journal every 60s (trades safety for performance).

---

## Desktop File Indexing (Baloo)

KDE's `baloo_file` content-indexes file *contents*. Its default excludes target
a normal home, not a dev box — it misses language build caches and grinds
through millions of files, stalling the system on I/O (observed: 2.66M files,
7.34GB index, 248GB I/O).

Fix — filename-only indexing plus dev-cache excludes in `~/.config/baloofilerc`:

```ini
[General]
onlyBasicIndexing=true
exclude filters=...,target,.cargo,.rustup,.cache,.zig-cache,zig-out,go,pkg,dist,build,.gradle,.m2
```

```bash
balooctl6 disable && balooctl6 enable
```

Prefer `ripgrep`/`fd` for full-text code search. Full write-up and PSI-based
diagnosis in `freeze-diagnosis.md`.

---

## Benchmark Tools

- `fio` - I/O stress testing
- `iostat` - I/O usage stats
- `hdparm` - Simple throughput tests

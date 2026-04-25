# io.md

Disk I/O tuning and scheduler configuration.

---

## I/O Scheduler Tuning

Linux supports multiple I/O schedulers that influence how read/write requests are handled. Selecting the right scheduler can significantly improve performance based on the device type:

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

## Writeback and Dirty Ratios

See `memory.md` for current dirty_ratio and dirty_background_ratio settings.

---

## Filesystem Mount Options

- Use `noatime` to avoid updating access timestamps on every read.
- Example for `/etc/fstab`:
  ```bash
  UUID=xxxx-xxxx / ext4 defaults,noatime,commit=60 0 1
  ```
- Consider `commit=60` to flush journal every 60s (trades safety for performance).

---

## Benchmark Tools

- `fio` - I/O stress testing
- `iostat` - I/O usage stats
- `hdparm` - Simple throughput tests


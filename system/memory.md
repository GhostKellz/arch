# 🧠 memory.md

This file documents the current memory configuration and optimizations for swap, caching behavior, and dirty writeback settings. It includes ZRAM configuration, kernel tuning parameters, and zswap status for improved memory efficiency and responsiveness.

---

## 🧊 ZRAM Swap (Active)

ZRAM is configured via `systemd-zram-generator` for lightweight compressed swap in RAM.

```ini
# /etc/systemd/zram-generator.conf
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
```

**Status:**
- Device: `/dev/zram0`
- Size: ~31 GB
- Used: ~6.7 GB
- Priority: 100

```bash
swapon --show --bytes
```

**Benefits:**
- Enables fast, compressed swap in RAM for better responsiveness under load.
- `zstd` compression offers high speed and good compression ratio.

---

## 🚫 zswap (Disabled)

```bash
cat /sys/module/zswap/parameters/enabled
N
```

Zswap is explicitly disabled in favor of ZRAM, which provides better performance and flexibility under this configuration.

---

## 🧪 Kernel Virtual Memory Tunables

These `vm.` parameters optimize memory pressure and writeback behavior:

```bash
vm.swappiness = 10
vm.vfs_cache_pressure = 50
vm.dirty_ratio = 50
vm.dirty_background_ratio = 20
```

### 🔍 What these do:
- **`swappiness = 10`**: Favors RAM over swap; only uses swap under memory pressure.
- **`vfs_cache_pressure = 50`**: Retains inode/dentry cache longer for improved filesystem performance.
- **`dirty_ratio = 50`**: Max percent of dirty pages before forced flush to disk.
- **`dirty_background_ratio = 20`**: Background writeback kicks in earlier to smooth I/O.

---

## 🚫 OOM Killer (Default)

No custom OOM killer or `earlyoom` is currently in use.

```bash
cat /etc/sysctl.d/* | grep -i oom
No custom OOM killer settings
```

You may consider configuring earlyoom or customizing `/proc/sys/vm/oom_*` if running into low-memory stability issues.

---

## ✅ Summary

- Using ZRAM with `zstd` compression at 50% of RAM
- Swappiness tuned to 10 for minimal swap usage
- zswap is disabled
- Kernel memory pressure and dirty writeback behavior adjusted for better latency

> 📁 All related config files are in `/etc/systemd/zram-generator.conf` and `/etc/sysctl.d/`.


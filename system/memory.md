# memory.md

Memory configuration for 64GB workstation (9950X3D). Philosophy: **fail fast instead of freezing**.

---

## ZRAM Swap

ZRAM configured via `systemd-zram-generator`.

**Current config:**
```ini
# /etc/systemd/zram-generator.conf
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
```

**Current status:** ~31GB zram (ram/2)

**PLANNED CHANGE:** Reduce to 16GB fixed size:
```ini
# /etc/systemd/zram-generator.conf
[zram0]
zram-size = 16384
compression-algorithm = zstd
```

**Rationale:** For high-end 64GB systems, ram/2 (30GB) is too aggressive. With 30GB zram, the system can compress and thrash through 30GB of data before OOM triggers, leading to system freezes. 16GB provides enough swap headroom while ensuring faster OOM intervention when memory is truly exhausted.

---

## zswap (Disabled)

```bash
cat /sys/module/zswap/parameters/enabled
# N
```

zswap disabled in favor of ZRAM.

---

## Kernel VM Tunables

**Current values (actual):**
```bash
vm.swappiness = 10
vm.vfs_cache_pressure = 50
vm.dirty_ratio = 20
vm.dirty_background_ratio = 10
```

**PLANNED CHANGE:** Tighten dirty ratios for faster writeback:
```bash
# /etc/sysctl.d/99-memory.conf
vm.swappiness = 10
vm.vfs_cache_pressure = 50
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
```

**Rationale:** Lower dirty ratios force earlier disk writeback, preventing large dirty page buildups that can cause I/O stalls during heavy memory operations (like kernel linking).

---

## OOM Management

**Current:** No OOM daemon (systemd-oomd disabled)

**PLANNED CHANGE:** Enable systemd-oomd:
```bash
sudo systemctl enable --now systemd-oomd
```

**Rationale:** systemd-oomd monitors memory pressure and kills processes early before the system becomes unresponsive. This aligns with "fail fast" philosophy - better to lose one runaway process than freeze the entire system.

---

## Summary

**Current state:**
- ZRAM: 31GB (ram/2) - too aggressive
- dirty_ratio: 20, dirty_background_ratio: 10
- systemd-oomd: disabled

**Planned changes:**
- ZRAM: 16GB fixed
- dirty_ratio: 15, dirty_background_ratio: 5
- systemd-oomd: enabled

**Apply changes after kernel build:**
```bash
# 1. Update zram config
sudo vim /etc/systemd/zram-generator.conf

# 2. Add sysctl config
echo 'vm.dirty_ratio = 15
vm.dirty_background_ratio = 5' | sudo tee /etc/sysctl.d/99-dirty.conf

# 3. Enable oomd
sudo systemctl enable --now systemd-oomd

# 4. Reboot to apply zram changes
```

Config files: `/etc/systemd/zram-generator.conf`, `/etc/sysctl.d/`


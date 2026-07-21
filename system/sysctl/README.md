# Sysctl Configuration

Install these files under `/etc/sysctl.d/` and apply them with
`sudo sysctl --system`.

## `99-sysctl.conf`

- `vm.swappiness=150`: prefer cheap compressed zram over reclaiming useful file
  cache. This is a reclaim-cost bias, not a request to fill swap immediately.
- `vm.page-cluster=0`: avoid disk-style swap read-ahead on zram.
- `vm.vfs_cache_pressure=50`: retain inode and dentry cache moderately.
- `vm.dirty_bytes=268435456` and `vm.dirty_background_bytes=67108864`: cap
  dirty data at 256 MiB and begin background writeback at 64 MiB. Fixed byte
  ceilings avoid ratio-derived multi-gigabyte bursts on a 64 GiB host.
- `vm.dirty_writeback_centisecs` remains at the kernel default of 500.
- IPv6 is disabled because this network has no routed IPv6 and Wine/Proton AAAA
  attempts caused long application startup delays.

## `80-gamecompatibility.conf`

Provides the high `vm.max_map_count` required by memory-map-heavy Wine, Proton,
and native game workloads.

## Verification

```bash
sysctl vm.swappiness vm.page-cluster vm.vfs_cache_pressure
sysctl vm.dirty_bytes vm.dirty_background_bytes vm.dirty_writeback_centisecs
sysctl vm.max_map_count
```

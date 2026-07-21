# CKTech Linux System Configuration

System-wide configuration and tuning for Arch Linux workstation.

---

## Hardware

- **CPU:** AMD Ryzen 9950X3D (Zen 5, 16c/32t)
- **RAM:** 64GB DDR5
- **GPU:** NVIDIA RTX 5090 (Blackwell)
- **Storage:** NVMe

---

## Memory and Swap

- RAM-sized zram with zstd compression and priority 100
- Workstation policy of `vm.swappiness=150` with `vm.page-cluster=0`
- Fixed 256 MiB/64 MiB dirty-page ceilings to smooth writeback
- Pressure-based systemd-oomd policy; no swap-occupancy kill trigger
- Transparently routed resource-controlled slice for agent/build workloads
- Bounded coredump retention and terminal scrollback
- Explicit persistent, compressed 4 GiB journal retention

See `memory.md` for full configuration.

## Maintenance Safety

- Weekly maintenance is a bounded health report plus pacman-cache retention; it
  never launches Btrfs scrub, balance, package upgrades, or DKMS work.
- Monthly Btrfs verification processes `/` and `/data` sequentially, read-only,
  with Btrfs-native and systemd 64 MB/s device caps.
- The packaged per-filesystem scrub timers remain disabled because they can
  overlap. Neither custom maintenance timer catches up at boot.
- Ordinary `codex` and `claude` shell commands route through `agent-scope`;
  explicitly named unscoped commands remain available for exceptional work.

See `systemd.md` and `../scripts/README.md` for installation and verification.

---

## Kernel Configuration

**Primary Kernel:** CachyOS LTO
- Package: `linux-cachyos-lto`

**Fallback Kernel:** linux-zen
- Package: `linux-zen`

**Driver:** NVIDIA Open DKMS (required for Blackwell/RTX 5090)

Both kernels include:
- Full netfilter stack for Docker/Tailscale (CONNMARK, nftables compat)
- VFIO/KVM passthrough support
- Container namespaces and cgroups
- BBR3 TCP congestion control
- Performance governor default

See `kernel/` for myfrag configs and PKGBUILD settings.

---

## systemd

- Journal compression and persistent logging
- Timers for backups and maintenance
- Service overrides for reliability

See `systemd.md` for details.

---

## Disk I/O

- I/O scheduler tuning per drive type
- fstab mount options: noatime, commit=60
- udev rules for persistent tuning

See `io.md` for details.

---

## File Index

| Path | Description |
|------|-------------|
| `kernel/` | Kernel configs, myfrag files, PKGBUILD settings |
| `kernel/linux-tkg/` | TKG kernel customization |
| `kernel/linux-cachyos/` | CachyOS kernel customization |
| `kernel/nvidia/` | NVIDIA DKMS patches |
| `memory.md` | Zram, reclaim, OOM, coredump, and workload-limit policy |
| `memory/` | Installable zram, oomd, and coredump configuration |
| `freeze-diagnosis.md` | PSI-based freeze triage; zram vs I/O; Baloo indexer fix |
| `docker.md` | Docker kernel requirements, GPU support |
| `makepkg.conf` | Compiler flags for znver5 |
| `io.md` | I/O scheduler and disk tuning |
| `power.md` | CPU governor, suspend/hibernate |
| `systemd.md` | systemd unit overrides, maintenance, and timers |
| `systemd/btrfs-scrub-safe.*` | Sequential rate-limited monthly scrub units |
| `systemd/weekMain.*` | Bounded weekly health-maintenance units |
| `systemd/user/` | User slices for bounded agent/build workloads |
| `systemd/journald.conf.d/` | Persistent bounded journal policy |
| `sysctl/` | Sysctl configs (gaming, memory) |
| `pacman.conf` | Pacman configuration |

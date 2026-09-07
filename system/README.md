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
- the workstation-required storage, networking, container, and virtualization
  features documented in `kernel/config-spec.md`

The custom CachyOS-LTO profile additionally enables explicit Ghost Zen 5,
BORE, O3, full Clang LTO, 1000 Hz, full tickless operation, non-dynamic full
preemption, BBR3/FQ, and the performance governor. NVIDIA Open is built from
the separate local source tree through DKMS, not by the CachyOS PKGBUILD.

See `../packaging/linux-cachyos-lto/CUSTOMIZATIONS.md` for the authoritative
build/rebase runbook and `kernel/` for boot, validation, rollback, and historical
reference notes.

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
| `kernel/` | Kernel system state, boot, validation, rollback, and historical references |
| `kernel/linux-tkg/` | TKG kernel customization |
| `kernel/linux-cachyos/` | Historical CachyOS snapshots and pointer to the live build tree |
| `kernel/nvidia/` | Separate NVIDIA Open source-DKMS contract and historical patch notes |
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

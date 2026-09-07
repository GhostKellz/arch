# Linux-CachyOS-LTO Reference Files

This directory contains older configuration snapshots and boot references. It
is not the active build tree and must not become a second copy of the PKGBUILD.

## Authoritative locations

| Purpose | Location |
| --- | --- |
| Build tree | `/data/repo/linux-cachyos/linux-cachyos/` |
| Local branch | `ghostkellz`, tracking `origin/master` |
| Build/rebase runbook | [`../../../packaging/linux-cachyos-lto/CUSTOMIZATIONS.md`](../../../packaging/linux-cachyos-lto/CUSTOMIZATIONS.md) |
| Canonical Ghost Zen 5 patch | [`../../../packaging/linux-cachyos-lto/ghostzen5.patch`](../../../packaging/linux-cachyos-lto/ghostzen5.patch) |
| Prior-release backups | `/data/backup/linux-cachyos/` |

## Ghost Zen 5 target

The patch is deliberately modeled on CachyOS's `CONFIG_MZEN4` implementation.
It adds the parallel `CONFIG_MZEN5` choice and wires it to `-march=znver5` for
C and Rust. Selecting `_processor_opt=zen5` enables MZEN5 and disables MZEN4,
native, and generic targets. This is an explicit, reproducible Zen 5 build—not
`-march=native`.

The active profile also selects BORE, O3, full Clang LTO, 1000 Hz, performance
governor, full tickless operation, non-dynamic full preemption, BBR3/FQ, and
THP-always with shmem/tmpfs `within_size`.

## Retained files

| File | Status |
| --- | --- |
| `PKGBUILD` | Historical snapshot; never build or refresh it here |
| `ghostkellz.myfrag` | Retired fragment; not applied by the active PKGBUILD |
| `config-overrides.cfg` | Historical experiment; not consumed by the active build |
| `dkms-clang.patch` | Old downloaded snapshot; active builds fetch the checksum-pinned upstream source |
| `ghostzen5.patch` | Legacy mirror; canonical tracked copy is under `packaging/` |
| `linux-cachyos-lto.conf` | Reference copy of the systemd-boot entry |

Do not copy any of these files into the live clone during an update. Rebase the
tracked `ghostkellz` commit, regenerate `.SRCINFO`, verify the effective config,
and build from the live clone as documented in the canonical runbook.

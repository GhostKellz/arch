# Custom Kernel Operations

System-state, boot, validation, and rollback notes for the Arch workstation.
The package implementation and rebase procedure live in
[`../../packaging/linux-cachyos-lto/CUSTOMIZATIONS.md`](../../packaging/linux-cachyos-lto/CUSTOMIZATIONS.md).

## Current setup

| Role | Kernel | Scheduler | Source |
| --- | --- | --- | --- |
| Primary | `linux-cachyos-lto` | BORE | `/data/repo/linux-cachyos`, branch `ghostkellz` |
| Rollback | `linux-zen` | EEVDF | Official Arch package |

The primary kernel is built for the Ryzen 9 9950X3D with the explicit Ghost
Zen 5 target. NVIDIA Open is not compiled by the CachyOS PKGBUILD; the local
`~/open-gpu-kernel-modules` source tree is registered separately with DKMS.

## Documentation ownership

- [`../../packaging/linux-cachyos-lto/CUSTOMIZATIONS.md`](../../packaging/linux-cachyos-lto/CUSTOMIZATIONS.md)
  is the source of truth for the local PKGBUILD delta, checksums, rebase, build,
  and post-install verification.
- [`linux-cachyos/README.md`](linux-cachyos/README.md) explains the historical
  reference files retained in this directory. They are not build inputs.
- [`kernel-params.md`](kernel-params.md) documents the systemd-boot command
  line shared by the installed kernels.
- [`nvidia/README.md`](nvidia/README.md) documents the separate NVIDIA Open
  source-DKMS workflow.
- [`config-spec.md`](config-spec.md) is a requirements checklist, not an active
  config fragment.

## Verified primary profile

- `CONFIG_MZEN5=y` with `-march=znver5`; MZEN4, native, and generic targets off
- BORE scheduler, O3, full Clang LTO, 1000 Hz, performance governor
- full tickless operation and full preemption with runtime switching disabled
- BBR3 with FQ as the defaults
- THP always, with shmem/tmpfs constrained to `within_size`
- CachyOS in-tree NVIDIA build disabled; NVIDIA Open and v4l2loopback via DKMS

## Build and verify

Follow the canonical runbook before building. The final install command is:

```bash
cd /data/repo/linux-cachyos/linux-cachyos
makepkg -si
```

After installation, verify the package, boot artifacts, config, and DKMS state:

```bash
pacman -Q linux-cachyos-lto linux-cachyos-lto-headers linux-zen linux-zen-headers
ls -lh /boot/vmlinuz-linux-cachyos-lto /boot/initramfs-linux-cachyos-lto.img
dkms status
kernel_release=$(basename "$(dirname "$(readlink -f /usr/src/linux-cachyos-lto)")")
rg '^(CONFIG_(MZEN5|SCHED_BORE|CC_OPTIMIZE_FOR_PERFORMANCE_O3|HZ_1000|LTO_CLANG_FULL|TCP_CONG_BBR3))=' \
  "/usr/lib/modules/$kernel_release/build/.config"
bootctl list
```

After reboot, `uname -r` must report the installed CachyOS-LTO release. Confirm
the running config with `/proc/config.gz`; do not infer success from package
installation alone.

## Rollback

Before installing a new custom kernel, keep all of these working together:

- packaged `linux-zen` and `linux-zen-headers`;
- its systemd-boot entry and initramfs;
- NVIDIA Open and other required DKMS modules built for Zen.

If the new kernel fails, select `linux-zen` from the systemd-boot menu. Do not
treat an orphaned `/usr/lib/modules` directory as a reinstallable fallback.

## Hardware target

- AMD Ryzen 9 9950X3D (Zen 5)
- NVIDIA RTX 5090 using NVIDIA Open DKMS
- 64 GiB DDR5
- NVMe storage

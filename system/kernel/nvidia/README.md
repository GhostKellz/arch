# NVIDIA Open Modules for Custom Kernels

The RTX 5090 uses NVIDIA Open built from `~/open-gpu-kernel-modules` and
registered as `nvidia-open/<version>` with DKMS. The CachyOS PKGBUILD keeps
`_build_nvidia_open=no`; CachyOS's prebuilt NVIDIA module package is not part of
this workflow.

## Kernel-install contract

Installing or upgrading either `linux-cachyos-lto` or `linux-zen` must leave a
matching NVIDIA DKMS module for every bootable kernel. Pacman's DKMS hook should
perform that build automatically after the matching headers are installed.

Verify rather than assuming:

```bash
dkms status
kernel_release=$(basename "$(dirname "$(readlink -f /usr/src/linux-cachyos-lto)")")
modinfo -k "$kernel_release" nvidia | grep -E '^(filename|version|vermagic):'
```

The `vermagic` release must match the target kernel. Keep the Zen module built
as the rollback before rebooting into a newly installed CachyOS-LTO kernel.

## Source and userland consistency

The source tag, DKMS module version, `nvidia-utils-beta`, and
`lib32-nvidia-utils-beta` must match. Query live state instead of recording a
version here:

```bash
git -C ~/open-gpu-kernel-modules describe --tags --exact-match
dkms status
pacman -Q nvidia-utils-beta lib32-nvidia-utils-beta
```

## Historical BTF workaround

`kernel-7.0-btf.patch` records a BTF-generation compatibility fix required by
an older NVIDIA Open source release. It is historical evidence, not a patch to
apply automatically to current source. See
[`../../../kb/kernel-7.0-compat.md`](../../../kb/kernel-7.0-compat.md) and use it
only if the documented error is reproduced and the current source still lacks
the equivalent change.

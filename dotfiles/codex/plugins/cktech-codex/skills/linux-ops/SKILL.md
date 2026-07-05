---
name: linux-ops
description: Linux operations across Arch, Debian/Ubuntu, and Fedora/RHEL-family systems. Use for package managers, system updates, service debugging, logs, kernel/initramfs caution, distro-specific admin, and cross-distro troubleshooting.
---

# Linux Ops

- Arch: pacman, makepkg, AUR review, mkinitcpio, systemd, workstation conventions.
- Debian/Ubuntu: apt/dpkg, systemd units/drop-ins, server networking, Proxmox/GitLab/Heimdall hosts.
- Fedora/RHEL: dnf/rpm, SELinux, firewalld, podman, systemd.
- Inspect logs with `journalctl`; verify services with `systemctl`.
- Avoid unmanaged global installs when a project dev shell exists.
- Be cautious with kernel, initramfs, bootloader, firewall, and network changes.

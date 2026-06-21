# Infrastructure & hardware reference

Read this when a task targets a specific machine, VM, or the Proxmox cluster.
Intentionally NOT auto-loaded — kept out of normal coding sessions to save context.

## Primary dev workstation
- Arch Linux (main OS). Ryzen 9950X3D, 64 GB DDR5, NVIDIA RTX 5090.
- Primary build/test host for most projects.

## Proxmox cluster (secondary test environment)
| Node  | CPU                    | RAM         | GPU / Notes |
|-------|------------------------|-------------|-------------|
| PVE 1 | Ryzen 5900X            | 96 GB DDR4  | RX 570 |
| PVE 2 | Ryzen 7950X3D          | 96 GB DDR5  | — |
| PVE 3 | Intel 14900K           | 128 GB DDR5 | RTX 4090 |
| PVE 4 | Intel 12900KF          | 128 GB DDR5 | RTX 3070 |
| PVE 5 | Dell XPS, i7 9th gen    | 32 GB       | RTX 2060 |
| PVE 6 | Dell XPS, i7 9th gen    | 32 GB       | RTX 2060 |
| PVE 7 | EPYC 4th gen, 24 core  | 128 GB ECC  | 2× 4 TB NVMe ZFS mirror; baremetal, public exposure |

## Staged VMs
- Windows, Pop!_OS, Fedora, and Arch are staged for cross-OS testing.
- Reverse shell into these is permitted only when explicitly requested for OS-specific testing.

## Container testing defaults
- Default to host networking (see `~/.claude/rules/docker.md`). Verify DNS resolution and local-service reachability under host networking.
- Don't assume custom Docker networks work on this workstation.

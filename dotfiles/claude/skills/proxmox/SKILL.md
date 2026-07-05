---
name: proxmox
description: Operate the Proxmox VE cluster and Proxmox Backup Server from the CLI — VMs (qm), containers (pct), storage (pvesm), cluster/quorum (pvecm), the API (pvesh), SDN, and VFIO/GPU passthrough; plus PBS backup/restore, datastores, prune/GC, verify, and sync. Use for creating/migrating/cloning VMs or LXCs, debugging a node or quorum, wiring GPU passthrough, or managing backups/restores. The node inventory lives in reference/infrastructure.md. Triggers: "on the proxmox cluster", qm/pct/pvesh/pvecm, "PBS", "backup this VM", GPU passthrough, PVE node work.
---

# Proxmox VE + Backup Server

The cluster is the secondary test environment — node inventory (CPUs, GPUs, the
public-exposed baremetal node) is in `reference/infrastructure.md`; read it
before targeting a specific node. Reach nodes over SSH (see the `ssh` skill);
prefer an API token over `root@pam` for scripted access.

## Orientation before acting
```bash
pvecm status              # cluster + quorum health — never act into a no-quorum state
pvesh get /cluster/resources --type vm   # every VM/CT across the cluster, with node
qm list ; pct list        # VMs / containers on THIS node
pvesm status              # storage pools (local-lvm, ZFS, PBS) + free space
```
Confirm **which node** and **which VMID/CTID** before any state change — IDs are
cluster-unique but commands run per-node. Read-heavy by default.

## VMs (qm)
```bash
qm config <vmid>                      # current hardware/cloud-init
qm start|stop|shutdown|reboot <vmid>
qm clone <vmid> <newid> --name x --full
qm migrate <vmid> <target-node> [--online]
qm snapshot <vmid> pre-change ; qm rollback <vmid> pre-change
qm set <vmid> --memory 8192 --cores 4        # hot-add where supported
```
- Snapshot before any risky change; roll back rather than hand-repair.
- `--online` migrate needs shared/replicated storage; local-disk migrates cold.
- cloud-init VMs: `qm set <vmid> --ciuser --sshkeys --ipconfig0` then `qm cloudinit update`.

## Containers (pct)
```bash
pct list ; pct config <ctid>
pct enter <ctid>            # shell in ; pct exec <ctid> -- <cmd>
pct clone <ctid> <newid> --full
pct start|stop|reboot <ctid>
```
Prefer **unprivileged** LXCs; only go privileged when a workload truly needs it,
and know it weakens host isolation.

## VFIO / GPU passthrough
Given the RTX/RX cards in the cluster, passthrough is common:
- Host: IOMMU on (`intel_iommu=on` / `amd_iommu=on`), `vfio-pci` bound to the
  GPU's PCI IDs, GPU blocked from host drivers (`softdep`/modprobe blacklist).
- VM: `qm set <vmid> --hostpci0 <bus>,pcie=1[,x-vga=1]`, machine `q35`, OVMF/UEFI.
- Watch the **AMD reset bug** (some cards don't reset cleanly between VM stops) —
  may need `vendor-reset` or a full host reboot. Verify `lspci -nnk` shows
  `vfio-pci` in use before starting the guest.

## SDN & storage
- SDN: zones → vnets → subnets (`pvesh get /cluster/sdn`); apply with
  `pvesh set /cluster/sdn`. Reload after edits.
- ZFS pools: `zpool status`/`zfs list` on the node; snapshots are cheap — use
  them. The EPYC node's NVMe ZFS mirror is the durable tier.

## Backups — vzdump + PBS
```bash
vzdump <vmid> --storage <pbs-storage> --mode snapshot   # one-off backup to PBS
```
PBS is the backup target. On the PBS server / client:
```bash
proxmox-backup-client backup root.pxar:/ --repository <user@host:datastore>
proxmox-backup-client snapshot list --repository <repo>
proxmox-backup-client restore <snapshot> root.pxar /restore/path --repository <repo>
proxmox-backup-manager datastore list
proxmox-backup-manager prune-job list ; verify-job list ; sync-job list
proxmox-backup-manager garbage-collection start <datastore>
```
- **Encryption key is a secret** — store/rotate it via the `secrets` skill; if
  the key is lost the backups are unrecoverable. Never commit it.
- Retention = prune schedule (keep-daily/weekly/monthly) **then** GC reclaims
  space; verify jobs prove restorability; sync jobs replicate to a remote PBS.
- The `PBS_REPOSITORY` / `PBS_PASSWORD` env vars drive scripted clients — fetch
  at runtime, don't inline.

## Discipline
- Never break quorum; don't `pvecm delnode`/reconfigure corosync without a plan
  and a maintenance window.
- Confirm node + VMID/CTID before destroy/rollback/migrate; these are irreversible
  or disruptive. Snapshot first.
- The public-exposed baremetal node (see infrastructure.md) gets extra care —
  no careless firewall/network changes.
- Restores and destructive backup ops (prune/GC/forget) only when asked, target
  confirmed first.

## See also
- `reference/infrastructure.md` — the actual node/GPU/VM inventory.
- `ssh` skill — reaching nodes, PTY sudo.
- `secrets` skill — PBS encryption keys, API tokens, `PBS_PASSWORD`.

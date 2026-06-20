# Ubuntu VM Recovery from initramfs / fsck Failure

## Overview

This runbook documents the recovery process for an Ubuntu VM that boots into `initramfs` with filesystem errors following an unclean shutdown, power loss, host crash, or storage interruption.

Common symptoms:

```text
/dev/mapper/ubuntu--vg-ubuntu--lv: UNEXPECTED INCONSISTENCY
RUN fsck MANUALLY
```

or

```text
Failure: File system check of the root filesystem failed
The root filesystem on /dev/mapper/ubuntu--vg-ubuntu--lv requires a manual fsck
```

---

## Root Cause

Typical causes include:

* Power outage
* Forced VM shutdown
* Host crash
* Storage interruption
* Proxmox node reboot
* Dirty shutdown during updates

In this case the VM had experienced an unexpected shutdown due to power issues.

---

## Verify LVM Device

At the `(initramfs)` prompt:

```bash
ls /dev/mapper
```

Expected output:

```text
control
ubuntu--vg-ubuntu--lv
```

Do **not** add spaces when referencing the LVM device.

Correct:

```bash
/dev/mapper/ubuntu--vg-ubuntu--lv
```

Incorrect:

```bash
/dev/mapper/ubuntu --vg-ubuntu --lv
```

---

## Run Filesystem Repair

Execute:

```bash
fsck.ext4 -f -y /dev/mapper/ubuntu--vg-ubuntu--lv
```

Parameters:

| Flag | Description                         |
| ---- | ----------------------------------- |
| -f   | Force filesystem check              |
| -y   | Automatically answer yes to repairs |

---

## Expected Repair Output

You may see messages similar to:

```text
recovering journal
Clearing orphaned inode
Pass 1: Checking inodes, blocks, and sizes
Pass 2: Checking directory structure
Pass 3: Checking directory connectivity
Pass 4: Checking reference counts
Pass 5: Checking group summary information
```

Example repair confirmation:

```text
***** FILE SYSTEM WAS MODIFIED *****
```

This indicates fsck successfully repaired filesystem corruption.

---

## Handling I/O Errors

During recovery you may encounter:

```text
I/O error, dev sda
Buffer I/O error on dev dm-0
Error reading block XXXXXXX
```

If prompted:

```text
Ignore error?
```

Answer:

```text
yes
```

If prompted:

```text
Force rewrite?
```

Answer:

```text
yes
```

If fsck is able to continue and complete successfully, the filesystem can often be recovered.

---

## Reboot VM

After fsck completes:

```bash
reboot -f
```

Alternatively:

```bash
exit
```

and allow boot to continue.

---

## Post-Recovery Validation

After Ubuntu boots:

Verify filesystem status:

```bash
sudo dmesg -T | grep -Ei "error|fail|ext4"
```

Verify disk usage:

```bash
df -h
```

Verify mounted filesystems:

```bash
mount | grep '^/dev'
```

Review recent boot logs:

```bash
journalctl -b -p warning
```

---

## Proxmox Host Validation

If I/O errors were observed during fsck, inspect the host.

### General

```bash
dmesg -T | grep -Ei "error|fail|i/o"
```

```bash
journalctl -p err -b
```

### ZFS Storage

```bash
zpool status -v
```

### LVM / LVM-Thin

```bash
pvs
vgs
lvs -a
```

### VM Configuration

```bash
qm config <vmid>
```

---

## Notes

* Filesystem corruption after a dirty shutdown is common and recoverable.
* Repeated I/O errors after recovery may indicate underlying storage issues.
* Always investigate host storage if fsck reports unreadable blocks.
* Maintain current backups before performing major filesystem repairs.

---

## Example Incident

**Date:** 2026-06-20

**Platform:** Ubuntu Server VM (LVM Root Filesystem)

**Symptoms:**

* Boot dropped to initramfs
* Root filesystem failed automatic fsck
* Journal recovery errors
* Multiple orphaned inodes detected

**Resolution:**

```bash
fsck.ext4 -f -y /dev/mapper/ubuntu--vg-ubuntu--lv
```

Filesystem repaired successfully:

```text
***** FILE SYSTEM WAS MODIFIED *****
```

VM rebooted normally and returned to service.


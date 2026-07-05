---
name: backup-storage
description: Backup and storage operations spanning Wasabi/S3, Proxmox Backup Server, restic/borg/rclone, object storage, lifecycle/immutability, and restore tests. Use for backup target setup, retention, and verification.
---

# Backup / Storage

- A backup is not valid until restore is tested.
- Treat object storage keys, repo passwords, and PBS credentials as secrets.
- Review retention, lifecycle, immutability/object lock, versioning, and prune policies.
- Keep backup configs and secrets separate.
- Call out destructive prune/delete operations before running them.

---
name: wasabi
description: Use for Wasabi/S3-compatible storage in backup and object-storage workflows. Covers bucket policy, access keys, lifecycle, immutability, versioning, S3 endpoints, backup targets, and secret hygiene.
---

# Wasabi / S3 Storage

- Treat access keys and secret keys as secrets; never commit them.
- Confirm endpoint, region, bucket, lifecycle, object lock/immutability, and versioning.
- For backups, require restore verification, not just successful upload.
- Keep bucket policies least-privilege.
- Prefer named profiles/env injection from secret stores over plaintext config.

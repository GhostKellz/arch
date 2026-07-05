---
name: cktech-aur-audit
description: Audit AUR packages and Arch supply-chain incidents. Use for reviewing PKGBUILD/.install diffs, orphaned/adopted packages, suspicious npm/bun build steps, binary blobs, IOC scans, AUR malware advisories, and workstation compromise response.
---

# CKTech AUR Audit

- Review `PKGBUILD`, `.install`, patches, source URLs, maintainer changes, and new build-time dependencies before AUR updates.
- Watch for orphaned/adopted packages, forged metadata, `npm`/`bun` preinstall hooks, curl-to-shell, binary blobs, and persistence.
- Compare installed foreign packages with known-bad lists during incidents.
- Re-run archived IOC scanners when relevant.
- If a payload executed, treat workstation as compromised and rotate developer secrets.
- File incident/CVE notes under `~/arch/advisories/` or repo advisory docs.

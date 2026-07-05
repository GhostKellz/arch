---
name: cktech-arch-packaging
description: Maintain and audit Arch packaging for CKTech. Use for PKGBUILD, .SRCINFO, makepkg, package release sync, checksums, sources, depends/makedepends, provides/conflicts/replaces, clean builds, and Arch package security review.
---

# CKTech Arch Packaging

- Keep `PKGBUILD` and `.SRCINFO` in sync.
- Review `pkgver`, `pkgrel`, `source`, checksums, license, deps, makedeps, provides/conflicts/replaces.
- Never run unreviewed package scripts as root.
- Prefer clean build environments when testing package changes.
- Sync packaging with upstream manifest/changelog.
- Treat unexpected binary blobs, network fetches, and install scripts as audit triggers.

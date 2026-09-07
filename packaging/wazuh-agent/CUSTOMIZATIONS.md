# wazuh-agent — local customizations

The package is built from a clone of the AUR package `wazuh-agent` at
`/data/repo/wazuh-agent`. `origin` is `https://aur.archlinux.org/wazuh-agent.git`
— the maintainer's package, **not a fork we can push to**, so nothing local is
ever published upstream.

This directory is documentation only. It is deliberately not a second copy of
the PKGBUILD, which would rot the moment the maintainer publishes.

## Status: the delta is spent — sync to upstream

The local change was a **version bump ahead of the maintainer**, made to deploy
4.14.7 before it appeared in the AUR. Upstream has since published its own
4.14.7 (`ee544bc`, 2026-08-01) carrying a **byte-identical `sha512sums_x86_64`**,
so the local edit was a correct anticipation of the official update, not a
divergence. Per the maintainer's own note on the AUR page, 4.14.7 was ready
earlier but unpublishable while Arch DevOps had AUR pushes disabled during the
malware campaign.

There is nothing left for the delta to buy, and staying on it now *costs*
three upstream fixes:

| Upstream `ee544bc` adds | Effect of not having it |
| --- | --- |
| `conflicts=('wazuh-manager')` | pacman aborts with an unreadable "exists in filesystem" instead of naming the real conflict — agent and manager share ~164 files in `/var/ossec` |
| Correct `sha512sums_aarch64` (`5e3fadee…`) | ours is still 4.14.6's `eb0c101b…` against a 4.14.7 URL — fails closed, x86_64-only host, but wrong |
| `active-responses.log` creation in the install hook | `ossec.conf` declares a `localfile` at that path, so `wazuh-logcollector` logs `ERROR: (1103): Could not open file` |

Retire it:

```sh
cd /data/repo/wazuh-agent
git stash            # or: git checkout -- PKGBUILD .SRCINFO
git pull
git diff HEAD@{1} HEAD   # read what you're adopting
makepkg -si
```

Because the x86_64 RPM checksum is identical, this is a packaging-only change —
the running binaries do not change.

Do not rebase the bump forward version after version. Bridging a few weeks until
the maintainer catches up is reasonable; carrying it indefinitely turns a one-off
into an unmaintained private fork of someone else's package.

## What this package actually is

It repackages Wazuh's **prebuilt vendor RPM** from `packages.wazuh.com/4.x/yum/`
into a pacman package. There is no `build()` function; nothing is compiled. The
trust boundary is Wazuh the vendor plus the AUR maintainer, not the Arch build
process.

Three properties to keep in view when bumping the version:

- **No signature check.** `validpgpkeys=()` is empty and the `source` arrays
  carry no detached signature — the `.sig`/`.asc` files in the clone are orphans
  from the 4.7/4.8 era, dropped upstream in 2024. Integrity rests on `sha512sums`
  plus HTTPS alone. So when you bump the version, **verify the checksum against
  Wazuh's published value** rather than trusting whatever `updpkgsums` fetched:

  ```sh
  curl -s https://packages.wazuh.com/4.x/checksums/wazuh/$pkgver/wazuh-agent-$pkgver-1.x86_64.rpm.sha512
  ```

- **The SCA ruleset tracks a moving branch ref**
  (`.../refs/heads/main/.../cis_arch_linux.yml`), pinned by checksum. When Wazuh
  edits that file the build fails a checksum check rather than drifting silently
  — correct, but expect unprompted rebuild breakage.

- **`post_upgrade` defeats `.pacnew`.** The install hook unconditionally restores
  `ossec.conf.bak` over `ossec.conf` on every upgrade, so upstream `ossec.conf`
  changes are discarded rather than surfaced. Config preservation is the intent;
  the cost is that upstream config drift is invisible. Diff the packaged
  `ossec.conf` against yours after a version bump.

The maintainer's `prepare()` carries a real fix worth not regressing on rebase:
makepkg symlinks non-archive sources into `$srcdir` pointing at the `SRCDEST`
cache, and `patch(1)` refuses to follow symlinks (CVE-2015-1196 hardening).
Following them would patch the *cached* copy in place, breaking the checksum on
the next build — so the symlink is materialized into a real copy first.

## Audit

Reviewed 2026-08-25 against the `aur-audit` procedure. Verdict: **safe, no
evidence of compromise, no credential rotation warranted.**

- The x86_64 checksum verified against Wazuh's published `.sha512`, a fresh
  download hashed locally, and the maintainer's official 4.14.7 commit — three
  independent exact matches.
- The installed package's `.BUILDINFO` `pkgbuild_sha256sum` matches the audited
  working-tree PKGBUILD, and the shipped `.INSTALL` is byte-identical to the
  audited hook, so nothing was swapped between review and install.
- All 27 ELF sections of the shipped binaries match the vendor RPM except
  `.gnu_debuglink` — no byte of any loadable image differs. That delta is just
  makepkg's `strip`/`debug` running `objcopy --add-gnu-debuglink`.
- No build-time network access, no pipe-to-shell, no npm/pip/cargo injection.
  The install hook creates a system user, chowns `/var/ossec`, and prints
  instructions; it does **not** auto-enable the service or register with a
  manager, and makes no network calls.
- Maintainer history is ~2.5 years of unbroken single-author maintenance with no
  adoption gap or author/committer mismatch — none of the Atomic Arch forgery
  tells. Not on the known-bad package list.
- The CIS patch is SCA rule-YAML only: widens OS detection to `ID_LIKE=arch`,
  anchors patternless `not c:` rules (a real Wazuh SCA engine bug), and adds a
  `findmnt` fallback for `/tmp` mount checks. No rule disabled.

Scope limit: this verifies the *packaging* faithfully delivers Wazuh's official
binaries. It does not audit Wazuh's own shipped C daemons and Python wodles —
that trust transfer is unavoidable with any binary-repackage EDR agent.

`pacman -Qkk wazuh-agent` reporting ~428 altered files is expected, not an
integrity failure: `post_install` chowns `/var/ossec` after packaging and the
agent mutates its own state at runtime.

## Rebuilding

```sh
cd /data/repo/wazuh-agent
git fetch origin && git log --oneline origin/master -5
$EDITOR PKGBUILD                     # pkgver / pkgrel
updpkgsums                           # never hand-edit checksums
makepkg --printsrcinfo > .SRCINFO
makepkg -si
```

`pkgrel` resets to `1` whenever `pkgver` moves. `_remRevision` stays `1` — it is
Wazuh's own RPM revision (the `-1` in `wazuh-agent-4.14.7-1.x86_64.rpm`), not an
Arch field.

Review before building, every time — third-party AUR packaging for a daemon that
runs as root. See [AUDITING.md](../AUDITING.md) and [REVIEWING.md](../REVIEWING.md).

Build artifacts (`*.pkg.tar.zst`, `src/`, `pkg/`) stay in the clone under
`/data/repo`, which is why the clone does not live in this repo: `~/arch` is in
the restic critical backup tier and has no business carrying a 9 MB package
tarball.

## Verification

The agent runs as root with no `User=` in its unit, and its enrollment key is a
`backup=` file, so a bad upgrade can silently orphan the agent from the manager.
`/var/ossec` is root-only, so the last two need `sudo`.

```sh
pacman -Q wazuh-agent
systemctl is-enabled wazuh-agent && systemctl is-active wazuh-agent
sudo /var/ossec/bin/wazuh-control info
sudo test -s /var/ossec/etc/client.keys && echo "enrolled"
```

`client.keys`, `ossec.conf`, and `local_internal_options.conf` are all in
`backup=`. Check for `.pacnew` after every upgrade — though note the
`post_upgrade` caveat above, which is why diffing the packaged `ossec.conf`
matters more here than the `.pacnew` mechanism.

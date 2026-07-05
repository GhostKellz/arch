---
name: aur-audit
description: 'Security-review an Arch AUR package BEFORE building or installing it — read the PKGBUILD, .install, and .SRCINFO end-to-end, scan for build-time exfiltration / injected deps / install-hook backdoors, and judge maintainer provenance. Use when deciding whether an AUR package is safe, reviewing a PKGBUILD/-bin update diff, or triaging after the Atomic Arch (atomic-lockfile / js-digest) supply-chain wave. Read-only: it advises, it does not build. Triggers: "is this AUR package safe", "review this PKGBUILD", "audit this AUR package", "check before I install from the AUR", "did I get hit by the AUR malware".'
allowed-tools: Read, Grep, Glob
---

# Auditing an AUR package before you build it

An AUR package is **not** a binary from a signed repo — it is a `PKGBUILD`
shell script plus `.install` hooks that run on **your** machine, often under
`sudo` during `pacman -U`. `makepkg`/`paru -S`/`yay -S` a foreign package is
`curl | bash` with extra steps. The reflex: **read PKGBUILD + every `.install`
+ `.SRCINFO` end-to-end, scan for the red-flag classes, judge provenance, then
decide build / rebuild-clean / reject.** Official `core`/`extra`/`multilib`
(and CachyOS) are signed and out of scope — this is for the AUR only.

Reality check (Atomic Arch, 2026-06, CVSS 8.7): ~588 confirmed — up to ~1,500
under investigation — orphaned AUR packages were hijacked to pull a malicious
`npm`/`bun` dep whose `preinstall` hook dropped a Rust credential-stealer + an
optional eBPF rootkit. The packages were long-trusted and the commit metadata
was forged. **Trust and age are not safety signals.** (Sonatype "Atomic Arch";
BleepingComputer/Phoronix coverage; IOCs at `github.com/lenucksi/aur-malware-check`.)

## The one rule
Never `makepkg`/`paru -S`/`yay -S` a package you haven't read — `PKGBUILD`
**and** every `*.install`, `*.hook`, and `.SRCINFO` it ships, plus the diff on
every update. Keep `paru`/`yay` review prompts **on**; a clean PKGBUILD hiding a
malicious `.install` hook is the whole game.

## Step 1 — grep the PKGBUILD + install scripts for red flags
Any hit = stop and read that block in full before building:

```bash
grep -rnE \
 'curl|wget|nc |ncat|/dev/tcp|base64 -d|eval |exec\(|xxd|openssl enc|\|\s*(ba)?sh' \
 PKGDIR/PKGBUILD PKGDIR/*.install
grep -rniE \
 'npm i|npm install|bun (add|install)|npx|pip install|yarn add|cargo install' \
 PKGDIR/PKGBUILD PKGDIR/*.install
```

Red flags (rough order of severity):
- **Build-time network fetch** in `prepare()`/`build()`/`package()` — anything
  pulling code at build time beyond the declared `source=()` array (which is
  checksum-pinned). `source=()` + verified `sha256sums` is the *only* sanctioned
  fetch; a raw `curl`/`wget`/`git clone` inside a build function is not.
- **Injected package-manager deps unrelated to the software** — `npm install
  atomic-lockfile`, `bun install js-digest`, surprise `nodejs`/`bun`/`pip`
  pulls in a package that isn't a JS/Python project. This is the exact Atomic
  Arch vector.
- **`.install` hooks** — `pre_install`/`post_install`/`pre_upgrade` run as
  **root** during `pacman -U`. Any command there that fetches, decodes, or
  execs is a root-level backdoor. Read every line.
- **Obfuscation** — `base64 -d`, hex/`xxd`, `openssl enc`, or `eval`/`exec` on
  a decoded blob. A PKGBUILD has no legitimate reason to hide a command.
- **Piped remote execution** — `curl … | bash`, `wget … | sh`, `| python`.
- **Privileged / persistence ops** — writes to systemd units, `~/.bashrc`/
  `~/.zshrc`, `crontab`, `~/.ssh/authorized_keys`, `/etc/`, udev/pacman hooks.
- **`SKIP` checksums** — `sha256sums=('SKIP')` on a downloaded (not VCS) source
  disables integrity checking; treat as unverified input.

## Step 2 — provenance & metadata
- **Orphaned / recently-adopted** package (the Atomic Arch entry point) — a
  long-idle package with a sudden new maintainer and a fresh update is the
  single biggest tell. Check the AUR page's "Last adopted" / maintainer.
- **Maintainer e-mail changed without a name change**, or **forged commit
  metadata** (author name vs. actual account — `arojas` was impersonated via
  committer `PLYSHKA`). Don't trust the displayed name; the account is what
  matters.
- **`-bin` shadowing** — a `-bin` package that ships a prebuilt binary you
  can't inspect, especially one shadowing an official repo package. Prefer the
  source package or the official repo.
- **Diff against the official upstream** — compare the PKGBUILD's `source=()`
  URL and version to the real project. Typosquats and look-alike repos are common.
- **Redundancy** — is it in `extra`/`multilib`/CachyOS already? Signed repo
  beats AUR every time; the leanest safe move is often not using the AUR build.

## Step 3 — IOC triage (already installed / post-incident)
If the question is "did I get hit," use the upstream detection tooling rather
than hand-rolling checks:
- **`github.com/lenucksi/aur-malware-check`** — the community `package_list.txt`
  (known-bad names) + `iocs.txt` + scan scripts. Cross-reference `pacman -Qmq`
  against the known-bad set by exact match, then run the on-disk IOC sweep
  (payload hash/size, npm+bun caches, eBPF maps, install-hook strings, systemd
  persistence, miner artifact, live C2/processes).

Atomic Arch IOCs to look for by hand (full table in the advisory):
- `pacman -Qmq` ∩ the known-bad name list (exact match, no eyeballing).
- npm hook `"preinstall": "./src/hooks/deps"`; malicious pkgs
  `atomic-lockfile@1.4.2`, `js-digest`, `lockfile-js`.
- eBPF maps `/sys/fs/bpf/hidden_{pids,names,inodes}`.
- systemd persistence with `Restart=always`, `RestartSec=30`.
- C2 to the `…sneid.onion` service or `temp.sh POST /upload`; miner
  `/usr/bin/monero-wallet-gui`.

## Step 4 — if it's compromised
Removing the package is **not** enough once the payload has built/run — the
build already executed with your privileges. Treat the host as fully
compromised:
- **Rotate every secret class the stealer touches** — browser/Electron sessions
  (Slack/Teams/Discord), SSH keys, GitHub/npm tokens, Vault, Docker/Podman,
  VPN material, cloud keys, shell history. Use the `secrets` skill for the
  keyring-backed rotation flow.
- **If the build ran as root** (or the eBPF rootkit loaded), reinstall from
  trusted media — a userspace clean can't be trusted under a kernel rootkit.
- Preserve IOCs first (hashes, unit files, caches) if you want to write the
  incident up before you wipe.

## Decide
| Verdict | When |
|---|---|
| **Build** | PKGBUILD + install read clean, `source=()` checksum-pinned, no injected deps, maintainer/provenance sane. |
| **Rebuild clean / pin** | want it but the update diff is noisy — pin to a reviewed commit, clear `~/.cache/paru` build dir, rebuild from the audited PKGBUILD. |
| **Reject** | any build-time fetch/exec, injected unrelated dep, obfuscated `.install`, forged/orphan provenance, or `-bin` you can't inspect. Prefer the signed repo or upstream release. |

## See also
- `skill-audit` — the same read-before-you-trust discipline for Claude/Codex skills.
- `security` — appsec review of code you own; threat-modeling.
- `secrets` — leaked-secret scanning + the rotation flow to run after a compromise.
- `github.com/lenucksi/aur-malware-check` — the Atomic Arch known-bad list + IOC scanner.

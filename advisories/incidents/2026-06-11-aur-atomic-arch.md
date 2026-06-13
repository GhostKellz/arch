# AUR Supply-Chain Attack — "Atomic Arch" (atomic-lockfile / js-digest)

## Overview

- **Incident**: Mass compromise of Arch User Repository (AUR) packages
- **Tracking name**: "Atomic Arch" (Sonatype) / Sonatype-2026-003775
- **CVSS**: 8.7 (High)
- **First reported**: 2026-06-11 (Wave 1), 2026-06-12 (Wave 2)
- **Scope**: ~588 confirmed AUR package names across waves; reports of up to ~1,500 under investigation
- **Affects**: AUR only — official Arch/CachyOS repositories are **not** affected
- **Type**: Supply-chain — hijacked orphaned/abandoned AUR packages → malicious npm/bun dependency → ELF infostealer with optional eBPF rootkit
- **Our system status**: **NOT COMPROMISED** (see Results)

## How the Attack Works

1. Attackers adopt **orphaned/abandoned** AUR packages (legitimate, long-trusted projects).
2. They edit the `PKGBUILD` or `.install` script to pull a malicious dependency during build:
   - **Wave 1 (npm):** `npm install atomic-lockfile`
   - **Wave 2 (bun):** `bun install js-digest`
3. Git commit metadata is **forged** to impersonate long-standing maintainers (e.g. the `arojas` identity was forged via commit author `PLYSHKA`; the real account was never compromised).
4. The malicious npm package (`atomic-lockfile@1.4.2`) defines a `preinstall` hook `./src/hooks/deps` that runs a bundled Linux ELF the moment the package is built.
5. Because users assume "trusted package, new update available," they rebuild and execute the payload — often the build runs with elevated privileges.

### Payload (`deps`) capabilities
- Stripped Rust binary (async state machines). Linux **credential stealer** aimed at developer workstations.
- **Targets:** browser + Electron app data, Slack, Teams, Discord, GitHub, npm, Vault, Docker/Podman, SSH keys, VPN material, shell history, cloud keys.
- **Optional eBPF rootkit** (root + `CAP_BPF`): loads `scales.bpf.c`, hooks directory-listing syscalls, hides its files/processes/sockets via BPF maps `hidden_pids`, `hidden_names`, `hidden_inodes`.
- **Anti-analysis:** detects debuggers / security tooling.
- **Exfil/C2:** uploads to `temp.sh`; C2 over a Tor onion service. Persists via systemd (`Restart=always`, `RestartSec=30`).

## Indicators of Compromise (IOCs)

| Category | Indicator |
|----------|-----------|
| ELF payload (`deps`) | SHA256 `6144D433F8A0316869877B5F834C801251BBB936E5F1577C5680878C7443C98B` / MD5 `42B59FDBE1B72895B2951412222EBF40` / 3,040,376 bytes |
| ELF payload (js-digest) | SHA256 `7883BDA1FF15425F2DBE622C45A3AE105DDFA6175009BBF0B0CAD9BF5C79B316` |
| Cryptominer sample | SHA256 `47893d9badc38c54b71321263ce8178c1abb10396e0aadf9793e61ec8829e204` |
| Malicious npm/bun pkgs | `atomic-lockfile@1.4.2`, `js-digest`, `lockfile-js` (publisher `herbsobering`) |
| npm hook | `"preinstall": "./src/hooks/deps"` |
| eBPF maps | `/sys/fs/bpf/hidden_pids`, `/hidden_names`, `/hidden_inodes` |
| Persistence | `~/.config/systemd/user/<name>.service` or `/etc/systemd/system/<name>.service` with `Restart=always`, `RestartSec=30` |
| Filesystem | `/var/lib/<generated>`, `/usr/bin/monero-wallet-gui`, `~/.npm/_cacache`, `~/.bun/install/cache` references |
| C2 / exfil | `olrh4mibs62l6kkuvvjyc5lrercqg5tz543r4lsw3o6mh5qb7g7sneid.onion` (`POST /api/agent`, TCP/80, TCP/8080); `temp.sh POST /upload` |
| Attacker accounts | AUR: `krisztinavarga`, `custodiatovar`, `veramagalhaes`; Git: `PLYSHKA`; NPM: `herbsobering`; GH: `fardewoak` |

## Results — This System (CachyOS, 2026-06-12)

| # | Check | Method | Result |
|---|-------|--------|--------|
| 1 | Installed AUR pkgs vs known-bad list | `pacman -Qmq` (61 pkgs) ∩ 512 known-bad names | **CLEAN** — 0 matches |
| 2 | Known July-2025 browser RATs | `firefox-patch-bin`, `librewolf-fix-bin`, `zen-browser-patched-bin`, etc. | **CLEAN** — none installed |
| 3 | eBPF rootkit maps | `/sys/fs/bpf/hidden_{pids,names,inodes}` + `bpftool prog show` | **CLEAN** — absent / empty |
| 4 | `deps` ELF payload | `find / -xdev -type f -name deps -size 3040376c` | **CLEAN** — not found |
| 5 | npm cache | grep `atomic-lockfile/js-digest/lockfile-js` in `~/.npm/_cacache` | **CLEAN** — no matches |
| 6 | bun cache | grep same in `~/.bun` (bun-bin installed) | **CLEAN** — no matches |
| 7 | Injected install hooks | grep payload strings in `/var/lib/pacman/local/*/install` | **CLEAN** — no matches |
| 8 | Rogue systemd units | system + user units for `Restart=always` / payload strings | **CLEAN** — none |
| 9 | Cryptominer artifact | `/usr/bin/monero-wallet-gui` | **CLEAN** — absent |
| 10 | Suspicious processes / C2 | `pgrep` tor/deps/atomic; tun interfaces | **CLEAN** — only Tailscale + libvirt bridge (expected) |

**Conclusion:** No indicator of the Atomic Arch campaign (or the July-2025 CHAOS-RAT browser packages) is present. No remediation required. Wazuh agent (`wazuh-agent 4.14.5`) is installed and can be used for ongoing FIM/alerting.

## What We Did

1. Pulled the community known-bad package list and IOCs from [`lenucksi/aur-malware-check`](https://github.com/lenucksi/aur-malware-check).
2. Cross-referenced all 61 installed foreign packages against the 512-name known-bad set — exact match, no eyeballing.
3. Ran a full on-disk IOC sweep (payload hash/size, npm + bun caches, eBPF maps, install-script hooks, systemd persistence, miner artifact, live processes/C2).
4. Confirmed system clean; archived the reusable scan script at `../checks/aur-atomic-arch-scan.sh`.
5. Removed scratch artifacts created during the investigation.

## Recommended Hygiene (going forward)

- Never blindly update AUR packages — review `PKGBUILD` and `.install` diffs before every build.
- Be suspicious of updates that newly introduce `npm`/`bun`/`nodejs` dependencies unrelated to the software, or that change the maintainer e-mail without a name change.
- Prefer `paru`/`yay` review prompts; keep them enabled.
- If ever affected: treat the host as fully compromised. Removing the package is **not** sufficient once the payload has run. Rotate all secrets the stealer touches (browser sessions, SSH keys, GitHub/npm tokens, Slack/Teams/Discord sessions, Vault, Docker/Podman, cloud keys). If it ran as root, reinstall from trusted media.

## References

- [Phoronix — AUR sees 400+ packages compromised](https://www.phoronix.com/news/Arch-Linux-AUR-400-Compromised)
- [Sonatype — Atomic Arch npm campaign](https://www.sonatype.com/blog/atomic-arch-npm-campaign-adds-malicious-dependency)
- [ioctl.fail — Preliminary analysis of AUR malware](https://ioctl.fail/preliminary-analysis-of-aur-malware/)
- [BleepingComputer — Over 400 Arch Linux packages compromised](https://www.bleepingcomputer.com/news/security/over-400-arch-linux-packages-compromised-to-push-rootkit-infostealer/)
- [The Hacker News — eBPF rootkit + infostealer](https://thehackernews.com/2026/06/over-400-arch-linux-aur-packages.html)
- [PrivacyGuides — ~1,500 AUR packages compromised](https://www.privacyguides.org/news/2026/06/12/around-1-500-aur-packages-compromised-with-rootkit-like-malware/)
- [Detection tooling — github.com/lenucksi/aur-malware-check](https://github.com/lenucksi/aur-malware-check) (`package_list.txt`, `iocs.txt`, scan scripts)

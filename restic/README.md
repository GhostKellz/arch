# 👻 Restic Backup Automation

[![Restic](https://img.shields.io/badge/Restic-Backup-34A853)](https://restic.net/) [![Systemd](https://img.shields.io/badge/Systemd-Timers-0078D4)](https://freedesktop.org/wiki/Software/systemd/) [![Wasabi](https://img.shields.io/badge/Wasabi-S3-01A94E)](https://wasabi.com/) [![TPM2](https://img.shields.io/badge/TPM2-Sealed-4B275F)](https://www.freedesktop.org/software/systemd/man/systemd-creds.html) [![GhostSecured](https://img.shields.io/badge/Ghost-Secured-6B21A8)](#)

---

## 📖 Overview

This directory manages fully automated backup strategies using **Restic** with:

- ✨ Backups to **Wasabi** (S3, bucket `ck-arch`, `us-east-1`)
- 🔐 Credentials **TPM2-sealed** via `systemd-creds` — no plaintext env file
- ⏳ Scheduled **systemd timers** (daily backup, weekly integrity check)
- 🔔 **Loud failure** — `OnFailure=` alerting on every unit
- ✨ **Pruning** old snapshots automatically

Optimized for secure, encrypted, and deduplicated backups with minimal manual intervention.

> ⚠️ **Migrated off MinIO (2026-08).** The old `ckels.com` MinIO endpoint went
> NXDOMAIN and the backup failed silently for **26 consecutive nights** — no
> `OnFailure=`, output buried in `/var/log/restic.log`. That is why alerting and
> verification are now first-class below. See 💀 Post-Mortem.

---

## 🌐 Key Files

| File | Purpose |
|:----|:--------|
| `restic-critical.service` | One-shot service — backs up the critical tier and applies snapshot retention |
| `restic-critical.timer` | Daily schedule, `RandomizedDelaySec=30m` |
| `restic-check.service` | Repo integrity check, `--read-data-subset=15%` |
| `restic-check.timer` | Sundays 04:00, `RandomizedDelaySec=1h` |
| `restic-prune.service` / `.timer` | Monthly repository compaction |
| `restic-failure@.service` | Alert path — writes `LAST_FAILURE` + desktop toast |
| `include.txt` | What gets backed up → `/etc/restic/` |
| `exclude.txt` | Sockets and transient state → `/etc/restic/` |
| `policy.json` | Wasabi sub-user IAM policy (reference copy) |
| `restic.env.example` | Template only — documents where the real secrets live |

---

## 🎯 Backup Scope

**Critical tier only** — data that exists nowhere else:

| Path | Why |
|:----|:--------|
| `~/brain/private` | gitignored, local-only, on no remote |
| `~/brain/wiki` | pushed, but the working copy holds unpushed edits — and it's small |
| `~/arch` | public repo, same reasoning — and it holds this backup config |
| `~/.gnupg` | private keys, unrecoverable |
| `~/.ssh` | private keys |
| selected `~/.claude` paths | durable config, rules, reference, skills, and lessons |
| `/etc` | small, and rebuilding it by hand is a bad afternoon |

🚫 **Deliberately not backed up:** `/data/projects` (GitLab remotes already
back it up) and `~/.cache` (43G of reproducible junk). Bulk coverage is a future
Proxmox Backup Server tier.

> A git remote is not a backup of the working tree. `~/arch` and `~/brain/wiki`
> are cheap to carry, so they ride along here; `/data/projects` is not.

---

## ☁️ Wasabi Bucket

| Setting | State |
|:----|:--------|
| Bucket / Region | `ck-arch` · `us-east-1` · `s3.wasabisys.com` |
| Versioning | ✔️ Enabled |
| Object Lock | ✔️ **Permanently enabled** (irreversible, set at creation) |
| Default Object Retention | ➖ Off for Restic compatibility |
| Replication / Logging | ➖ Off — both reversible, skipped |

Object Lock remains available on the bucket, but no bucket-wide default
retention is applied. Restic does not manage S3 Object Lock retention dates;
Versioning and the sub-user's lack of `s3:DeleteObjectVersion` provide the
workstation's rollback protection without obstructing repository maintenance.

---

## 🔐 Credentials

No plaintext env file. Both secrets are sealed with `systemd-creds` (TPM2 + host
key) and loaded per-run via `LoadCredentialEncrypted=`, appearing in `%d` as
non-swappable files readable only by the unit.

| Credential | Sealed path | Unit ID |
|:----|:--------|:--------|
| Repo password | `/etc/credstore.encrypted/restic-repo-password` | `repopw` |
| Wasabi keys | `/etc/credstore.encrypted/restic-aws-credentials` | `aws` |

The `--name=` given to `systemd-creds encrypt` **must** match the unit ID or the
unit refuses to start. Credential paths are passed through each `ExecStart=`
using `%d`; `Environment=...%d/...` is incorrect because `Environment=` retains
that text literally.

> 🗝️ **Escrow the repo password in your password manager.** The sealed copy is
> TPM-bound to this motherboard. Board dies → sealed copy dies → the password
> manager holds the only key to the repo. No password, no restore, ever.

**Wasabi identity:** sub-user `ck-arch` — an IAM user *inside* the existing
account, not a separate account. Programmatic only, no console, **no MFA** (a
midnight timer can't produce an MFA token). Exactly one policy attached:
`ck-arch-restic`, matching `policy.json`. No built-ins — those are all
account-wide.

Deliberately absent from the policy: `s3:DeleteObjectVersion` and
`s3:BypassGovernanceRetention`. A compromise of this workstation therefore
cannot purge version history or override Object Lock. A root key was rejected for
exactly that reason — root can bypass Governance mode, making the lock decorative.

✔️ Scoping verified: `s3 ls s3://ck-arch` succeeds, bare `s3 ls` returns
`AccessDenied`. This key cannot see the Comet / Veeam / client buckets.

---

## 📚 Basic Setup

### Install
```bash
sudo install -m644 restic-critical.service restic-critical.timer \
                   restic-check.service restic-check.timer \
                   restic-prune.service restic-prune.timer \
                   restic-failure@.service /etc/systemd/system/
sudo install -Dm644 include.txt exclude.txt -t /etc/restic/
sudo systemctl daemon-reload
```

### Enable & Start the Timers
```bash
sudo systemctl enable --now restic-critical.timer restic-check.timer \
                              restic-prune.timer
```

### Manual Run (Optional)
```bash
sudo systemctl start restic-critical.service
```

### Did last night's backup run?
```bash
systemctl status restic-critical.service
ls -l /var/lib/restic/LAST_FAILURE     # absent == no failure since last clear
```

---

## 🛡️ Security Notes
- Backup repos are encrypted by Restic natively.
- Credentials are **TPM2-sealed**, never a plaintext env file, never in this repo.
- Wasabi access is a **scoped sub-user**, not a root key — bucket-limited, and
  unable to delete object versions or bypass Object Lock.
- Units run hardened: `ProtectSystem=strict`, `ProtectHome=read-only`,
  `NoNewPrivileges=true`, `RestrictAddressFamilies=`.
- ⚠️ This repo is **public**. `restic/*.env` is gitignored; only `*.env.example`
  is ever tracked.

---

## 💀 Post-Mortem — why this was rebuilt

`restic-backup.service` pointed at MinIO on `ckels.com`. That domain stopped
resolving on **2026-07-22**. restic exited non-zero every night through
**2026-08-17** and nobody knew, because:

- output went to `/var/log/restic.log`, a file nobody reads
- there was no `OnFailure=` — nothing notified anyone
- `systemctl --failed` was the only signal, buried under 27 unrelated
  `drkonqi-coredump-processor@*` failures

It also only ever covered `/home` — `/data/projects` was never in scope at all.

**Rules that came out of it:**

1. 🔔 **Failure must be loud.** Every unit has `OnFailure=restic-failure@%n.service`,
   which writes `/var/lib/restic/LAST_FAILURE` and fires a desktop toast. (A bare
   `notify-send` from a root unit never reaches the session — it goes through
   `systemd-run --uid=1000` with an explicit `DBUS_SESSION_BUS_ADDRESS`.)
2. 🔍 **A backup that has never been verified is a hypothesis.** Weekly
   `restic check --read-data-subset=15%` covers the whole repo about every 7 weeks.
3. 🧪 **A backup that has never been restored is a rumor.** See below.

---

## 🌟 Highlights
- **Encrypted** ✔️
- **Deduplicated** ✔️
- **TPM2-sealed credentials** ✔️
- **Versioned off-site storage** ✔️
- **Alerts on failure** ✔️
- **Pruned** (14 daily, 8 weekly, 6 monthly snapshots)
- **Ghost-tested** — zero-trust mindset

> 🌟 Built for reliability. Optimized for flexibility. Minimal human error.

---

## 🧪 Restore Drill

Untested backups are not backups. Restore a selected path to project-local
scratch, compare it against the live source, then remove the scratch copy.
Periodically include sensitive key material using a tightly controlled target.

| Date | Result |
|:----|:--------|
| 2026-08-18 | PASS — `/etc/hostname` restored from Wasabi and matched byte-for-byte |

---

## 🔗 Related
- [Restic Official Docs](https://restic.net/)
- [Systemd Timers Guide](https://wiki.archlinux.org/title/Systemd/Timers)
- [systemd-creds](https://www.freedesktop.org/software/systemd/man/systemd-creds.html)
- [Wasabi Object Lock](https://docs.wasabi.com/docs/object-locking)
- [Proxmox Backup Server](https://www.proxmox.com/en/proxmox-backup-server)

---

_"Backups are your last line of defense. Encrypt them. Automate them. Validate them."_

👻 Stay Ghosted, Stay Protected.

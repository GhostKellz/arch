# systemd Policy and Timers

## Memory control

- `user.slice` is monitored by systemd-oomd for sustained memory PSI only.
- `agent-workload.slice` bounds explicitly launched agent/build work to
  `MemoryHigh=16G`, `MemoryMax=24G`, and `MemorySwapMax=16G`.
- `earlyoom` remains disabled to avoid competing userspace OOM policies.

See `memory.md` and `systemd/user/agent-workload.slice`.

## Journal retention

`systemd/journald.conf.d/60-workstation.conf` makes the existing persistent
journal policy explicit: compression enabled, 4 GiB maximum use, 50 GiB kept
free, 256 MiB file rotation, and 30 days maximum retention. Do not reduce this
to CachyOS's generic 50 MiB limit; this host needs bounded crash and lockup
history.

Install and verify:

```bash
sudo install -Dm644 systemd/journald.conf.d/60-workstation.conf \
  /etc/systemd/journald.conf.d/60-workstation.conf
sudo systemctl restart systemd-journald
systemd-analyze cat-config systemd/journald.conf
journalctl --disk-usage
```

## Snapper and Btrfs

- Snapper timeline creation is overridden from hourly to daily because the root
  configuration retains daily snapshots and zero hourly snapshots.
- Snapper cleanup remains hourly and count-based.
- Qgroups remain disabled to avoid high-churn accounting overhead; therefore
  Snapper `SPACE_LIMIT` and `FREE_LIMIT` are not enforcement mechanisms.
- The packaged per-filesystem scrub timers remain disabled. They can overlap and
  concurrent `/` plus `/data` scrubs caused a hard lockup on this workstation.
- `weekMain.timer` runs lightweight health checks and bounded cache cleanup
  weekly; it never launches scrub or balance.
- `btrfs-scrub-safe.timer` follows upstream's monthly recommendation. Its
  service verifies one filesystem at a time, read-only, at 64 MiB/s, with both
  Btrfs-native and systemd cgroup bandwidth limits plus an exclusive lock. It
  skips a busy or newly booted host.
- Both timers are deliberately non-persistent: a missed maintenance window
  never triggers catch-up work during an interactive boot.
- Btrfs balance is never scheduled blindly. Run a filtered balance only after
  inspecting allocation and confirming it is needed.

## Weekly maintenance

`weekMain.timer` runs the bounded `/usr/local/bin/weekly-maintenance` health and
cache job. It does not perform package/AUR upgrades, orphan deletion, Btrfs
balance, DKMS builds, or user development-tool updates.

Inspect timers and their previous results:

```bash
systemctl list-timers --all
journalctl -u weekMain.service -u btrfs-scrub-safe.service
```

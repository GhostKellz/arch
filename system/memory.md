# Workstation Memory Policy

This is the source of truth for the 64 GiB Ryzen 9 9950X3D workstation. The
system runs Arch Linux with `linux-cachyos-lto` as its primary kernel;
`linux-zen` is a fallback only.

## Design goals

- Preserve gaming and interactive desktop latency.
- Let cold anonymous pages use compressed RAM instead of sacrificing file cache.
- Kill a sustained runaway workload before the desktop becomes unusable.
- Never use swap occupancy alone as proof of memory pressure.
- Keep agent and build scratch off `/tmp`, which is RAM-backed on this host.

## ZRAM

Install [`memory/zram-generator.conf`](memory/zram-generator.conf) as
`/etc/systemd/zram-generator.conf`.

This workstation explicitly sets logical zram capacity equal to physical RAM,
uses zstd, and assigns priority 100. The host uses a CachyOS kernel but does not
have the `cachyos-settings` userland package installed, so do not present these
values as inherited CachyOS defaults. The device size is a maximum amount of
uncompressed data; it does not reserve that amount of RAM. Physical memory and
CPU are consumed only as pages are compressed into or read from zram.

Zswap must remain disabled when zram is the swap device:

```bash
cat /sys/module/zswap/parameters/enabled
# N
```

Changing zram capacity takes effect on reboot. Do not live `swapoff` a heavily
used zram device.

## VM reclaim policy

Install [`sysctl/99-sysctl.conf`](sysctl/99-sysctl.conf) as
`/etc/sysctl.d/99-sysctl.conf`.

`vm.swappiness=150` reflects the low relative cost of compressed in-memory swap.
`vm.page-cluster=0` avoids read-ahead intended for slow disk swap. Fixed dirty
ceilings start background writeback at 64 MiB and cap dirty data at 256 MiB so
the limits do not grow into multi-gigabyte bursts with total RAM.

## Userspace OOM policy

Install [`memory/50-oomd.conf`](memory/50-oomd.conf) as
`/etc/systemd/system/user.slice.d/50-oomd.conf`.

systemd-oomd monitors sustained PSI memory pressure on `user.slice`. It must not
use `ManagedOOMSwap=kill`: a full zram device by itself is not proof that the
machine is stalled. Keep `earlyoom` disabled so only one userspace policy makes
kill decisions.

## Workload containment

Install [`systemd/user/agent-workload.slice`](systemd/user/agent-workload.slice)
in `~/.config/systemd/user/` and use
[`../scripts/agent-scope.sh`](../scripts/agent-scope.sh) for agent/build commands.
The aggregate slice starts reclaim at 16 GiB, has a 24 GiB hard ceiling, and
allows at most 16 GiB of swap. This
protects the browser and desktop from a runaway compiler, analyzer, test, or
agent without restricting games, the VM, or the whole user session.

The tracked zsh configuration routes ordinary `codex`, `claude`, and `gemini`
commands through this slice. Their explicitly named `*-unscoped` commands are
deliberate escape paths for exceptional work; use them only while monitoring
memory pressure.

## Journal retention

Install [`systemd/journald.conf.d/60-workstation.conf`](systemd/journald.conf.d/60-workstation.conf)
under `/etc/systemd/journald.conf.d/`. Persistent compressed logs are capped at
4 GiB with 50 GiB reserved free and 30 days maximum retention. The size retains
enough history for lockup diagnosis without adopting CachyOS's workstation-wide
50 MiB limit.

## `/tmp`

`/tmp` remains a tmpfs capped at 12 GiB. This is a ceiling, not a reservation.
Normal agent scratch belongs in a project-local `.scratch/` directory on disk.
Do not lower the cap without measured usage and do not use `/tmp` for builds or
bulk logs.

## Coredumps and terminal output

Install [`memory/60-workstation-limits.conf`](memory/60-workstation-limits.conf)
under `/etc/systemd/coredump.conf.d/`. It retains useful crash diagnostics while
preventing multi-gigabyte dumps from accumulating without a bound.

Ghostty uses a 10 MB scrollback limit per surface. Commands must still bound
journal/build output; scrollback is a guardrail, not a substitute for filtering.

## KVM allocation

`CKEL-VM-01` is intentionally configured for 8 GiB RAM and 4 vCPUs persistently.
Changes apply at its next normal shutdown/start. Do not live-balloon or stop the
guest merely to apply this policy.

## Verification

```bash
zramctl
swapon --show
sysctl vm.swappiness vm.page-cluster vm.dirty_bytes vm.dirty_background_bytes
oomctl
cat /proc/pressure/memory
cat /proc/pressure/io
systemctl --user status agent-workload.slice
journalctl --disk-usage
virsh dominfo CKEL-VM-01
```

Investigate pressure using PSI, zram compression statistics, cgroup memory, and
the complete kernel event. Do not infer a root cause from swap percentage alone.

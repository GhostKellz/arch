# Workstation Pressure and Application-Kill Diagnosis

Use measurements from the same event. Swap occupancy, free RAM, or a process
name alone is not a diagnosis.

## First capture

```bash
date --iso-8601=seconds
free -h
zramctl
swapon --show
cat /proc/pressure/memory
cat /proc/pressure/io
cat /proc/pressure/cpu
systemd-cgtop --depth=3 --iterations=1
```

Then inspect a bounded journal window around the event:

```bash
journalctl -k --since '-5 min' --no-pager -n 300
journalctl --user --since '-5 min' --no-pager -n 300
```

Never stream an unfiltered multi-boot journal into Ghostty. Large terminal
output has itself produced severe I/O pressure and multi-gigabyte terminal
memory peaks on this workstation.

## Interpret the signals together

- High memory PSI means tasks are stalling on memory reclaim.
- High I/O PSI with low memory PSI points to storage or terminal/log churn.
- High zram occupancy is not itself pressure, but a completely full zram device
  removes swap headroom and must be correlated with the kernel event.
- `MemAvailable` is more useful than `MemFree`, but neither replaces the OOM
  task table, zone information, PSI, and zram statistics.
- The selected OOM victim is not necessarily the process that created the
  pressure. Chromium applications commonly carry a positive OOM score.
- Cgroup `MemoryCurrent` includes charged file cache and can be much larger than
  the resident set of its processes. Correlate it with PSI, swap, reclaim, and
  current activity before declaring a service runaway.

## Known contributors on this host

- The zram ceiling was reduced from approximately 31 GiB to 16 GiB on
  2026-04-24. Every retained global OOM after that change occurred with the
  16 GiB device essentially full. The workstation now follows the explicit
  RAM-sized local policy documented in `memory.md`.
- `CKEL-VM-01` was configured for 16 GiB and 6 vCPUs even though the intended
  allocation was 8 GiB and 4 vCPUs.
- Historical dev processes reached 9-30 GiB RSS. Agent/build workloads belong
  in `agent-workload.slice`.
- Ghostty reached approximately 6.8 GiB peak memory while processing excessive
  output and was the source of a captured high-I/O-PSI incident.
- Baloo has previously generated heavy cumulative I/O. It is configured for
  filename-only indexing and development caches should remain excluded.
- Baloo can retain several GiB of cgroup-charged index file cache while idle;
  this accounting is not equivalent to its process RSS.
- Wazuh has shown a historical cgroup peak around 5.5 GiB but was near 1.3 GiB
  with no swap during the latest audit. Recheck only if the peak repeats with
  pressure.
- Large crash batches can create coredump/DrKonqi processing storms; coredumps
  are bounded by the policy in `memory/`.

## Triage order

1. Capture PSI, zram, available RAM, and cgroup usage.
2. Determine whether the symptom was a kernel OOM kill, systemd-oomd action,
   application crash, or desktop/I/O stall.
3. If I/O PSI is high, inspect live per-cgroup I/O before blaming memory.
4. If memory PSI is high, identify the growing cgroup and confirm whether it was
   launched in the bounded workload slice.
5. Preserve only a bounded journal window and the complete relevant OOM block.
6. Change one policy variable at a time unless correcting a known-bad bundle.

See `memory.md` for the installed policy and verification commands.

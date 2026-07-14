# freeze-diagnosis.md

Diagnosing "my system froze / went critical" on a 64GB workstation.

**The one-line lesson:** a full zram device is *not* memory pressure. Most
"critical" freezes on this box are **I/O stalls**, not RAM exhaustion. Measure
pressure before you blame memory.

---

## The trap: zram "swap used" looks catastrophic but isn't

zram is *compressed RAM*, not a disk. When `free -h` or a system monitor shows
15GB of 16GB swap used, that is not 15GB of thrashing — zstd compresses it
roughly 2.5:1, so it occupies far less physical RAM.

Real capture from an event that felt "critical":

```
$ zramctl
NAME       ALGORITHM DISKSIZE  DATA COMPR TOTAL MOUNTPOINT
/dev/zram0 zstd           16G 14.7G  5.7G  5.9G [SWAP]
```

14.7GB of swapped pages → **5.9GB of actual RAM**. Meanwhile `free` reported
26GB available. Nothing was starving. With `swappiness=10` the kernel had simply
parked cold pages in zram and left them there; that is zram working as designed,
not a warning sign.

**Do not use swap percentage as a health metric on a zram system.**

---

## Diagnose with PSI, not vibes

`/proc/pressure/*` (kernel Pressure Stall Information) is the ground truth. It
reports the share of time tasks stalled waiting on a resource.

```bash
cat /proc/pressure/memory   # real memory stall
cat /proc/pressure/io       # disk stall
cat /proc/pressure/cpu      # cpu contention
```

From the same "critical" event:

```
memory: some avg10=0.00  full avg10=0.00     # zero memory pressure
io:     some avg10=64.84  full avg10=55.82    # everything stalled on disk
```

- `full avg10 > ~20` on **io** → the machine is choking on disk, not RAM.
- `full avg10` near 0 on **memory** → memory is fine no matter what swap says.

Rule of thumb: **if memory PSI is ~0 and io PSI is high, stop looking at RAM.**

---

## Find the actual culprit

### Who is in swap (usually harmless, but shows the picture)

```bash
for f in /proc/*/status; do
  awk '/^Name:/{n=$2}/^VmSwap:/{if($2>0)print $2, n}' "$f" 2>/dev/null
done | sort -rn | head
```

Example ranking (KB): qemu 4.1G · codex ×2 2.4G · rust-analyzer 1.76G ·
claude ×2 1.0G · baloo 809M · brave renderers. It is always the *sum* of the
dev stack, never "one VM."

### Who is hammering the disk (this is what freezes you)

```bash
for f in /proc/*/io; do
  p=$(dirname "$f")
  r=$(awk -F': ' '/^read_bytes/{print $2}' "$f" 2>/dev/null)
  w=$(awk -F': ' '/^write_bytes/{print $2}' "$f" 2>/dev/null)
  [ -n "$r" ] && echo "$((r+w)) $(cat "$p/comm" 2>/dev/null)"
done | sort -rn | head
```

Result that solved the case (cumulative bytes over process lifetime):

```
248 GB  baloo_file    <- KDE file indexer, 8x everything else
 32 GB  zsh
 26 GB  brave
 18 GB  codex
```

Live view instead of cumulative: `sudo iotop -ao` or `dstat -d --top-io`.

---

## Root cause on this box: KDE Baloo content indexing

`baloo_file` content-indexes the *contents* of files. Its default exclude list
targets a normal user's home, not a developer's — it misses language build
caches entirely. On this machine it had indexed **2.66 million files** into a
**7.34GB** index, generating 248GB of I/O and stalling the whole system.

The gap: the stock list excludes `node_modules`, `.venv`, `.terraform`,
`CMakeFiles`, but **not** the caches that dominate a rust/zig/go/python/node box:
`target/`, `.cargo/`, `.rustup/`, `.cache/`, `.zig-cache/`, `zig-out/`, `~/go`,
`build/`, `dist/`.

### Fix: filename-only indexing + exclude dev caches

Keep instant file-*name* search in KRunner/Dolphin, kill the content thrashing.

Edit `~/.config/baloofilerc`:

```ini
[Basic Settings]
Indexing-Enabled=true

[General]
onlyBasicIndexing=true
exclude filters=...,target,.cargo,.rustup,.cache,.rust-analyzer,.zig-cache,zig-out,zig-cache,go,pkg,dist,build,.gradle,.m2
```

Apply (a plain `enable` re-reads config; toggle to be safe):

```bash
balooctl6 disable
balooctl6 enable
balooctl6 status
```

Verify `Files waiting for content indexing: 0` and that the index stops growing.

### Alternatives

- **Full-text code search** — don't rely on Baloo. `ripgrep` (`rg`) and `fd` are
  git-aware, respect `.gitignore`, and are far faster.
- **Don't use KDE search at all** — `balooctl6 disable` and forget it.
- **Keep content indexing** — only if you truly use Dolphin full-text; then the
  exclude list is mandatory, not optional.

---

## Playbook: "system feels critical"

1. `cat /proc/pressure/memory` and `/proc/pressure/io` — which resource?
2. Memory PSI ~0? Ignore the swap number entirely; it's a zram red herring.
3. io PSI high? Rank `/proc/*/io` by bytes; find the disk hog.
4. Fix the hog (indexer, runaway build, backup job), don't tune RAM.
5. Only if **memory** PSI is genuinely high: revisit zram size, dirty ratios,
   and `systemd-oomd` in `memory.md`.

---

See also: `memory.md` (zram, swappiness, OOM), `io.md` (schedulers, writeback).

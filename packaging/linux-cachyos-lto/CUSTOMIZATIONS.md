# linux-cachyos-lto — local customizations

The kernel is built from a clone of upstream `CachyOS/linux-cachyos` at
`/data/repo/linux-cachyos` (this package is the `linux-cachyos/` subdir).
`origin` is upstream itself, **not a fork**, so nothing local is ever pushed.

The local delta lives on branch **`ghostkellz`**, tracking `origin/master` and
rebased after each upstream release lands. This directory is documentation plus
the one file upstream does not carry (`ghostzen5.patch`); it is not a second
copy of the PKGBUILD, which would rot.

Backups of prior PKGBUILDs and configs: `/data/backup/linux-cachyos/`.

## The delta

Everything below is applied to `linux-cachyos/PKGBUILD`.

### Knob flips

These are `: "${_var:=…}"` defaults; upstream supports every value, we just
pick a different one. They can equivalently be set in the environment.

| Knob | Upstream | Ours | Why |
| --- | --- | --- | --- |
| `_cpusched` | `cachyos` | `bore` | BORE scheduler |
| `_per_gov` | `no` | `yes` | performance governor as default |
| `_tcp_bbr3` | `no` | `yes` | BBR3 congestion control + FQ qdisc |
| `_processor_opt` | *(empty → native)* | `zen5` | Ryzen 9000X3D; needs `ghostzen5.patch` |
| `_use_llvm_lto` | `thin` | `full` | full LTO |
| `_use_lto_suffix` | `no` | `yes` | package name `linux-cachyos-lto` |

The remaining performance defaults are intentionally retained: O3
(`_cc_harder=yes`), 1000 Hz, full tickless operation, full preemption, and
THP-always.

For the `always` profile, shmem and tmpfs retain the proven installed baseline's
`within_size` policy. This permits hugepages when an allocation remains inside
the object size, without the unconditional memory-footprint risk of selecting
shmem/tmpfs `always`. The current upstream input config changed both defaults to
`advise`, so these symbols are set explicitly during `prepare()`.

### znver5 support — `ghostzen5.patch`

Upstream's patchset stops at `CONFIG_MZEN4`. `ghostzen5.patch` deliberately
mirrors that implementation: it adds `CONFIG_MZEN5` to
`arch/x86/Kconfig.cpu` and the matching `-march=znver5` to
`arch/x86/Makefile`. Selecting Zen 5 replaces the MZEN4/native/generic choice;
it is not shorthand for `-march=native`.

Wiring in the PKGBUILD:

- added to `source=()` — `prepare()` has a generic loop that applies every
  `*.patch` in `source[]` with `patch -Np1`, so no separate apply step;
- the CPU-optimization `case` in `prepare()` gains a `ZEN5)` arm, and every
  other arm gains `-d MZEN5`, so the `MZEN*` symbols stay mutually exclusive.

It applies with fuzz 2 (its context lines use a tab where the tree uses
spaces). `patch -Np1` defaults to fuzz 2, so this works — but it is the
first thing to check after a rebase. Verify against the release tag tree
(`CachyOS/linux` tag `cachyos-<ver>`), **not** the `cachy` branch: the
branches are components, the release tag is what the tarball is built from.

### BBR3 block fix

Upstream's `_tcp_bbr3` block is wrong in two ways, so we rewrite it:

- it enables `TCP_CONG_BBR` / `DEFAULT_BBR`, i.e. plain BBR, not BBR3;
- it passes `CONFIG_DEFAULT_FQ_CODEL` / `CONFIG_DEFAULT_FQ` to
  `scripts/config`, which does not strip a `CONFIG_` prefix — those two
  lines were silently no-ops and the FQ qdisc default never got set.

Ours sets `TCP_CONG_BBR3`, `DEFAULT_BBR3`, `DEFAULT_TCP_CONG="bbr3"`,
`NET_SCH_FQ` and `DEFAULT_FQ`.

### Full preemption without runtime switching

The proven installed baseline used `PREEMPT=y`, `PREEMPT_LAZY=n`, and
`PREEMPT_DYNAMIC=n`. Preserve that behavior explicitly: the `full` and `lazy`
arms disable `PREEMPT_DYNAMIC`; only the explicit `dynamic` arm enables it.
The current upstream PKGBUILD stopped changing this symbol, so omitting the
local handling would silently retain the input config's
`PREEMPT_DYNAMIC=y`.

### b2sums

Upstream's `b2sums` only covers the sources *its* default knobs pull in.
Ours adds two entries, positionally: `ghostzen5.patch` (after `config`) and
`sched/0001-bore-cachy.patch` (last). `updpkgsums` regenerates the whole
array correctly, so prefer that over hand-editing.

## Not customized

- **`config`** — taken from upstream verbatim. Everything we want is
  expressed through PKGBUILD knobs, which `prepare()` re-applies via
  `scripts/config`. A `config` in the build dir with a version header
  matching a kernel we built is a **build artifact**, not a source of
  truth; overwrite it.
- **nvidia** — `_build_nvidia_open=no`. `nvidia-open` is built separately
  via DKMS, so the PKGBUILD's whole nvidia block is inert and its `_nv_ver`
  is irrelevant to us.
- **zfs, debug, r8125** — all off.

## Prerequisite: upstream signing keys

Upstream uses `validpgpkeys` plus a detached release signature. These keys live
in *your* GPG keyring, not pacman's, so `cachyos-keyring` does not satisfy the
makepkg check.

```sh
gpg --recv-keys E18447AC260021D31F3FF6C4C8A2A4774B8B63C4 \
                E8B9AA39F054E30E8290D492C3C4820857F654FE
```

Both fingerprints were checked against keyserver.ubuntu.com and match the
maintainers who sign the releases (Eric Naim `dnaim@cachyos.org`, Peter Jung
`admin@ptr1337.dev`). Recheck current key validity rather than relying on an
expiry date copied into documentation.

Do not use `--skippgpcheck` for the real build. It is acceptable only for an
isolated, non-installing source-preparation audit when checksum verification
remains enabled.

## Rebase onto a new release

```sh
cd /data/repo/linux-cachyos
git fetch origin
git rebase origin/master ghostkellz
git branch --set-upstream-to=origin/master ghostkellz
# Remove only known downloaded remote patches if their checksums are stale.
rm -f linux-cachyos/dkms-clang.patch linux-cachyos/0001-bore-cachy.patch
cd linux-cachyos
updpkgsums
makepkg --printsrcinfo > .SRCINFO
makepkg --printsrcinfo | grep -cE 'source =|b2sums ='   # counts must match
makepkg -si
```

Things that reliably need attention on a rebase:

- `ghostzen5.patch` fuzz/offsets against the new tree;
- the `MZEN*` arms in the CPU-optimization `case`, if upstream adds a µarch;
- stale downloaded `*.patch` files in the build dir — makepkg reuses an
  existing file rather than refetching, so a stale one fails checksum
  validation (or, worse, gets applied under `--skipchecksums`).

Keep the packaged `linux-zen` kernel, matching headers, boot entry, and its DKMS
modules working as the rollback before installing a new custom kernel.

## Post-install verification

Do not reboot on package-install success alone. Verify the installed config,
boot files, and separate DKMS modules first:

```sh
pacman -Q linux-cachyos-lto linux-cachyos-lto-headers linux-zen linux-zen-headers
ls -lh /boot/vmlinuz-linux-cachyos-lto /boot/initramfs-linux-cachyos-lto.img
dkms status
kernel_release=$(basename "$(dirname "$(readlink -f /usr/src/linux-cachyos-lto)")")
grep -E '^(CONFIG_(MZEN5|SCHED_BORE|CC_OPTIMIZE_FOR_PERFORMANCE_O3|HZ_1000|LTO_CLANG_FULL|TCP_CONG_BBR3))=' \
  "/usr/lib/modules/$kernel_release/build/.config"
modinfo -k "$kernel_release" nvidia | grep -E '^(filename|version|vermagic):'
bootctl list
```

After reboot, `uname -r` must match the installed CachyOS-LTO release and
`zgrep CONFIG_MZEN5 /proc/config.gz` must report `CONFIG_MZEN5=y`.

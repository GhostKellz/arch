# linux-cachyos-lto — local customizations

The kernel is built from a clone of upstream `CachyOS/linux-cachyos` at
`/data/repo/linux-cachyos` (this package is the `linux-cachyos/` subdir).
`origin` is upstream itself, **not a fork**, so nothing local is ever pushed.

The local delta lives on branch **`ghostkellz`**, rebased onto each upstream
release. This directory is documentation plus the one file upstream does not
carry (`ghostzen5.patch`); it is not a second copy of the PKGBUILD, which
would rot.

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

### znver5 support — `ghostzen5.patch`

Upstream's patchset stops at `CONFIG_MZEN4`. `ghostzen5.patch` adds
`CONFIG_MZEN5` to `arch/x86/Kconfig.cpu` and the matching `-march=znver5`
to `arch/x86/Makefile`.

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

## Rebase onto a new release

```sh
cd /data/repo/linux-cachyos
git fetch origin
git rebase origin/master ghostkellz      # or origin/<ver> before it merges
rm -f linux-cachyos/*.patch              # keep ghostzen5.patch (tracked)
cd linux-cachyos
updpkgsums
makepkg --printsrcinfo | grep -cE 'source =|b2sums ='   # counts must match
makepkg -s
```

Things that reliably need attention on a rebase:

- `ghostzen5.patch` fuzz/offsets against the new tree;
- the `MZEN*` arms in the CPU-optimization `case`, if upstream adds a µarch;
- stale downloaded `*.patch` files in the build dir — makepkg reuses an
  existing file rather than refetching, so a stale one fails checksum
  validation (or, worse, gets applied under `--skipchecksums`).

Do not build against an unmerged upstream release branch without a working
rollback: the running kernel's modules under `/usr/lib/modules/` plus a
bootloader entry are not a package, and cannot be reinstalled.

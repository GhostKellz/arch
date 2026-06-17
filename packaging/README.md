# Packaging

Per-language `PKGBUILD` templates for shipping our projects on Arch Linux.

Each subdirectory holds a complete, engineered `-git` PKGBUILD modelled on the
official pacman prototypes
([`PKGBUILD-vcs.proto`](https://gitlab.archlinux.org/pacman/pacman/-/blob/master/proto/PKGBUILD-vcs.proto))
and the Arch package guidelines. They are not skeletons to rewrite — copy the
one for your language, fill the placeholders, and build.

| Folder            | Toolchain | Output                                   |
|-------------------|-----------|------------------------------------------|
| [`rust/`](rust/PKGBUILD) | `cargo`   | release binary from `target/release/`    |
| [`go/`](go/PKGBUILD)     | `go`      | hardened PIE binary                       |
| [`zig/`](zig/PKGBUILD)   | `zig`     | `ReleaseSafe`, baseline-CPU binary        |
| [`node/`](node/PKGBUILD) | `npm`     | global install under `/usr/lib/node_modules` |
| [`bun/`](bun/PKGBUILD)   | `bun`     | single compiled self-contained binary     |

## Guides

| Doc | Covers |
|-----|--------|
| [AUDITING.md](AUDITING.md)     | Pre-build review checklist for any PKGBUILD (ours or AUR) — `namcap`, `--verifysource`, clean-chroot builds, red flags. |
| [REVIEWING.md](REVIEWING.md)   | Reviewing build files and diffs with `paru`/`yay` before they build — review prompts, diff/edit menus, manual `git diff` workflow. |
| [MAINTAINING.md](MAINTAINING.md) | Upkeep of our packages — version/`pkgrel` rules, refreshing checksums, regenerating `.SRCINFO`, verifying changes, AUR publishing. |

## Quick start

```sh
cp packaging/rust/PKGBUILD ~/build/myproj/PKGBUILD   # pick your language
cd ~/build/myproj
$EDITOR PKGBUILD                                      # fill placeholders
makepkg --printsrcinfo > .SRCINFO                     # sanity check metadata
makepkg -si                                           # build + install
```

## Placeholders to fill

Every template ships with the same three placeholders plus the dependency
arrays:

| Placeholder | Replace with                                                    |
|-------------|-----------------------------------------------------------------|
| `NAME`      | binary / package name. `pkgname` stays `NAME-git`; the build derives the real name via `${pkgname%-git}`. |
| `REPO`      | GitHub repo path under `github.com/ghostkellz` (used in both `url` and `source`). |
| `pkgdesc`   | one-line description.                                           |
| `depends`   | real runtime libraries.                                         |
| `makedepends` | build-only tools (the toolchain + `git` are pre-filled).      |

Do **not** invent a `_pkgname` variable — these follow the upstream idiom of
deriving the source-tree name from `${pkgname%-git}`, so there is a single
source of truth for the name.

## Why `-git`

These are VCS (`-git`) PKGBUILDs: `source` clones the repo and `pkgver()`
derives the version from the git history, so a package builds **without a
release tag**.

- With tags: `git describe` yields `1.2.3.r4.gabcdef`.
- Before any tag: it falls back to `r<commit-count>.<short-sha>`.

Both forms increase monotonically under `vercmp`, so upgrades resolve correctly.

### Switching to a tagged-release tarball

When a project starts cutting releases and you want reproducible source
checksums instead of a moving `HEAD`:

1. Drop the `-git` suffix from `pkgname` and delete `pkgver()`.
2. Set `pkgver` to the release version.
3. Swap `source` to the archive:
   `source=("$pkgname-$pkgver.tar.gz::$url/archive/v$pkgver.tar.gz")`
4. Replace `sha256sums=('SKIP')` with real sums (`makepkg -g` or `updpkgsums`).

## Language notes

### Rust (`rust/PKGBUILD`)
- `makedepends=('git' 'cargo')`; depends on `gcc-libs glibc`.
- `prepare()` runs `cargo fetch --locked`, so `build()`/`check()` are offline
  and reproducible — this requires a committed `Cargo.lock` (commit it for any
  binary/app). `--frozen` enforces that.
- Toolchain config (global `~/.cargo/config.toml`, `git-fetch-with-cli`,
  edition/MSRV) lives in `~/arch/rust/` — see that README, don't duplicate here.
- Drop `--all-features` if the crate's default feature set is what you ship.

### Go (`go/PKGBUILD`)
- Follows the Arch Go packaging guidelines: distro `CGO_*`/`GOFLAGS` are
  exported so the binary is a hardened, trimmed PIE.
- `options=('!lto')` because the Go toolchain manages its own linking.
- `-ldflags "-X main.version=$pkgver"` stamps the version; rename the symbol to
  match your project (e.g. `main.Version`, `internal/build.Version`).

### Zig (`zig/PKGBUILD`)
- `-Doptimize=ReleaseSafe` keeps runtime safety checks; use `ReleaseFast` only
  when a project explicitly needs it.
- `-Dcpu=baseline` keeps the binary portable across the x86_64 machines we
  distribute to instead of pinning to the build host's microarchitecture.
- `options=('!buildflags' '!lto')` — Zig owns its own flags and linking.
- `build()` installs into `$srcdir/install` via `--prefix`; adjust the binary
  path in `package()` if `build.zig` installs elsewhere.

### Node (`node/PKGBUILD`)
- `arch=('any')` — pure JS packages are architecture-independent.
- `build()` uses `npm ci` against the committed lockfile, then `npm run build`.
- `package()` does `npm pack` + `npm install -g --prefix "$pkgdir/usr"` so the
  bin shims and `node_modules` layout match a real global install, then strips
  the leaked build path and normalises permissions.

### Bun (`bun/PKGBUILD`)
- `bun build --compile` produces a single self-contained executable, so the
  installed package has no runtime dependency on bun or nodejs.
- `options=('!strip')` — stripping the embedded Bun runtime breaks the binary.
- `bun install --frozen-lockfile` requires a committed `bun.lockb`.
- Point `bun build` at the real entrypoint (`src/index.ts` is a placeholder).

## Where this folder lives in a project

Keep distro packaging in a subfolder so `makepkg` artifacts (`src/`, `pkg/`,
tarballs) never pollute the repo root:

| Location     | Use when                                                          |
|--------------|-------------------------------------------------------------------|
| `packaging/` | Default for code projects — packaging files only.                 |
| `release/`   | Packaging is one part of a broader release workflow (changelog tooling, multi-distro specs, release scripts). |
| repo root    | Trivial / AUR-only projects with a single PKGBUILD and nothing else. |

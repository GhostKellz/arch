# Auditing a PKGBUILD

A pre-build checklist for reviewing any PKGBUILD — ours or a third-party/AUR
package — before it runs on your machine. A PKGBUILD is arbitrary shell that
executes as your user (and `package()`-installed hooks can run as root), so
treat every one as untrusted code until reviewed.

## Tools

| Tool         | Package         | Use                                             |
|--------------|-----------------|-------------------------------------------------|
| `namcap`     | `namcap`        | Lint the PKGBUILD and the built package.        |
| `makepkg`    | `pacman`        | `--printsrcinfo`, `--verifysource`.             |
| `updpkgsums` | `pacman-contrib`| Regenerate `sha256sums`.                        |
| `parse-submodules` / `git` | `git` | Inspect `source` repos before cloning fully. |

```sh
sudo pacman -S --needed namcap pacman-contrib
```

## Static review (read before you run)

1. **Maintainer & source provenance** — does `url`/`source` point at the real
   upstream? Watch for typo-squatted hosts or a `source` that differs from `url`.
2. **`source` array** — every entry is a URL, a `vcs+url#fragment`, or a local
   file. Reject anything that pipes to a shell (`curl ... | sh`), fetches from
   shorteners, or hardcodes a random IP.
3. **Checksums** — non-VCS sources must have real `sha*sums`, not `SKIP`. `SKIP`
   is only legitimate for VCS sources (the commit hash is the integrity anchor)
   and signed sources verified via `validpgpkeys`.
4. **Functions** — read `prepare/build/check/package` line by line:
   - No network access outside `prepare()` (build/check should be offline).
   - No writes outside `$srcdir`/`$pkgdir`; nothing touching `$HOME`, `/etc`,
     `/usr` directly.
   - No `sudo`/privilege escalation inside any function.
   - `install`/`*.install` hook scripts: read them — they run as root.
5. **Dependencies** — `depends`/`makedepends` are real package names, no
   unexpected toolchains or networking utilities pulled in to exfiltrate.
6. **`options`** — flags like `!strip`, `!lto`, `!buildflags` should have a
   reason (see each language template). Be suspicious of disabled hardening
   without justification.

## Mechanical checks

```sh
# Metadata parses and matches expectations
makepkg --printsrcinfo

# Download sources and verify checksums WITHOUT building
makepkg --verifysource -f

# Lint the recipe
namcap PKGBUILD
```

`namcap PKGBUILD` flags missing/`unused` deps, wrong field types, and common
mistakes. After a build, lint the artifact too:

```sh
makepkg -f                       # build
namcap ./*.pkg.tar.zst           # lint the package: missing deps, soname issues, perms
```

## Build in isolation

For anything you don't fully trust — or to catch missing `depends` — build in a
clean chroot instead of your live system (`devtools`):

```sh
sudo pacman -S --needed devtools
extra-x86_64-build               # builds in a throwaway clean chroot
```

A clean-chroot build fails if a dependency isn't declared, which is the single
most reliable correctness check for a PKGBUILD.

## Red flags — stop and investigate

- `sha256sums=('SKIP')` on a plain tarball/HTTP source.
- Base64/hex blobs decoded and executed in any function.
- `source` host ≠ `url` host with no explanation.
- Build steps that `chmod`/`chown` or write outside `$srcdir`/`$pkgdir`.
- An `.install` hook that downloads or executes anything.
- Disabled hardening (`!buildflags`) on a C/C++ network-facing program.

## Auditing our own templates

Our per-language templates (`rust/`, `go/`, `zig/`, `node/`, `bun/`) already
satisfy this checklist by design. When you copy one into a project, re-run:

```sh
makepkg --printsrcinfo && namcap PKGBUILD
```

after filling placeholders, so a typo in `depends` or a wrong binary path is
caught before the first build.

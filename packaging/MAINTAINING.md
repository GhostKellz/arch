# Maintaining our packages

Day-to-day upkeep of the PKGBUILDs we ship: bumping versions, refreshing
checksums, regenerating `.SRCINFO`, and verifying a change before it goes out.

## Version & release fields

- **`-git` packages** (our templates) derive the version from `pkgver()`, so you
  never hand-edit `pkgver`. Bump **`pkgrel`** only when the *packaging* changes
  (deps, build flags, install paths) without the upstream commit changing.
- **Tagged-release packages** set `pkgver` to the release and reset `pkgrel=1`
  on each new `pkgver`. Use `epoch` only when upstream versioning goes backwards
  (e.g. a `2024.x` scheme replaced by `1.0`).

## Reviewing upstream changes before a bump

Diff the source between what you currently ship and the new commit/tag so you
know what you're packaging:

```sh
cd ~/.cache/<src-checkout>/<pkg>     # or the cloned source tree
git fetch --tags
git log --oneline OLD..NEW           # commits since last packaged version
git diff OLD..NEW                    # full source diff
git diff OLD..NEW -- build.zig Cargo.toml go.mod package.json   # build inputs
```

Pay attention to changed build inputs (lockfiles, manifests, new system deps) —
those are what require `depends`/`makedepends` updates in the PKGBUILD.

## Refresh checksums (tagged-release variant only)

`-git` sources use `SKIP`; tarball sources need real sums:

```sh
updpkgsums          # rewrites sha*sums in place (pacman-contrib)
# or:
makepkg -g >> PKGBUILD   # then move the generated line into the array
```

## Regenerate metadata

`.SRCINFO` must be regenerated after *any* edit to the PKGBUILD (the AUR uses it
as the canonical metadata):

```sh
makepkg --printsrcinfo > .SRCINFO
```

## Verify before shipping

```sh
makepkg --verifysource -f          # sources download + checksums pass
namcap PKGBUILD                    # recipe lint
extra-x86_64-build                 # clean-chroot build (devtools) — catches missing deps
namcap ./*.pkg.tar.zst             # built-package lint: sonames, deps, perms
namcap -i ./*.pkg.tar.zst          # show what files land where
```

A clean-chroot build is the gate: if it builds there, the declared `depends`/
`makedepends` are complete. See [AUDITING.md](AUDITING.md) for the full review
checklist.

## Updating to a tagged release

When a project starts cutting releases, convert the `-git` template:

1. Drop the `-git` suffix from `pkgname`; delete `pkgver()`.
2. Set `pkgver` to the release; `pkgrel=1`.
3. `source=("$pkgname-$pkgver.tar.gz::$url/archive/v$pkgver.tar.gz")`.
4. `updpkgsums` to replace `SKIP` with real checksums.
5. Regenerate `.SRCINFO` and run the verification steps above.

## Publishing to the AUR

```sh
git clone ssh://aur@aur.archlinux.org/<pkgname>.git aur-<pkgname>
cp PKGBUILD .SRCINFO aur-<pkgname>/
cd aur-<pkgname>
git add PKGBUILD .SRCINFO
git commit -m "upgpkg: <pkgname> <version>"
git push
```

`.SRCINFO` must be committed alongside the PKGBUILD and must match it, or the
AUR rejects the push.

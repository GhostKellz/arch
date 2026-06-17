# Reviewing builds with paru / yay

How to read the PKGBUILD and the **diff of what changed** before an AUR helper
builds anything. The golden rule: never let a helper build a package you
haven't reviewed the diff for. Both `paru` and `yay` are wrappers around
`makepkg` and keep a git clone of each package's build files, so "review" means
reading those files and `git diff`-ing them against the last version you built.

## Fetch build files without building

Both helpers expose `-G` (get) so you can inspect first:

```sh
paru -G  pkgname     # clone build files into ./pkgname
paru -Gp pkgname     # print the PKGBUILD to stdout

yay  -G  pkgname     # same with yay
yay  -Gp pkgname     # print the PKGBUILD to stdout
```

## paru review workflow

paru reviews build files before installing. On `paru -Sua` (upgrade) or
`paru -S pkg` it fetches the new build files, then prompts you to review; it
shows the PKGBUILD and a `git diff` against the version you last built in your
pager.

```sh
paru                         # full upgrade, with review step
paru -S pkgname              # install one package, with review step
paru --review                # review pending AUR build files on demand
```

Useful flags / config (`~/.config/paru/paru.conf`):

- `--skipreview` / `--review` — skip or force the review step for this run.
- `[options] NewsOnUpgrade` — print Arch news before upgrading.
- `[options] UpgradeMenu` — interactive menu to pick what to upgrade.
- `[options] CleanAfter` — drop `$srcdir`/`$pkgdir` once built.

Cloned build files live under `~/.cache/paru/clone/<pkg>`; you can `cd` there
and run `git log -p` / `git diff` manually for a deeper look.

## yay review workflow

yay drives review through three menus. They are off by default — enable and
persist them once:

```sh
yay --save --diffmenu --editmenu --cleanmenu
```

- **diffmenu** — shows a `git diff` of the build files vs. the last build.
- **editmenu** — opens the PKGBUILD/`.install` in `$EDITOR` before building.
- **cleanmenu** — choose whether to wipe the existing build dir first.

Then a normal run prompts you per package:

```sh
yay              # full upgrade, prompts: diffs to show? edit? proceed?
yay -S pkgname   # single package with the same prompts
```

yay caches clones in `~/.cache/yay/<pkg>`; `--answerdiff`, `--answeredit`,
`--answerclean` pre-answer the menus for scripted runs (e.g. `--answerdiff All`).

## Reading the diff that matters

When upgrading an already-installed AUR package, the only thing that changed is
the diff between the old and new build files. Focus there:

- New or changed `source` URLs / hosts.
- `sha*sums` going to `SKIP`, or checksums changing without a `pkgver` bump.
- New `prepare/build/package` steps, especially anything fetching from the
  network or writing outside `$srcdir`/`$pkgdir`.
- A newly added `.install` hook (runs as root).

Anything flagged here should be cross-checked against [AUDITING.md](AUDITING.md)
before you approve the build.

## Reviewing by hand (no helper)

The same review without paru/yay, useful in scripts or CI:

```sh
git clone https://aur.archlinux.org/pkgname.git
cd pkgname
git fetch && git log --oneline            # see what changed upstream
git diff HEAD@{1} HEAD -- PKGBUILD *.install   # diff the recipe across updates
makepkg --printsrcinfo                    # confirm metadata
namcap PKGBUILD                           # lint
makepkg -si                               # build + install once satisfied
```

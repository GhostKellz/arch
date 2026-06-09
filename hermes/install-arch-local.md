# Local Install — Arch Workstation (our actual setup)

How Hermes is installed on the primary Arch box (9950X3D / 64GB / RTX 5090).
This documents what we *actually did*, including the one real gotcha.

## The gotcha: system Python is too new

Hermes requires **Python `>=3.11,<3.14`**. Arch ships bleeding-edge:

```
$ python --version
Python 3.14.5
```

So the system interpreter **cannot** be used directly. The fix is not to
downgrade system Python — it's to let `uv` provision an isolated 3.11. The
`setup-hermes.sh` dev installer does this automatically.

## What we used: `setup-hermes.sh` (native dev install)

Chosen over Docker/Nix because this box is for hacking on the agent. Steps run:

```bash
cd /data/repo/hermes-agent
./setup-hermes.sh        # non-interactive runs: ./setup-hermes.sh < /dev/null
```

The script:

1. Finds existing `uv` (we had `uv 0.7.9`) or installs it.
2. `uv python install 3.11` → provisioned **Python 3.11.12** (system 3.14.5 untouched).
3. `uv venv venv --python 3.11` → venv at `/data/repo/hermes-agent/venv`.
4. `uv sync --extra all --locked` → **hash-verified** install of all extras against
   `uv.lock` (transitive supply-chain protection; falls back to PyPI resolve only
   if the lockfile is stale).
5. Created `.env` from `.env.example` (chmod 600).
6. Symlinked `hermes` → `~/.local/bin/hermes` (→ `venv/bin/hermes`).
7. Synced **74 bundled skills** into `~/.hermes/skills/`.

> `--extra all` is deliberate (not `--all-extras`) — it installs the curated `[all]`
> set and avoids backends like `[matrix]`/`[rl]` that need extra build tooling.

## PATH (zsh)

`~/.local/bin` is already on PATH in `~/.zshrc` (line ~210:
`export PATH="$HOME/.local/bin:$PATH"`), so `hermes` resolves in any new shell.
If it ever doesn't:

```bash
source ~/.zshrc
which hermes        # /home/chris/.local/bin/hermes
```

## Prereqs already present on this box

| Tool | Version | Needed for |
|------|---------|-----------|
| uv | 0.7.9 | Python provisioning + install |
| ripgrep | 15.1.0 | fast file search |
| ffmpeg | n8.1.1 | audio/video |
| git | 2.54.0 | required |
| docker | 29.5.2 + compose 5.1.4 | optional Docker backend / Compose deploy |
| node | 24.10.0 | dashboard/TUI builds (core ships prebuilt) |

## The `direnv` / `.envrc` blocked warning

`cd`-ing into the repo prints:

```
direnv: error /data/repo/hermes-agent/.envrc is blocked. Run `direnv allow` ...
```

The `.envrc` is **only** the Nix flake dev environment:

```bash
watch_file pyproject.toml uv.lock ...
use flake
```

We **don't** have Nix installed, so `direnv allow` would just fail on `use flake`.
**Leave it blocked.** It has nothing to do with our native install. Options:

- Ignore the warning (harmless), or
- `rm /data/repo/hermes-agent/.envrc` to silence it, or
- Only `direnv allow` *after* installing Nix if you ever want the flake workflow
  (see [resources.md](resources.md)).

## Verify

```bash
hermes doctor
```

Expected healthy state on this box:

- ✓ Python 3.11.12, venv active, version files consistent
- ✓ core packages (OpenAI SDK, Rich, dotenv, PyYAML, HTTPX, croniter)
- ✓ `~/.hermes/` dirs, skills, SOUL.md seeded
- ✓ external tools: git, ripgrep, docker, node
- ⚠ messaging libs (telegram/discord) not installed — lazy-installed on first use
- ⚠ no provider logged in yet — see [getting-started.md](getting-started.md)
- ⚠ `agent-browser not installed` — optional, `npm install` in repo if wanted

## Updating

Native dev install tracks the git checkout:

```bash
cd /data/repo/hermes-agent
git pull
./setup-hermes.sh < /dev/null     # re-syncs deps + skills against the new lockfile
```

`hermes update` is the path for installer-based installs; for this repo clone,
prefer `git pull` + re-running the setup script so the venv matches `uv.lock`.

## Reinstall / reset

```bash
# rebuild the venv from scratch (keeps ~/.hermes data)
rm -rf /data/repo/hermes-agent/venv
./setup-hermes.sh < /dev/null

# nuke ALL runtime data (memory, skills, config) — destructive
rm -rf ~/.hermes/
```

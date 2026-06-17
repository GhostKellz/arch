# Rust

Rust / Cargo toolchain configuration and reference for this Arch system.

> Living knowledge base — reflects a point in time (Rust 1.96, edition 2024,
> 2026) and may drift as the toolchain evolves.

## Contents

| File | Description |
|------|-------------|
| [config.toml](config.toml) | Canonical global Cargo config (deploy to `~/.cargo/config.toml`) |
| [rust_guide.md](rust_guide.md) | In-depth Rust guide |
| [rust-cheatsheet.md](rust-cheatsheet.md) | Quick reference |

## Global Cargo config

`config.toml` here is the single source of truth for `~/.cargo/config.toml`.

### Deploy

```bash
install -Dm644 ~/arch/rust/config.toml ~/.cargo/config.toml
```

`~/.cargo/config.toml` should be owned by your user, not root. If it ever ends
up root-owned (e.g. created via sudo), fix it:

```bash
sudo chown "$USER:$USER" ~/.cargo/config.toml
```

### Settings and justification

#### `[net] git-fetch-with-cli = true`

Tells Cargo to shell out to the system `git` binary for fetching the registry
index and git dependencies, instead of its bundled libgit2.

This is **required** on this system because `~/.gitconfig` contains:

```ini
[url "git@github.com:"]
    insteadOf = https://github.com/
```

That rule rewrites every `https://github.com/...` URL to SSH so all GitHub
access uses your key. libgit2 cannot authenticate through `ssh-agent` the way
the `git` CLI can, so without this setting any crate with a git dependency
(e.g. `nih-plug` in ghostwave) fails:

```
failed to authenticate when downloading repository: git@github.com:...
  * attempted ssh-agent authentication, but no usernames succeeded: `git`
  if the git CLI succeeds then `net.git-fetch-with-cli` may help here
```

`git-fetch-with-cli` is the cargo-team-recommended fix for this class of
authentication problem and is the standard setup when an `insteadOf` SSH
rewrite is in use. It also benefits `cargo install`, which only reads the
global config.

#### `[net] retry = 3`

Retries transient network failures (registry/git fetches) instead of aborting
the whole build on a single spurious error.

### What this file intentionally does NOT set

A previous version set a global default build target:

```toml
[build]
target = "x86_64-unknown-linux-gnu"   # removed
```

Forcing a default target globally is an anti-pattern: the host triple is
already the default, and pinning it makes every project build into
`target/x86_64-unknown-linux-gnu/` (redundant with `target/debug`), which
wastes space and confuses rust-analyzer and cross-compilation. Leave the
target unset and let Cargo use the host default.

## References

- [The Cargo Book — Configuration](https://doc.rust-lang.org/cargo/reference/config.html)
- [`net.git-fetch-with-cli`](https://doc.rust-lang.org/cargo/reference/config.html#netgit-fetch-with-cli)

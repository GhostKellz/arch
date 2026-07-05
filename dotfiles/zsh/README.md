# 👻 GhostKellz Zsh Setup

[![Zsh](https://img.shields.io/badge/Zsh-Shell-689E6E?logo=gnu-bash&logoColor=white)](https://www.zsh.org/)
[![Oh My Zsh](https://img.shields.io/badge/Oh_My_Zsh-Framework-3C3C3C?logo=ohmyzsh&logoColor=white)](https://ohmyz.sh/)
[![Powerlevel10k](https://img.shields.io/badge/Powerlevel10k-Prompt-1D99F3)](https://github.com/romkatv/powerlevel10k)

A modular Zsh configuration built on Oh My Zsh with a Powerlevel10k prompt, Wayland/NVIDIA-aware
environment variables, and per-domain alias files loaded from `~/.zshrc.d/`.

---

## 📷 Preview

![Powerlevel10k Prompt](https://raw.githubusercontent.com/GhostKellz/arch/main/assets/powerlevel10k.png)

---

## 📂 Layout

```bash
dotfiles/zsh/
├── .zshrc            # Main shell config (sourced as ~/.zshrc)
├── .p10k.zsh         # Powerlevel10k prompt configuration
├── .zshrc.d/         # Modular, per-domain alias files (auto-loaded)
│   ├── docker.zsh    # Docker / Compose helpers
│   ├── git-aliases.zsh
│   ├── repo-scripts.zsh # New-repo bootstrappers: ghostkellz / cktech / gitlab
│   ├── restic.zsh    # Restic backup helpers
│   ├── snapper.zsh   # Btrfs/Snapper snapshot helpers
│   ├── system.zsh    # systemd, systemd-boot, journal
│   └── wezterm.zsh   # WezTerm config + hot reload
├── starship.toml     # Starship prompt theme (alternative prompt)
├── bootstrap.sh      # Baseline provisioning (packages, OMZ, plugins, fonts)
└── oh-my-zsh/        # Custom plugins/themes (not a full OMZ install)
```

---

## 🚀 Prompt

The active prompt is **Powerlevel10k**, set as the Oh My Zsh theme and configured via `~/.p10k.zsh`.
The P10k *instant prompt* block sits at the top of `.zshrc` so the shell is interactive immediately
while the rest of the config loads.

> A Starship config (`starship.toml`) is kept for reference, but its init line in `.zshrc` is
> commented out — two prompt engines can't run at once, so only Powerlevel10k drives the prompt.

---

## 🧩 Framework & Plugins

Built on **Oh My Zsh** with the following plugins:

| Plugin | Purpose |
|--------|---------|
| `git` | Git aliases and prompt info |
| `sudo` | Press `Esc` twice to prefix the last command with `sudo` |
| `zsh-autosuggestions` | Fish-style history suggestions |
| `zsh-syntax-highlighting` | Inline command syntax highlighting |
| `zsh-completions` | Extra completion definitions |
| `zsh-history-substring-search` | Substring history search with arrow keys |
| `colored-man-pages` | Colorized man pages |

---

## 🔧 Tool Integrations

Initialized in `.zshrc`:

- **zoxide** – smarter `cd` with frecency-based jumping
- **fzf** – fuzzy finder (`~/.fzf.zsh`)
- **direnv** – per-directory environment loading
- **nvm** / **pyenv** – Node and Python version management
- **vivid** – `LS_COLORS` generation using the `ghost-hacker-blue` theme

Custom `zsh-syntax-highlighting` styles tint commands, builtins, aliases, and functions in
aquamarine/mint accents.

---

## 🗂️ Modular Aliases (`~/.zshrc.d/`)

Every `*.zsh` file in `~/.zshrc.d/` is auto-sourced, keeping concerns separated:

| File | Covers |
|------|--------|
| `docker.zsh` | `d`, `dc`, `dps`, `dlogs`, `dclean`, container exec helpers |
| `git-aliases.zsh` | `gaa`, `gc`, `gp`, `gl`, plus `gcp`/`gpush` add-commit-push one-liners |
| `repo-scripts.zsh` | `ghostkellz`, `cktech`, `gitlab` — new-repo bootstrappers (GitHub + self-hosted GitLab) |
| `restic.zsh` | `restic-backup`, `restic-snapshots`, `restic-prune`, `restic-check` |
| `snapper.zsh` | `snapls`, `snap`, `snaprm`, `snapdiff`, `snapmount` |
| `system.zsh` | systemd power/service/journal + systemd-boot entry helpers |
| `wezterm.zsh` | `wezconfig`, `wezreload` (hot reload) |

The main `.zshrc` adds further aliases for `exa`-based `ls`, pacman/yay updates, reflector mirror
refresh, DKMS/initramfs rebuilds, KWin restart, DNS/network tooling, and dev-toolchain shortcuts.

> **Repo bootstrappers:** `repo-scripts.zsh` wires up `ghostkellz` (personal GitHub / GhostKellz),
> `cktech` (CK-Technology org), and `gitlab` (self-hosted GitLab). All three scaffold a new project
> — license, badge'd README with a one-line description, `docs/` + advisories tree — and set the
> matching remote repo description. Full per-script docs live alongside the scripts in
> `~/arch/scripts/` (`build-repo.md`, `cktechrepit.md`, `gitlab.md`).

---

## 🖥️ Environment

`.zshrc` exports a tuned environment for this Wayland + NVIDIA workstation:

- **NVIDIA/Wayland**: GBM backend, GLX vendor, VDPAU/VA-API, render-offload, vibrance toggles
- **Vulkan**: ICD + layer paths
- **Gaming**: DXVK async, FSR, G-Sync/VRR, shader cache, MangoHud
- **Dev toolchains**: Go, Rust (`target-cpu=native`), Zig, Python (pyenv), CUDA (`/opt/cuda`)
- **GPG/SSH**: `GPG_TTY` and gpg-agent as the SSH auth socket

---

## 📦 Bootstrap

`bootstrap.sh` provisions a baseline from scratch: installs core packages (zsh, starship, zoxide,
fzf, ripgrep, fd, bat, exa, neovim, etc.), Nerd Fonts, Oh My Zsh, and the plugins above, then sets
Zsh as the default shell.

> Note: `bootstrap.sh` writes a minimal starter `.zshrc` (robbyrussell theme) for a clean baseline.
> The full Powerlevel10k-based config in this directory is the maintained daily-driver version —
> symlink or copy `.zshrc`, `.p10k.zsh`, and `.zshrc.d/` into `$HOME` after bootstrapping.

---

🌟 Maintained by [GhostKellz](https://github.com/GhostKellz)

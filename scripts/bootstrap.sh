#!/usr/bin/env bash
# Experimental fresh-workstation bootstrap for GhostKellz/arch.
# Dry-run is the default. Nothing changes unless --apply is supplied.

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly SCRIPT_DIR
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"
readonly REPO_ROOT
readonly REPO_URL="https://github.com/GhostKellz/arch.git"
TARGET_USER="$(id -un)"
readonly TARGET_USER

APPLY=false
WITH_AGENT_CLIS=false
WITH_SNAPPER=false
WITH_MAINTENANCE=false
WITH_OBS_VIRTUAL_CAMERA=false
REBUILD_INITRAMFS=false
BRIDGE_PARENT=""
BRIDGE_NAME="br0"
SCRATCH_DIR=""
BACKUP_ROOT="${HOME}/.local/state/ghostkellz-bootstrap/backups/$(date +%Y%m%d-%H%M%S)"
SYSTEM_BACKUP_ROOT="/var/lib/ghostkellz-bootstrap/backups/$(date +%Y%m%d-%H%M%S)"

usage() {
  cat <<'EOF'
Usage: bootstrap.sh [options]

Experimental GhostKellz Arch workstation bootstrap. The default is a dry run.

  --apply                    Perform the displayed changes
  --with-agent-clis          Install Codex, Claude Code, and Gemini CLI for the user
  --with-snapper             Configure Snapper after validating the Btrfs layout
  --with-maintenance         Install bounded weekly and monthly maintenance timers
  --with-obs-virtual-camera  Install v4l2loopback DKMS support for OBS
  --rebuild-initramfs        Run mkinitcpio -P after installing NVIDIA policy
  --bridge-parent INTERFACE  Create disabled NetworkManager bridge profiles
  --bridge-name NAME         Bridge name (default: br0)
  --dry-run                  Explicitly select the default no-change mode
  -h, --help                 Show this help

The bridge profiles have autoconnect disabled and are never activated here.
Agent CLIs are installed under ~/.local and are not authenticated here.
EOF
}

log() {
  printf '[bootstrap] %s\n' "$*"
}

die() {
  printf '[bootstrap] ERROR: %s\n' "$*" >&2
  exit 1
}

print_command() {
  printf '  +'
  printf ' %q' "$@"
  printf '\n'
}

run() {
  print_command "$@"
  if [[ "${APPLY}" == true ]]; then
    "$@"
  fi
}

cleanup() {
  if [[ -n "${SCRATCH_DIR}" && -d "${SCRATCH_DIR}" ]]; then
    rm -rf -- "${SCRATCH_DIR}"
  fi
}

ensure_scratch() {
  if [[ -z "${SCRATCH_DIR}" ]]; then
    mkdir -p -- "${REPO_ROOT}/.scratch"
    SCRATCH_DIR="$(mktemp -d -p "${REPO_ROOT}/.scratch" bootstrap.XXXXXXXX)"
  fi
}

backup_path() {
  local target="$1"
  local relative

  [[ -e "${target}" || -L "${target}" ]] || return 0
  relative="${target#"${HOME}"/}"
  if [[ "${relative}" == "${target}" ]]; then
    die "refusing to back up a path outside HOME: ${target}"
  fi

  log "back up ${target} -> ${BACKUP_ROOT}/${relative}"
  if [[ "${APPLY}" == true ]]; then
    mkdir -p -- "${BACKUP_ROOT}/$(dirname -- "${relative}")"
    cp -a -- "${target}" "${BACKUP_ROOT}/${relative}"
  fi
}

install_user_file() {
  local mode="$1"
  local source="$2"
  local target="$3"

  backup_path "${target}"
  run install -Dm"${mode}" -- "${source}" "${target}"
}

install_user_tree() {
  local source="$1"
  local target="$2"

  backup_path "${target}"
  run mkdir -p -- "${target}"
  run rsync -a -- "${source}/" "${target}/"
}

install_system_file() {
  local mode="$1"
  local source="$2"
  local target="$3"

  if [[ -e "${target}" || -L "${target}" ]]; then
    log "back up ${target} -> ${SYSTEM_BACKUP_ROOT}${target}"
    run sudo mkdir -p -- "${SYSTEM_BACKUP_ROOT}$(dirname -- "${target}")"
    run sudo cp -a -- "${target}" "${SYSTEM_BACKUP_ROOT}${target}"
  fi
  run sudo install -Dm"${mode}" -- "${source}" "${target}"
}

parse_args() {
  while (($#)); do
    case "$1" in
      --apply) APPLY=true ;;
      --dry-run) APPLY=false ;;
      --with-agent-clis) WITH_AGENT_CLIS=true ;;
      --with-snapper) WITH_SNAPPER=true ;;
      --with-maintenance) WITH_MAINTENANCE=true ;;
      --with-obs-virtual-camera) WITH_OBS_VIRTUAL_CAMERA=true ;;
      --rebuild-initramfs) REBUILD_INITRAMFS=true ;;
      --bridge-parent)
        (($# >= 2)) || die "--bridge-parent requires an interface"
        BRIDGE_PARENT="$2"
        shift
        ;;
      --bridge-name)
        (($# >= 2)) || die "--bridge-name requires a name"
        BRIDGE_NAME="$2"
        shift
        ;;
      -h | --help)
        usage
        exit 0
        ;;
      *) die "unknown option: $1" ;;
    esac
    shift
  done
}

preflight() {
  [[ ${EUID} -ne 0 ]] || die "run as the target user, not root"
  [[ -f /etc/arch-release ]] || die "this prototype supports Arch Linux only"
  [[ -d "${REPO_ROOT}/.git" ]] || die "run from a cloned ${REPO_URL} checkout"
  [[ -f "${REPO_ROOT}/dotfiles/zsh/.zshrc" ]] || die "checkout is missing tracked dotfiles"
  [[ "${HOME}" == /* && "${HOME}" != "/" ]] || die "HOME is not a safe absolute path"
  [[ "${BRIDGE_NAME}" =~ ^[a-zA-Z0-9_.:-]+$ ]] || die "invalid bridge name"
  if [[ -n "${BRIDGE_PARENT}" ]]; then
    [[ "${BRIDGE_PARENT}" =~ ^[a-zA-Z0-9_.:-]+$ ]] || die "invalid bridge parent"
    if [[ "${APPLY}" == true ]]; then
      [[ -d "/sys/class/net/${BRIDGE_PARENT}" ]] || die "interface does not exist: ${BRIDGE_PARENT}"
    fi
  fi

  log "repository: ${REPO_ROOT}"
  log "mode: $([[ "${APPLY}" == true ]] && printf APPLY || printf DRY-RUN)"
  if [[ "${APPLY}" != true ]]; then
    log "no changes will be made; rerun with --apply after reviewing this plan"
  fi
}

install_packages() {
  local -a packages=(
    base-devel git curl rsync zsh neovim ghostty vivid tmux fzf ripgrep fd bat
    eza zoxide direnv jq yq github-cli wl-clipboard man-db man-pages
    plasma-meta sddm xorg-xwayland wayland-utils qt6-wayland
    pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber
    xdg-desktop-portal xdg-desktop-portal-kde
    xdg-desktop-portal-gtk kpipewire
    ttf-meslo-nerd ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji
    firefox flatpak dolphin ark spectacle
    obs-studio obs-gstreamer obs-backgroundremoval ffmpeg gstreamer
    gst-plugin-pipewire
    rustup zig go python python-pip pyenv nodejs npm shellcheck shfmt stylua
    networkmanager docker docker-compose qemu-full libvirt virt-manager dnsmasq
    edk2-ovmf swtpm tailscale snapper snap-pac btrfs-progs btrfs-assistant cronie
    egl-wayland libva-nvidia-driver
  )

  if [[ "${WITH_OBS_VIRTUAL_CAMERA}" == true ]]; then
    packages+=(v4l2loopback-dkms v4l2loopback-utils)
  fi

  log "install curated repository packages (pacman remains interactive)"
  run sudo pacman -Syu --needed "${packages[@]}"
}

clone_if_missing() {
  local url="$1"
  local destination="$2"

  if [[ -d "${destination}/.git" ]]; then
    log "keep existing checkout: ${destination}"
    return 0
  fi
  [[ ! -e "${destination}" ]] || die "existing non-git path blocks clone: ${destination}"
  run git clone --depth=1 -- "${url}" "${destination}"
}

deploy_shell() {
  local omz="${HOME}/.oh-my-zsh"

  log "deploy Zsh, Oh My Zsh plugins, and Powerlevel10k"
  clone_if_missing https://github.com/ohmyzsh/ohmyzsh.git "${omz}"
  clone_if_missing https://github.com/romkatv/powerlevel10k.git "${omz}/custom/themes/powerlevel10k"
  install_user_tree "${REPO_ROOT}/dotfiles/zsh/oh-my-zsh/custom/plugins/zsh-autosuggestions" \
    "${omz}/custom/plugins/zsh-autosuggestions"
  install_user_tree "${REPO_ROOT}/dotfiles/zsh/oh-my-zsh/custom/plugins/zsh-syntax-highlighting" \
    "${omz}/custom/plugins/zsh-syntax-highlighting"
  install_user_file 0644 "${REPO_ROOT}/dotfiles/zsh/.zshrc" "${HOME}/.zshrc"
  install_user_file 0644 "${REPO_ROOT}/dotfiles/zsh/.p10k.zsh" "${HOME}/.p10k.zsh"
  install_user_tree "${REPO_ROOT}/dotfiles/zsh/.zshrc.d" "${HOME}/.zshrc.d"

  if [[ "${SHELL:-}" != "/usr/bin/zsh" && "${SHELL:-}" != "/bin/zsh" ]]; then
    run chsh -s /usr/bin/zsh
  fi
}

deploy_dotfiles() {
  log "deploy tracked editor and terminal configuration"
  install_user_tree "${REPO_ROOT}/dotfiles/nvim" "${HOME}/.config/nvim"
  install_user_file 0644 "${REPO_ROOT}/dotfiles/ghostty/config" "${HOME}/.config/ghostty/config"
  install_user_file 0644 "${REPO_ROOT}/dotfiles/tmux/.tmux.conf" "${HOME}/.tmux.conf"
  install_user_file 0644 "${REPO_ROOT}/dotfiles/vivid/themes/ghost-hacker-blue.yml" \
    "${HOME}/.config/vivid/themes/ghost-hacker-blue.yml"
  install_user_file 0755 "${REPO_ROOT}/scripts/agent-scope.sh" "${HOME}/.local/bin/agent-scope"
  install_user_file 0644 "${REPO_ROOT}/system/systemd/user/agent-workload.slice" \
    "${HOME}/.config/systemd/user/agent-workload.slice"
  install_user_file 0644 "${REPO_ROOT}/dotfiles/obs/basic/profiles/GhostKellz/basic.ini" \
    "${HOME}/.config/obs-studio/basic/profiles/GhostKellz/basic.ini"
}

install_rust_schedule() {
  # shellcheck disable=SC2016 # HOME must expand later in the cron environment.
  local cron_line='17 4 * * 0 "$HOME/.local/bin/update-rust.zsh"'
  local cron_file

  log "install safe weekly Rust updater without running it"
  install_user_file 0755 "${REPO_ROOT}/scripts/update-rust.zsh" "${HOME}/.local/bin/update-rust.zsh"
  print_command crontab -l '(preserve existing entries and add managed Rust entry)'
  if [[ "${APPLY}" == true ]]; then
    ensure_scratch
    cron_file="${SCRATCH_DIR}/crontab"
    crontab -l >"${cron_file}" 2>/dev/null || true
    if ! grep -Fqx -- "${cron_line}" "${cron_file}"; then
      printf '\n# GhostKellz weekly Rust toolchain update\n%s\n' "${cron_line}" >>"${cron_file}"
      crontab "${cron_file}"
    fi
  fi
}

install_system_policy() {
  log "install tracked memory, journal, NVIDIA, and workload policies"
  install_system_file 0644 "${REPO_ROOT}/system/sysctl/99-sysctl.conf" \
    /etc/sysctl.d/99-sysctl.conf
  install_system_file 0644 "${REPO_ROOT}/system/memory/zram-generator.conf" \
    /etc/systemd/zram-generator.conf
  install_system_file 0644 "${REPO_ROOT}/system/memory/50-oomd.conf" \
    /etc/systemd/system/user.slice.d/50-oomd.conf
  install_system_file 0644 "${REPO_ROOT}/system/memory/60-workstation-limits.conf" \
    /etc/systemd/coredump.conf.d/60-workstation-limits.conf
  install_system_file 0644 "${REPO_ROOT}/system/systemd/journald.conf.d/60-workstation.conf" \
    /etc/systemd/journald.conf.d/60-workstation.conf
  install_system_file 0644 "${REPO_ROOT}/nvidia/nvidia.conf" \
    /etc/modprobe.d/nvidia.conf

  run sudo systemctl daemon-reload
  run systemctl --user daemon-reload
  run sudo sysctl --system
  run sudo systemctl enable systemd-oomd.service

  if [[ "${REBUILD_INITRAMFS}" == true ]]; then
    run sudo mkinitcpio -P
  else
    log "initramfs rebuild deferred; use --rebuild-initramfs when ready"
  fi
}

enable_services() {
  log "enable workstation services; authentication and network cutover remain manual"
  run sudo systemctl enable --now NetworkManager.service
  run sudo systemctl enable --now libvirtd.service
  run sudo systemctl enable --now docker.service
  run sudo systemctl enable --now tailscaled.service
  run sudo systemctl enable --now cronie.service
  run sudo systemctl enable sddm.service
  run sudo usermod -aG libvirt,kvm,docker "${TARGET_USER}"
}

verify_nvidia_source_workflow() {
  local source_dir="${HOME}/open-gpu-kernel-modules"
  local source_version
  local dkms_version
  local userland_version

  if [[ ! -f "${source_dir}/version.mk" || ! -f "${source_dir}/dkms.conf" ]]; then
    log "custom NVIDIA source tree not present; driver build and beta userland remain manual"
    return 0
  fi

  source_version="$(awk '$1 == "NVIDIA_VERSION" && $2 == "=" { print $3; exit }' \
    "${source_dir}/version.mk")"
  dkms_version="$(awk -F= '$1 == "PACKAGE_VERSION" { gsub(/"/, "", $2); print $2; exit }' \
    "${source_dir}/dkms.conf")"
  [[ -n "${source_version}" && "${source_version}" == "${dkms_version}" ]] || \
    die "NVIDIA source and dkms.conf versions do not match"

  log "custom NVIDIA DKMS source is version-consistent: ${source_version}"
  if userland_version="$(pacman -Q nvidia-utils-beta 2>/dev/null)"; then
    userland_version="${userland_version#* }"
    userland_version="${userland_version%-*}"
    [[ "${userland_version}" == "${source_version}" ]] || \
      die "nvidia-utils-beta ${userland_version} does not match source ${source_version}"
    log "nvidia-utils-beta matches the source module: ${userland_version}"
  else
    log "nvidia-utils-beta is not installed; do not register DKMS until matching userland is packaged"
  fi
}

configure_snapper() {
  local rendered

  [[ "${WITH_SNAPPER}" == true ]] || return 0
  log "validate and configure root Snapper policy"
  if [[ "${APPLY}" == true ]]; then
    [[ "$(findmnt -no FSTYPE /)" == btrfs ]] || die "--with-snapper requires a Btrfs root"
    if [[ ! -f /etc/snapper/configs/root ]]; then
      if findmnt -rn /.snapshots >/dev/null 2>&1; then
        die "existing /.snapshots mount requires manual topology review before create-config"
      fi
      run sudo snapper -c root create-config /
    fi
    ensure_scratch
    rendered="${SCRATCH_DIR}/snapper-root"
    awk -v user="${TARGET_USER}" '
      /^ALLOW_USERS=/ { print "ALLOW_USERS=\"" user "\""; next }
      { print }
    ' "${REPO_ROOT}/btrfs/snapper/root" >"${rendered}"
    run sudo cp -a -- /etc/snapper/configs/root "/etc/snapper/configs/root.bootstrap-backup"
    run sudo install -m0644 -- "${rendered}" /etc/snapper/configs/root
  else
    print_command findmnt -no FSTYPE /
    print_command sudo snapper -c root create-config / '(only if no config or .snapshots mount exists)'
    print_command sudo install -m0644 '(rendered tracked root policy)' /etc/snapper/configs/root
  fi
  install_system_file 0644 "${REPO_ROOT}/system/systemd/snapper-timeline.timer.d/schedule.conf" \
    /etc/systemd/system/snapper-timeline.timer.d/schedule.conf
  run sudo systemctl daemon-reload
  run sudo systemctl enable --now snapper-timeline.timer snapper-cleanup.timer
}

install_maintenance() {
  [[ "${WITH_MAINTENANCE}" == true ]] || return 0
  log "install bounded maintenance; preflight never starts a scrub"
  install_system_file 0755 "${REPO_ROOT}/scripts/weeklyMain.sh" /usr/local/bin/weekly-maintenance
  install_system_file 0755 "${REPO_ROOT}/scripts/btrfs-scrub-safe.sh" /usr/local/bin/btrfs-scrub-safe
  install_system_file 0644 "${REPO_ROOT}/system/systemd/weekMain.service" \
    /etc/systemd/system/weekMain.service
  install_system_file 0644 "${REPO_ROOT}/system/systemd/weekMain.timer" \
    /etc/systemd/system/weekMain.timer
  install_system_file 0644 "${REPO_ROOT}/system/systemd/btrfs-scrub-safe.service" \
    /etc/systemd/system/btrfs-scrub-safe.service
  install_system_file 0644 "${REPO_ROOT}/system/systemd/btrfs-scrub-safe.timer" \
    /etc/systemd/system/btrfs-scrub-safe.timer
  run sudo systemctl daemon-reload
  run sudo /usr/local/bin/weekly-maintenance --check
  run sudo /usr/local/bin/btrfs-scrub-safe --check
  run sudo systemctl disable --now btrfs-scrub@-.timer btrfs-scrub@data.timer
  run sudo systemctl enable --now weekMain.timer btrfs-scrub-safe.timer
}

configure_bridge_profiles() {
  [[ -n "${BRIDGE_PARENT}" ]] || return 0
  log "create disabled bridge profiles; no connection is activated"
  run sudo nmcli connection add type bridge ifname "${BRIDGE_NAME}" \
    con-name "${BRIDGE_NAME}" connection.autoconnect no ipv4.method auto ipv6.method auto
  run sudo nmcli connection add type ethernet ifname "${BRIDGE_PARENT}" \
    con-name "${BRIDGE_NAME}-${BRIDGE_PARENT}" master "${BRIDGE_NAME}" \
    connection.autoconnect no
}

install_agent_clis() {
  [[ "${WITH_AGENT_CLIS}" == true ]] || return 0
  log "install official agent CLI npm packages under ~/.local; do not authenticate"
  run npm install --global --prefix "${HOME}/.local" \
    @openai/codex @anthropic-ai/claude-code @google/gemini-cli
}

summary() {
  printf '\n'
  if [[ "${APPLY}" == true ]]; then
    log "apply phase complete; inspect output before rebooting"
    log "backups of replaced user files: ${BACKUP_ROOT}"
    log "backups of replaced system files: ${SYSTEM_BACKUP_ROOT}"
    log "log out and back in for shell and group membership changes"
  else
    log "dry run complete; no files, packages, services, or network profiles changed"
    log "rerun with --apply and only the optional flags you have reviewed"
  fi
}

main() {
  trap cleanup EXIT
  parse_args "$@"
  preflight
  install_packages
  deploy_shell
  deploy_dotfiles
  install_rust_schedule
  install_system_policy
  enable_services
  verify_nvidia_source_workflow
  configure_snapper
  install_maintenance
  configure_bridge_profiles
  install_agent_clis
  summary
}

main "$@"

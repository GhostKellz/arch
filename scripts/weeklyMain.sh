#!/bin/bash
# Weekly System Maintenance Script
# Runs system cleanup, Btrfs maintenance, dev env checkups, etc.

set -euo pipefail
echo "🛠️ Starting weekly maintenance: $(date)"

# 1. Update Mirrorlist
echo "🔄 Updating mirrors..."
reflector --country 'US' --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# 2. Update System (Pacman + AUR)
echo "📦 Updating system packages..."
pacman -Syu --noconfirm

echo "📦 Updating AUR packages..."
if command -v paru &>/dev/null; then
    paru -Syu --noconfirm
elif command -v yay &>/dev/null; then
    yay -Syu --noconfirm
fi

# 3. Remove Orphans
echo "🧹 Removing orphaned packages..."
pacman -Qtdq | xargs -r sudo pacman -Rns --

# 4. Pacman Cache Cleanup
echo "🧽 Cleaning pacman cache..."
paccache -rk2
pacman -Sc --noconfirm

# 5. Journal Cleanup
echo "🧾 Cleaning journal logs..."
journalctl --vacuum-time=7d

# 6. Btrfs Maintenance
echo "🧬 Running Btrfs scrub..."
btrfs scrub start -Bd /

echo "📊 Running Btrfs balance (75% usage)..."
btrfs balance start -dusage=75 -musage=75 /

# 7. DKMS (NVIDIA / Custom Kernel)
echo "🔧 Checking DKMS modules..."
dkms autoinstall

# 8. Font Cache Rebuild
echo "🔤 Rebuilding font cache..."
fc-cache -rv

# 9. Optional: Trim SSD (if not using autotrim)
echo "✂️ Running fstrim..."
fstrim -av

# 10. Check Failed Services
echo "🚨 Checking failed services..."
systemctl --failed

# 11. Check for large trash files
echo "🗑️ Checking for trash..."
trash-empty 7 &>/dev/null || echo "Install 'trash-cli' to auto-clear trash"

# 12. Verify Gaming/Dev Binaries
echo "🎮 Verifying GPU, Vulkan, dev tools..."
nvidia-smi
vulkaninfo | grep -i deviceName || echo "vulkaninfo missing"
for tool in rustc go zig python3 node; do
    command -v $tool >/dev/null && echo "$tool: $($tool --version)" || echo "$tool not found"
done

# 13. Node / NPM Upkeep 
echo "🧩 Updating Node/NPM (nvm)…"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

TARGET_NODE="${TARGET_NODE:-24}"   # set to 24 by default; change to 22 if you prefer
if command -v nvm >/dev/null 2>&1; then
  nvm install "$TARGET_NODE"
  nvm alias default "$TARGET_NODE"
  nvm use default
  # make sure the selected Node is first on PATH for the rest of the script
  export PATH="$HOME/.nvm/versions/node/$(nvm current)/bin:$PATH"

  echo "📦 Updating global npm + packages…"
  npm install -g npm@latest || true
  npm update -g || true
  npm cache verify || true

  echo "ℹ️ Node: $(node -v) | npm: $(npm -v) | which node: $(which node)"
else
  echo "⚠️ nvm not found; skipping Node update."
fi
 
14.  ── Neovim plugins / parsers / tools ────────────────────────
echo "🧠 Neovim: plugin + tool upkeep…"

# If rust-tools.nvim has local edits, remove it so Lazy can update cleanly
RT_DIR="$HOME/.local/share/nvim/lazy/rust-tools.nvim"
if [ -d "$RT_DIR/.git" ] && ! git -C "$RT_DIR" diff --quiet 2>/dev/null; then
  echo "🧹 Clearing local changes in rust-tools.nvim…"
  rm -rf "$RT_DIR"
fi

# Headless maintenance: Lazy plugins, Treesitter parsers, Mason registry
if command -v nvim >/dev/null 2>&1; then
  nvim --headless \
    "+Lazy! sync" \
    "+Lazy! clean" \
    "+Lazy! check" \
    "+TSUpdateSync" \
    "+MasonUpdate" \
    "+qa" || true

  # Optionally ensure/update common LSPs/formatters/debuggers (idempotent)
  nvim --headless +"lua(function()
    local ok, mr = pcall(require, 'mason-registry')
    if not ok then return end
    local want = {
      'lua-language-server','rust-analyzer','zls','pyright','gopls',
      'bash-language-server','yaml-language-server','dockerfile-language-server',
      'json-lsp','prettier','stylua','black','gofumpt','delve','debugpy','codelldb'
    }
    for _, name in ipairs(want) do
      local okp, pkg = pcall(mr.get_package, name)
      if okp then
        if not pkg:is_installed() then pkg:install() end
        if pkg:is_installed() and pkg:has_update() then pkg:install() end
      end
    end
  end) | qa" || true
else
  echo "⚠️ nvim not found; skipping Neovim maintenance."
fi

echo "✅ Weekly maintenance complete: $(date)"


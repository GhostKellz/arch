#!/usr/bin/env zsh
# Auto-update Rust toolchains via rustup
# Logs to ~/.local/log/rust-update.log

set -euo pipefail

LOG_DIR="${HOME}/.local/log"
LOG_FILE="${LOG_DIR}/rust-update.log"

mkdir -p "$LOG_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "Starting Rust update..."

# Update stable toolchain
if rustup update stable 2>&1 | tee -a "$LOG_FILE"; then
    log "Stable toolchain updated successfully"
else
    log "ERROR: Failed to update stable toolchain"
    exit 1
fi

# Optionally update nightly if installed
if rustup toolchain list | grep -q nightly; then
    log "Updating nightly toolchain..."
    rustup update nightly 2>&1 | tee -a "$LOG_FILE" || log "WARN: Nightly update failed (non-critical)"
fi

# Show current versions
log "Current versions:"
rustc --version | tee -a "$LOG_FILE"
cargo --version | tee -a "$LOG_FILE"

# Cleanup old toolchains (keep only active ones)
log "Cleaning up unused toolchains..."
rustup toolchain list | grep -E '^[0-9]+\.[0-9]+' | while read -r tc; do
    log "Removing old pinned toolchain: $tc"
    rustup toolchain uninstall "$tc" 2>&1 | tee -a "$LOG_FILE" || true
done

log "Rust update complete"

#!/bin/bash
# Update Zig 0.16.0-dev to the latest master build
# Fetches from https://ziglang.org/download/index.json

set -euo pipefail

INSTALL_DIR="/opt/zig-0.16.0-dev"
JSON_URL="https://ziglang.org/download/index.json"
TMP_DIR="/tmp/zig-update-$$"
VERSION_FILE="$INSTALL_DIR/.zig-dev-version"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

# Fetch build info from Zig's JSON API
log "Fetching latest build info..."
BUILD_INFO=$(curl -sS "$JSON_URL" | jq -r '.master."x86_64-linux"')

TARBALL_URL=$(echo "$BUILD_INFO" | jq -r '.tarball')
VERSION=$(echo "$BUILD_INFO" | jq -r '.version // empty')
SHASUM=$(echo "$BUILD_INFO" | jq -r '.shasum')

if [[ -z "$TARBALL_URL" || "$TARBALL_URL" == "null" ]]; then
    log "ERROR: Could not find x86_64-linux tarball URL"
    exit 1
fi

# Extract version from URL if not in JSON directly
if [[ -z "$VERSION" ]]; then
    VERSION=$(basename "$TARBALL_URL" .tar.xz | sed 's/zig-x86_64-linux-//')
fi

log "Latest version: $VERSION"
log "Tarball URL: $TARBALL_URL"

# Check if we already have this version
if [[ -f "$VERSION_FILE" ]]; then
    CURRENT_VERSION=$(cat "$VERSION_FILE")
    if [[ "$CURRENT_VERSION" == "$VERSION" ]]; then
        log "Already at latest version ($VERSION). Nothing to do."
        exit 0
    fi
    log "Current version: $CURRENT_VERSION"
fi

# Download
mkdir -p "$TMP_DIR"
TARBALL="$TMP_DIR/zig.tar.xz"

log "Downloading..."
curl -# -L -o "$TARBALL" "$TARBALL_URL"

# Verify checksum
log "Verifying checksum..."
ACTUAL_SHA=$(sha256sum "$TARBALL" | cut -d' ' -f1)
if [[ "$ACTUAL_SHA" != "$SHASUM" ]]; then
    log "ERROR: Checksum mismatch!"
    log "  Expected: $SHASUM"
    log "  Got:      $ACTUAL_SHA"
    exit 1
fi
log "Checksum verified."

# Install
log "Installing to $INSTALL_DIR..."
sudo mkdir -p "$INSTALL_DIR"
sudo rm -rf "$INSTALL_DIR"/*
sudo tar -xJf "$TARBALL" --strip-components=1 -C "$INSTALL_DIR"

# Save version info
echo "$VERSION" | sudo tee "$VERSION_FILE" > /dev/null

log "Done! Zig updated to $VERSION"
"$INSTALL_DIR/zig" version

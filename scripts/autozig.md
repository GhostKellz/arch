# autozig.zsh

Automated Zig 0.16.0-dev updater for Arch Linux development system.

## Overview

Downloads and installs the latest Zig master build from ziglang.org. Skips if already on the latest version. Verifies SHA256 checksum before installation.

**Script location:** `/home/chris/arch/scripts/autozig.zsh`
**Install path:** `/opt/zig-0.16.0-dev`
**Version tracking:** `/opt/zig-0.16.0-dev/.zig-dev-version`

## Dependencies

- `curl`
- `jq`
- `sha256sum` (coreutils)

## How It Works

1. Fetches build metadata from `https://ziglang.org/download/index.json`
2. Compares remote version against local `.zig-dev-version` file
3. If versions match, exits early (nothing to do)
4. Downloads tarball to temp directory
5. Verifies SHA256 checksum
6. Extracts to `/opt/zig-0.16.0-dev`
7. Writes new version to `.zig-dev-version`

## Setup

### 1. Ensure script is readable and executable

```bash
chmod 755 /home/chris/arch/scripts/autozig.zsh
```

### 2. Add root crontab entry

```bash
sudo crontab -e
```

Add:
```
0 4 * * * /home/chris/arch/scripts/autozig.zsh >> /var/log/autozig.log 2>&1
```

### 3. Enable cronie service

```bash
sudo systemctl enable --now cronie
```

### 4. Verify cron is running

```bash
systemctl status cronie
```

## Manual Execution

```bash
sudo /home/chris/arch/scripts/autozig.zsh
```

## Troubleshooting

**Cron not running updates:**
- Check script permissions: must be readable (`r`) not just executable
- Verify cronie service is active: `systemctl status cronie`
- Check log output: `cat /var/log/autozig.log`

**Checksum failures:**
- Network issue during download, re-run script
- Upstream may have updated the build mid-download (rare)

## Log Output Example

```
[2026-03-21 19:46:26] Fetching latest build info...
[2026-03-21 19:46:27] Latest version: 0.16.0-dev.2962+08416b44f
[2026-03-21 19:46:27] Tarball URL: https://ziglang.org/builds/zig-x86_64-linux-0.16.0-dev.2962+08416b44f.tar.xz
[2026-03-21 19:46:27] Downloading...
[2026-03-21 19:46:30] Verifying checksum...
[2026-03-21 19:46:30] Checksum verified.
[2026-03-21 19:46:30] Installing to /opt/zig-0.16.0-dev...
[2026-03-21 19:46:33] Done! Zig updated to 0.16.0-dev.2962+08416b44f
```

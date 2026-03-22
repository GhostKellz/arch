# github-autozig.sh

Automated Zig 0.16.0-dev updater for GitHub Actions self-hosted runners on Ubuntu.

## Overview

Downloads and installs the latest Zig master build from ziglang.org. Stops/starts the GitHub Actions runner service during updates. Creates a symlink at `/usr/local/bin/zig`. Skips entirely if already on the latest version.

**Script location (on runner VMs):** `/opt/scripts/github-autozig.sh`
**Install path:** `/opt/zig-0.16.0-dev`
**Symlink:** `/usr/local/bin/zig`
**Version tracking:** `/opt/zig-0.16.0-dev/.zig-dev-version`

## Dependencies

- `curl`
- `jq`
- `sha256sum` (coreutils)

Install on Ubuntu:
```bash
sudo apt install -y curl jq
```

## How It Works

1. Fetches build metadata from `https://ziglang.org/download/index.json`
2. Compares remote version against local `.zig-dev-version` file
3. If versions match, exits early (runner not interrupted)
4. Downloads tarball to temp directory
5. Verifies SHA256 checksum
6. **Stops GitHub Actions runner** via `svc.sh stop`
7. Extracts to `/opt/zig-0.16.0-dev`
8. Creates/updates symlink at `/usr/local/bin/zig`
9. Writes new version to `.zig-dev-version`
10. **Starts GitHub Actions runner** via `svc.sh start`

## Configuration

Edit these variables at the top of the script if paths differ:

```bash
INSTALL_DIR="/opt/zig-0.16.0-dev"
SYMLINK_PATH="/usr/local/bin/zig"
RUNNER_DIR="/home/ckelley/actions-runner"
```

## Setup (per Ubuntu VM)

### 1. Copy script to VM

```bash
sudo mkdir -p /opt/scripts
sudo cp github-autozig.sh /opt/scripts/
sudo chmod 755 /opt/scripts/github-autozig.sh
```

### 2. Install dependencies

```bash
sudo apt install -y curl jq
```

### 3. Add root crontab entry

```bash
sudo crontab -e
```

Add:
```
0 4 * * * /opt/scripts/github-autozig.sh >> /var/log/autozig.log 2>&1
```

### 4. Verify cron is running

```bash
sudo systemctl status cron
```

## Manual Execution

```bash
sudo /opt/scripts/github-autozig.sh
```

## Differences from Arch Version (autozig.zsh)

| Feature | autozig.zsh (Arch) | github-autozig.sh (Ubuntu) |
|---------|-------------------|---------------------------|
| Runner management | None | Stops/starts via svc.sh |
| Symlink | None | /usr/local/bin/zig |
| Runner path | N/A | /home/ckelley/actions-runner |
| Cron service | cronie | cron |

## Troubleshooting

**Runner not restarting:**
- Check `RUNNER_DIR` variable matches actual path
- Verify svc.sh exists: `ls -la /home/ckelley/actions-runner/svc.sh`

**Script not running on schedule:**
- Verify cron service: `sudo systemctl status cron`
- Check log: `cat /var/log/autozig.log`

**Checksum failures:**
- Network issue during download, re-run script

## Log Output Example

```
[2026-03-21 20:00:00] Fetching latest build info...
[2026-03-21 20:00:01] Latest version: 0.16.0-dev.2962+08416b44f
[2026-03-21 20:00:01] No version file found, will install fresh.
[2026-03-21 20:00:01] Tarball URL: https://ziglang.org/builds/zig-x86_64-linux-0.16.0-dev.2962+08416b44f.tar.xz
[2026-03-21 20:00:01] Downloading...
[2026-03-21 20:00:05] Verifying checksum...
[2026-03-21 20:00:05] Checksum verified.
[2026-03-21 20:00:05] Stopping GitHub Actions runner...
[2026-03-21 20:00:06] Installing to /opt/zig-0.16.0-dev...
[2026-03-21 20:00:09] Updating symlink at /usr/local/bin/zig...
[2026-03-21 20:00:09] Starting GitHub Actions runner...
[2026-03-21 20:00:10] Done! Zig updated to 0.16.0-dev.2962+08416b44f
```

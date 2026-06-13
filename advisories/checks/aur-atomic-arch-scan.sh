#!/usr/bin/env bash
# Atomic Arch (AUR June 2026) IOC scanner — defensive detection only.
# Cross-references installed AUR packages against a known-bad list and sweeps
# the host for on-disk indicators of the atomic-lockfile / js-digest campaign.
#
# Known-bad list + IOCs sourced from:
#   https://github.com/lenucksi/aur-malware-check
#
# Usage: aur-atomic-arch-scan.sh [path-to-package_list.txt]
#   With no argument, the list is fetched from the GitHub repo (raw).
#   Pass a local package_list.txt to scan offline.
set -u

LIST_URL="https://raw.githubusercontent.com/lenucksi/aur-malware-check/master/package_list.txt"
LIST="${1:-}"
if [[ -z "$LIST" ]]; then
  LIST="$(mktemp)"; trap 'rm -f "$LIST"' EXIT
  curl -fsSL "$LIST_URL" -o "$LIST" || { echo "WARN: could not fetch known-bad list from $LIST_URL"; : > "$LIST"; }
fi
DEPS_SHA256="6144D433F8A0316869877B5F834C801251BBB936E5F1577C5680878C7443C98B"
DEPS_SIZE="3040376"
fail=0

note() { printf '%-46s %s\n' "$1" "$2"; }
flag() { printf '  !! %s\n' "$1"; fail=1; }

echo "== Atomic Arch IOC scan =="

# 1. Installed AUR pkgs vs known-bad names
if [[ -f "$LIST" ]]; then
  hits=$(comm -12 \
    <(pacman -Qmq | sort -u) \
    <(grep -vE '^\s*#|^\s*$' "$LIST" | sort -u))
  if [[ -n "$hits" ]]; then flag "compromised package(s) installed:"; echo "$hits" | sed 's/^/     /'
  else note "1. installed vs known-bad list" "CLEAN"; fi
else
  note "1. known-bad list" "SKIP (not found: $LIST)"
fi

# 2. eBPF rootkit maps
bpf=0
for m in hidden_pids hidden_names hidden_inodes; do
  [[ -e "/sys/fs/bpf/$m" ]] && { flag "eBPF map present: /sys/fs/bpf/$m"; bpf=1; }
done
[[ $bpf -eq 0 ]] && note "2. eBPF rootkit maps" "CLEAN"

# 3. deps ELF payload by size, then hash
found=$(find / -xdev -type f -name deps -size "${DEPS_SIZE}c" 2>/dev/null)
if [[ -n "$found" ]]; then
  while read -r f; do
    h=$(sha256sum "$f" | awk '{print toupper($1)}')
    [[ "$h" == "$DEPS_SHA256" ]] && flag "deps payload (hash match): $f" || flag "deps-sized file (verify): $f"
  done <<< "$found"
else note "3. deps ELF payload" "CLEAN"; fi

# 4. npm / bun caches
if grep -rilE 'atomic-lockfile|js-digest|lockfile-js' "$HOME/.npm/_cacache" "$HOME/.bun" 2>/dev/null | grep -q .; then
  flag "npm/bun cache references malicious package"
else note "4. npm/bun caches" "CLEAN"; fi

# 5. Injected install hooks in installed pkgs
if grep -rilE 'atomic-lockfile|js-digest|npm install atomic|bun install js-digest|src/hooks/deps' \
    /var/lib/pacman/local 2>/dev/null | grep -q .; then
  flag "installed package install-script references payload"
else note "5. pacman install hooks" "CLEAN"; fi

# 6. Rogue persistence (Restart=always user/system units)
if grep -rlE 'atomic-lockfile|js-digest|src/hooks/deps' \
    /etc/systemd /usr/lib/systemd "$HOME/.config/systemd/user" 2>/dev/null | grep -q .; then
  flag "systemd unit references payload"
else note "6. systemd persistence" "CLEAN"; fi

# 7. Cryptominer artifact
[[ -e /usr/bin/monero-wallet-gui ]] && flag "/usr/bin/monero-wallet-gui present" \
  || note "7. cryptominer artifact" "CLEAN"

echo
if [[ $fail -eq 0 ]]; then echo ">>> RESULT: CLEAN — no Atomic Arch IOCs detected."; exit 0
else echo ">>> RESULT: SUSPICIOUS — investigate flagged items. Treat host as compromised."; exit 1; fi

#!/usr/bin/env bash
# Pick one random wallpaper from the pool and apply it to every screen,
# so all monitors always show the same image. Run by wallpaper-cycle.timer.
set -euo pipefail

POOLS=(
  /home/chris/Pictures/wallpapers/cycle
  /data/projects/ghost/wallpapers/collection
)
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/wallpaper-cycle.last"

mapfile -t files < <(find "${POOLS[@]}" -maxdepth 1 \( -type f -o -type l \) \
  \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.avif' \) \
  | sort -u)

[ "${#files[@]}" -gt 0 ] || { echo "no wallpapers found" >&2; exit 1; }

last=$(cat "$STATE" 2>/dev/null || true)
pick="${files[RANDOM % ${#files[@]}]}"
# Avoid showing the same image twice in a row when there is a choice.
if [ "${#files[@]}" -gt 1 ]; then
  while [ "$pick" = "$last" ]; do pick="${files[RANDOM % ${#files[@]}]}"; done
fi

plasma-apply-wallpaperimage "$pick"
mkdir -p "$(dirname "$STATE")"
printf '%s\n' "$pick" > "$STATE"

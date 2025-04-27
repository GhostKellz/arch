#!/bin/zsh
# Clean orphaned /boot files for missing kernels
# Author: GhostKellz

print "🧹 Scanning /boot for orphaned kernel artifacts...\n"

for file in /boot/*; do
  if [[ $file == *"cachyos-bore"* ]] || [[ $file == *"fallback"* && ! -e /boot/vmlinuz-linux ]]; then
    print "⚡ Orphaned: $file"
    read -k "reply?Delete this file? (y/n) "
    echo
    if [[ $reply == [yY] ]]; then
      sudo rm -v "$file"
      print "✅ Deleted: $file\n"
    else
      print "❌ Skipped: $file\n"
    fi
  fi
done

print "🎯 Scan complete."

# ~/.zshrc.d/snapper.zsh
# Snapper Btrfs snapshot helpers

# Show snapshots
alias snapls='sudo snapper list'

# Create snapshot manually
alias snap='sudo snapper create --description'

# Delete snapshot by ID
alias snaprm='sudo snapper delete'

# Compare two snapshots
alias snapdiff='sudo snapper diff'

# Cleanup old snapshots (timeline)
alias snapcleanup='sudo snapper cleanup timeline'

# Mount snapshot manually
alias snapmount='sudo mount -o subvol=.snapshots/$1/snapshot /dev/$2 /mnt/snapshot'

# Example usage:
# snap "Before installing nvidia"
# snaprm 17
# snapmount 17 sda2

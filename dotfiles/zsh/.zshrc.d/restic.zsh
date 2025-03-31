# ~/.zshrc.d/restic.zsh
# Restic backup helpers

# Base command with env
alias resticenv='RESTIC_PASSWORD_FILE=/etc/restic.env restic'

# Common actions
alias restic-init='resticenv init'
alias restic-backup='resticenv backup ~/ --exclude-file=/etc/restic.exclude'
alias restic-snapshots='resticenv snapshots'
alias restic-restore='resticenv restore latest --target ~/ResticRestore'
alias restic-prune='resticenv forget --keep-daily 7 --keep-weekly 4 --keep-monthly 3 --prune'

# Check for corruption
alias restic-check='resticenv check'

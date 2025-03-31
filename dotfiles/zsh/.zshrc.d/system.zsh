# ~/.zshrc.d/system.zsh
# System management (systemd + systemd-boot)

# Power
alias reboot='systemctl reboot'
alias poweroff='systemctl poweroff'
alias suspend='systemctl suspend'

# Bootloader (systemd-boot)
alias bootloader='bootctl status'
alias bootentries='ls /boot/loader/entries'
alias bootedit='sudo nvim /boot/loader/entries/linux-zen.conf'

# Services
alias status='systemctl status'
alias servicestatus='systemctl status'
alias services='systemctl list-units --type=service'

# Journal
alias journal='journalctl -xe'
alias jboot='journalctl -b -1'  # previous boot
alias jnow='journalctl -f'      # follow current log

# Processes
alias psu='ps aux | grep'

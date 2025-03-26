# Arch Linux Cheatsheet

### Snapper test snapshot
#### / dir 
sudo snapper -c root create --description "snapshot_#1_$(date +%Y-%m-%d)"

#### /home dir
sudo snapper -c home create --description "initial home snapshot"
sudo snapper -c home list

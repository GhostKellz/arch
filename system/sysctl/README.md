# 🧠 system/sysctl

This directory contains custom `sysctl` configurations for optimizing system performance, memory usage, and improving compatibility for gaming on Arch Linux.

These `.conf` files are automatically loaded at boot by `systemd-sysctl` if placed in `/etc/sysctl.d/`.

---

## 🔧 Included Configs

### `99-sysctl.conf`

General system performance tweaks:

```ini
vm.swappiness = 10
vm.vfs_cache_pressure = 50
```

- **`vm.swappiness = 10`**  
  Reduces the kernel's tendency to swap processes out of physical RAM. Helps keep apps in memory longer.

- **`vm.vfs_cache_pressure = 50`**  
  Tells the kernel to preserve inode and dentry caches more aggressively, improving filesystem performance.

---

### `80-gamecompatibility.conf`

Gaming-related memory map tweak:

```ini
vm.max_map_count = 2147483642
```

- Required by many modern games running via **Proton**, **Wine**, or **Lutris**.
- Especially important for titles using **Unreal Engine**, **Unity**, or those with **anti-cheat systems** (e.g. EAC, BattleEye).

---

## 📦 Usage

To apply these settings:

```bash
sudo cp *.conf /etc/sysctl.d/
sudo sysctl --system
```

You can check values at any time using:
```bash
sysctl vm.swappiness
sysctl vm.vfs_cache_pressure
sysctl vm.max_map_count
```

---

## 💒 Notes

- These settings are safe for most desktop and gaming workloads.
- Adjust values based on personal preference or system use case.


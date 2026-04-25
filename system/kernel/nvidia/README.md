# NVIDIA Kernel Patches

Patches and fixes for NVIDIA drivers with custom kernels.

---

## Current Setup

- **Driver**: nvidia-open 595.x (manual DKMS)
- **GPU**: RTX 5090 (Blackwell)
- **Kernel**: 7.0.x

---

## Kernel 7.0 Compatibility

Linux 7.0 changed BTF generation (`pahole-flags.sh` → `gen-btf.sh`), breaking NVIDIA DKMS builds.

**Fix location**: `/var/lib/dkms/nvidia-open/<VERSION>/source/kernel-open/Makefile`

**Full documentation**: `~/arch/kb/kernel-7.0-compat.md`

### Quick Fix

Edit line ~98 in the Makefile:

```makefile
# Before
PAHOLE_VARIABLES=$(if $(wildcard $(KERNEL_SOURCES)/scripts/pahole-flags.sh),,"PAHOLE=$(AWK) '$(PAHOLE_AWK_PROGRAM)'")

# After
PAHOLE_VARIABLES=$(if $(or $(wildcard $(KERNEL_SOURCES)/scripts/pahole-flags.sh),$(wildcard $(KERNEL_SOURCES)/scripts/gen-btf.sh)),,"PAHOLE=$(AWK) '$(PAHOLE_AWK_PROGRAM)'")
```

Then rebuild:
```bash
sudo dkms build nvidia-open/595.58.03 -k $(uname -r)
sudo dkms install nvidia-open/595.58.03 -k $(uname -r)
sudo mkinitcpio -P
```

---

## Available Patches

| Patch | Description |
|-------|-------------|
| `kernel-7.0-btf.patch` | BTF generation fix for kernel 7.0+ |

### Applying kernel-7.0-btf.patch

```bash
cd /var/lib/dkms/nvidia-open/595.58.03/source
sudo patch -p1 < ~/arch/system/kernel/nvidia/kernel-7.0-btf.patch
```

---

## Adding Future Patches

Place kernel-specific patches here with naming convention:

```
kernel-<version>-<fix>.patch    # e.g., kernel-7.1-btf.patch
```

---

## Notes

- nvidia-open requires kernel 5.x+ and driver 515+
- RTX 5090 (Blackwell) requires nvidia-open 570+
- Legacy nvidia-all patches removed (were for kernels 4.x-6.x)

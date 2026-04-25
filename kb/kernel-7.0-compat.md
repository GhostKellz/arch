# NVIDIA Open Drivers with Linux Kernel 7.0

Linux kernel 7.0 introduced changes to BTF (BPF Type Format) generation that break NVIDIA DKMS module builds. This documents the fix.

## The Problem

Kernel 7.0 replaced `scripts/pahole-flags.sh` with `scripts/gen-btf.sh`. NVIDIA's Makefile only checks for the old script, causing the awk-based PAHOLE wrapper to be used incorrectly with the new BTF system.

### Error Symptoms

```
awk: cmd. line:1: 'BEGIN
awk: cmd. line:1: ^ invalid char ''' in expression
make[5]: *** [scripts/Makefile.modfinal:59: nvidia.ko] Error 1
```

Modules compile successfully but fail during BTF generation.

## The Fix

Patch the NVIDIA kernel-open Makefile to also check for `gen-btf.sh`:

### Location
```
/var/lib/dkms/nvidia-open/<VERSION>/source/kernel-open/Makefile
```

### Change (Line ~98)

**Before:**
```makefile
PAHOLE_VARIABLES=$(if $(wildcard $(KERNEL_SOURCES)/scripts/pahole-flags.sh),,"PAHOLE=$(AWK) '$(PAHOLE_AWK_PROGRAM)'")
```

**After:**
```makefile
PAHOLE_VARIABLES=$(if $(or $(wildcard $(KERNEL_SOURCES)/scripts/pahole-flags.sh),$(wildcard $(KERNEL_SOURCES)/scripts/gen-btf.sh)),,"PAHOLE=$(AWK) '$(PAHOLE_AWK_PROGRAM)'")
```

## Applying the Fix

1. Edit the Makefile (use your editor, not sed):
   ```bash
   sudo nvim /var/lib/dkms/nvidia-open/595.58.03/source/kernel-open/Makefile
   ```

2. Rebuild the module:
   ```bash
   sudo dkms build nvidia-open/595.58.03 -k $(uname -r)
   sudo dkms install nvidia-open/595.58.03 -k $(uname -r)
   ```

3. Regenerate initramfs:
   ```bash
   sudo mkinitcpio -P
   ```

## Affected Versions

- **Kernel:** 7.0+
- **NVIDIA Driver:** 595.x (nvidia-open)
- **Fix verified:** 595.58.03 on kernel 7.0.1-tkg

## References

- [Manjaro kernel-7.0.patch](https://gitlab.manjaro.org/packages/extra/nvidia-utils/-/blob/master/kernel-7.0.patch)
- [CachyOS NVIDIA integration](https://discuss.cachyos.org/)

## Notes

- This fix may be included in future nvidia-open-dkms package updates
- The proprietary nvidia-dkms likely needs the same fix
- CachyOS kernel packages may include this patch automatically

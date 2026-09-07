# Historical NVIDIA Open BTF Compatibility Fix

Status: historical. The current source-DKMS workflow builds against the custom
CachyOS-LTO kernel without this local patch. Retain this note only for diagnosing
the exact older failure signature below.

## Original failure

The kernel BTF helper changed from `scripts/pahole-flags.sh` to
`scripts/gen-btf.sh`. Older NVIDIA Open Makefiles checked only the former and
selected an incompatible awk-based PAHOLE wrapper.

```text
awk: cmd. line:1: ^ invalid char ''' in expression
make: *** [scripts/Makefile.modfinal:...: nvidia.ko] Error 1
```

## Recorded fix

The historical change taught the NVIDIA Makefile to accept either helper:

```makefile
PAHOLE_VARIABLES=$(if $(or $(wildcard $(KERNEL_SOURCES)/scripts/pahole-flags.sh),$(wildcard $(KERNEL_SOURCES)/scripts/gen-btf.sh)),,"PAHOLE=$(AWK) '$(PAHOLE_AWK_PROGRAM)'")
```

The retained patch is
[`../system/kernel/nvidia/kernel-7.0-btf.patch`](../system/kernel/nvidia/kernel-7.0-btf.patch).

## Safe triage

1. Capture the real DKMS failure from `journalctl` or the module's
   `/var/lib/dkms/nvidia-open/<version>/build/make.log`.
2. Confirm the error matches this BTF failure exactly.
3. Check `~/open-gpu-kernel-modules/kernel-open/Makefile` for equivalent
   upstream handling before applying anything.
4. Patch the tracked source tree only through a reviewed commit; do not edit
   `/var/lib/dkms` as the durable source of truth.
5. Rebuild for the explicit target kernel and verify `vermagic` with `modinfo`.

If current source already handles `gen-btf.sh`, this workaround is obsolete and
must not be applied.

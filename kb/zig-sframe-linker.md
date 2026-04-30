# Zig Linker Issue: R_X86_64_PC64 in .sframe section

**Upstream Issue:** https://codeberg.org/ziglang/zig/issues/31272

## Environment
- **Zig version:** 0.17.0-dev.101+4e2147d14
- **OS:** Arch Linux / CachyOS userspace
- **Kernel:** 7.0.1 CachyOS LTO
- **GCC:** 15.2.1 20260209
- **glibc:** 2.43+r22+g8362e8ce10b2-1 (updated 2026-04-21)

This is not an exotic setup. It is a current Arch/CachyOS workstation using current mainstream rolling packages for newer hardware.

## Error
```
error: fatal linker error: unhandled relocation type R_X86_64_PC64 at offset 0x1c
    note: in /usr/lib/gcc/x86_64-pc-linux-gnu/15.2.1/../../../../lib/crt1.o:.sframe
error: fatal linker error: unhandled relocation type R_X86_64_PC64 at offset 0x2c
    note: in /usr/lib/gcc/x86_64-pc-linux-gnu/15.2.1/../../../../lib/crt1.o:.sframe
```

## Reproduction
```bash
# Fails
echo 'const std = @import("std"); pub fn main() void { std.debug.print("hi", .{}); }' > /tmp/test.zig
zig build-exe /tmp/test.zig -lc

# Works (no libc)
zig build-exe /tmp/test.zig
```

## Affected Projects
Any Zig project that links libc, including:
- phantom (link_libc = true for PTY/C interop)
- grove (tree-sitter C code)
- grim, nvfury, nvhud, nvlatency, nvshader, nvsync, nvvk

This is not Phantom-specific. Phantom was just one of the projects that exposed the issue first.

## Root Cause
- Current Arch glibc/GCC startup objects now include `.sframe` data
- `.rela.sframe` in `/usr/lib/crt1.o` contains `R_X86_64_PC64` relocations
- Zig `0.17.0-dev.101+4e2147d14` cannot currently link those startup objects on this host when libc is involved
- The failure occurs before project-specific application logic matters

## Verification
```bash
readelf -SW /usr/lib/crt1.o | grep sframe
# Output: [ 5] .sframe GNU_SFRAME ...

readelf -Wr /usr/lib/crt1.o
# .rela.sframe contains:
# R_X86_64_PC64 at offsets 0x1c and 0x2c

# GCC 14 crt files don't have sframe (for reference)
readelf -SW /usr/lib/gcc/x86_64-pc-linux-gnu/14.3.1/crtbegin.o | grep sframe
# (no output)
```

## Workarounds Tried

Tested with a minimal libc-linked Zig program:

```bash
zig build-exe /tmp/test.zig -lc -fno-lld
zig build-exe /tmp/test.zig -lc -fno-lld -fllvm
zig build-exe /tmp/test.zig -lc -fno-lld -fPIE
```

All still fail with the same `.sframe` / `R_X86_64_PC64` linker error.

That means there is no simple flag-only workaround in this Zig build on this host.

## Workarounds
1. Wait for Zig fix (see upstream issue)
2. Use a local older glibc/crt sysroot without changing the host system
3. Use a container/VM/chroot with an older toolchain userspace
4. Use musl targets where that is viable

## Status
**RESOLVED** - Fixed upstream in Zig `0.17.0-dev.135+9df02121d` (or earlier).

The fix landed sometime between dev.101 and dev.135 (~late April 2026). All libc-linked projects now build cleanly on Arch with glibc 2.43+.

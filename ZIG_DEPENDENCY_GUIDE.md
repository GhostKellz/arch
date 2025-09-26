ZIG_DEPENDENCY_CHEATSHEET.md

Practical patterns for adding, pinning, and shipping Zig dependencies across apps and libs.
Uses examples from the Ghost stack (e.g., zsync, zhttp, zquic, ripple) but applies to any project.

0) Mental model

build.zig.zon = your dependency manifest (names, URLs, hashes).

zig build --fetch = resolves & vendors deps into the Zig global cache.

build.zig = wires deps into your targets (modules, C objects, options).

Rule: libraries stay allocator-aware, feature-flagged, and portable; apps choose concrete runtimes/backends.

1) Add a dependency
A. Pin by tag or commit (recommended)
zig fetch --save git+https://github.com/ghostkellz/zhttp#v0.3.2
# or pin to a commit
zig fetch --save git+https://github.com/ghostkellz/zhttp#7e2c2d1


This writes an entry to build.zig.zon with an integrity hash.

B. Wire it in build.zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target   = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // 1) Declare your module from the fetched dep
    const zhttp_dep = b.dependency("zhttp", .{
        .target = target,
        .optimize = optimize,
    });

    // 2) Create your library/exe
    const exe = b.addExecutable(.{
        .name = "myapp",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    // 3) Add the dependency’s public module
    exe.root_module.addImport("zhttp", zhttp_dep.module("zhttp"));

    // 4) Link C system libs if the dep needs them (example)
    // exe.linkSystemLibrary("ssl");
    // exe.linkSystemLibrary("crypto");

    b.installArtifact(exe);
}


Use it in code:

const zhttp = @import("zhttp");

2) Version pinning & reproducibility

Always pin to a tag or commit. Don’t depend on main.

Check in build.zig.zon to git.

CI: run zig build --fetch before build.

Checksum drift: if upstream retags, your integrity hash will fail (good!). Update intentionally.

3) Local, path-based deps (monorepo/workspace)

In build.zig.zon:

.depends = .{
  .zsync = .{ .path = "../zsync" },
  .zquic = .{ .path = "../zquic" },
},


Pros: fast iteration, offline-friendly.
Cons: don’t publish with path deps—rewrite to git URLs before release.

4) Optional features (no “cargo features”, but you can emulate)

Expose toggles via build options and conditional imports.

// build.zig
const use_zsync = b.option(bool, "zsync", "Enable zsync runtime") orelse false;
const exe = b.addExecutable(.{ .name = "server", ... });

if (use_zsync) {
    const zsync_dep = b.dependency("zsync", .{ .target = target, .optimize = optimize });
    exe.root_module.addImport("zsync", zsync_dep.module("zsync"));
    exe.root_module.addOption(bool, "feature_zsync", true);
} else {
    exe.root_module.addOption(bool, "feature_zsync", false);
}

// src/main.zig
const feature_zsync = @import("root").feature_zsync;
pub fn main() !void {
    if (feature_zsync) {
        const zsync = @import("zsync");
        // run with zsync
    } else {
        // run with a minimal loop / wasm adapter
    }
}


CLI:

zig build -Dzsync=true

5) Public vs private dependencies

Library:

Keep deps private (only in tests or internal modules).

If you must expose a dep’s types in your public API, re-expose explicitly and document the version range.

Application:

Fine to add many deps; you own the binary.

6) Platform-specific deps

Guard platform bindings:

if (target.result.os.tag == .linux) {
    exe.linkSystemLibrary("udev");
}
if (target.result.os.tag == .windows) {
    exe.linkSystemLibrary("ws2_32");
}


Avoid importing modules on unsupported targets:

comptime {
    if (@import("std").builtin.os.tag == .linux) {
        _ = @import("zwire"); // PipeWire impl
    }
}

7) WASM/browser-friendly deps

Don’t hard-require threads, files, or sockets.

Provide a runtime adapter layer (e.g., timers, fetch, websockets via JS).

Keep crypto, parsing, rendering, layouts pure Zig when possible.

Minimal pattern:

pub const Runtime = struct {
    sleep_ms: fn (u64) void,
    fetch: ?fn (method: []const u8, url: []const u8, body: []const u8) ![]u8 = null,
    // ...
};


Ship wasm_runtime() and zsync_runtime() adapters in separate files.

8) C/FFI dependencies

Prefer pure Zig libs (zcrypto, zregex, zpack) to avoid toolchain headaches.

If you must use C, wrap via addCSourceFiles and linkSystemLibrary, but:

Make it optional with -Dwith_c=true.

Document required headers and pkg-config hints.

Keep headers vendored or pinned.

9) Allocator-aware libraries

Accept an Allocator at the boundary (no hidden globals).

Expose no-alloc fast paths where possible.

For caches/pools, allow the caller to supply an allocator or pool policy.

pub fn Client(init: Init, allocator: std.mem.Allocator) !Client { ... }

10) Testing dependencies

Test-only deps go in a separate module:

const tests = b.addTest(.{
    .root_source_file = .{ .path = "src/lib.zig" },
    .target = target,
    .optimize = optimize,
});
const ghostspec_dep = b.dependency("ghostspec", .{});
tests.root_module.addImport("ghostspec", ghostspec_dep.module("ghostspec"));
b.installArtifact(tests);


Keep integration tests in tests/ with their own minimal build.zig if they need extra deps.

11) CI caching & speed

Set the global cache outside the ephemeral workspace:

export ZIG_GLOBAL_CACHE_DIR=/opt/zig-cache   # Linux CI runner
zig build --fetch
zig build -Drelease-fast


Cache $ZIG_GLOBAL_CACHE_DIR and your repo’s zig-cache/.

Split fetch and build steps to maximize cache hits.

12) Naming & module structure

Module name = short, lowercase handle: zhttp, zquic, zsync, zrpc, zpix, zfont.

Directory layout:

repo/
  src/
    lib.zig        # public entry
    internal/      # non-public subsystems
  examples/
  tests/
  build.zig
  build.zig.zon
  README.md
  LICENSE


Re-export your public API only from src/lib.zig. Keep internals behind that boundary.

13) License hygiene for deps

Add a tiny “THIRD-PARTY.md” that lists:

Dep name, URL, version/commit

License type

Notes on static/dynamic linking

Stay compatible (MIT/Apache-2.0 are simplest for the Zig world).

14) Common patterns (Ghost stack examples)

Networking app (ripple, zhttp demo):
Pin zhttp, zquic; optional zsync runtime (on by default for server builds, off/adapter for WASM).

Protocol suite (zproto):
Core is pure Zig; per-protocol submodules with zero or optional deps; no hard dependency on ghostnet.

Rendering (kline):
Split backends into submodules; each backend optional & platform-gated; no global allocator.

CLI (flash):
Optional integrations: -Dcompletions, -Ddocs, -Dconfig (backed by zconf once ready).

15) Troubleshooting quickies

Two Zig versions on PATH: which zig and type -a zig. Fix PATH or use absolute /opt/zig/zig.

“Unknown dependency”: Did you run zig build --fetch? Is the name in build.zig.zon matching b.dependency("name", …)?

Checksum mismatch: Upstream changed. Update the pinned ref and re-run zig fetch --save ….

Missing system libs: Add exe.linkSystemLibrary("…") and install dev packages on CI.

WASM import errors: Remove thread/file/socket code, use adapters; mark unsupported paths with @compileError on wasm32.

16) Minimal templates
Library build.zig
pub fn build(b: *std.Build) void {
    const target   = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addLibrary(.{
        .name = "zpix",
        .root_source_file = .{ .path = "src/lib.zig" },
        .target = target,
        .optimize = optimize,
    });

    // Optional dep example
    if (b.option(bool, "with_sse", "Enable SSE optimizations") orelse false) {
        lib.root_module.addOption(bool, "with_sse", true);
    }

    b.installArtifact(lib);
}

App build.zig (with deps)
pub fn build(b: *std.Build) void {
    const target   = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "ripple-dev",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const zhttp = b.dependency("zhttp", .{ .target = target, .optimize = optimize });
    const zquic = b.dependency("zquic", .{ .target = target, .optimize = optimize });

    exe.root_module.addImport("zhttp", zhttp.module("zhttp"));
    exe.root_module.addImport("zquic", zquic.module("zquic"));

    // Runtime toggle
    const use_zsync = b.option(bool, "zsync", "Enable zsync") orelse true;
    if (use_zsync) {
        const zsync = b.dependency("zsync", .{ .target = target, .optimize = optimize });
        exe.root_module.addImport("zsync", zsync.module("zsync"));
        exe.root_module.addOption(bool, "feature_zsync", true);
    } else {
        exe.root_module.addOption(bool, "feature_zsync", false);
    }

    b.installArtifact(exe);
}

17) Keep it simple

Fewer mandatory deps → more portability.

Feature flags over forks.

One runtime adapter layer reused across libs.

Pin versions. Check in the manifest. Cache CI.

Write a paragraph in your README: “This library is allocator-aware and runtime-agnostic. Enable -Dzsync=true to use the zsync executor.”

🧰

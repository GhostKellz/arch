# 🚀 Zig 0.16 "Understand & Build Well" Guide

This is a practical, paste-ready guide for designing rock-solid Zig libraries and apps—with special focus on allocators, API design best-practices (0.16), and when to use modular build flags vs. a flat build.

## 🧠 Core Mental Model (What Zig Wants From You)

🔒 **You own memory.** All allocation is explicit; pass an Allocator down your call graph. No hidden mallocs.

⚡ **Errors are values.** Use try, small error sets, and errdefer for cleanup on failure.

🔄 **Init/Deinit pairs.** Your types should have init(...) !Self and deinit(self: *Self); never allocate in global scope.

📊 **Slices, not vectors.** Favor []T with explicit length; copy/clone using the caller's allocator.

⚙️ **Comptime is a tool, not a religion.** Keep public generics stable and readable; hide template gymnastics behind small APIs.

🚫 **No global singletons.** If you need "global config", pass a Context struct.

## 🧩 Allocators: What to Use, When to Use It

### 🎯 Quick Chooser

| Situation | Allocator | Why |
| --- | --- | --- |
| Short-lived, bulk build-up then free-at-once | `ArenaAllocator` | Ultra fast alloc/free; one deinit clears all |
| General purpose, mixed lifetimes (debug/dev) | `GeneralPurposeAllocator (GPA)` | Checks leaks & double frees; great for tests |
| Fixed upper bound; no syscalls | `FixedBufferAllocator` | Pre-sized buffer; predictability and zero failure surprises |
| High-throughput transient scratch | Stack/Temp arena per call | Keep lifetimes tight; no cross-frame sharing |
| Global fallback (rare) | `page_allocator` | Only for top-level bootstrapping or tiny demos |

### 🎨 Patterns

**💉 Always inject the allocator:**
```zig
pub fn init(alloc: std.mem.Allocator, opts: Options) !Self { ... }
```

**🔄 Clone with allocator (no hidden copies):**
```zig
pub fn dupString(alloc: std.mem.Allocator, s: []const u8) ![]u8 {
    const out = try alloc.alloc(u8, s.len);
    std.mem.copy(u8, out, s);
    return out;
}
```

**🧹 Cleanups on failure:**
```zig
var buf = try alloc.alloc(u8, n);
errdefer alloc.free(buf);
```

**🏟️ Arena lifetime for request/connection scopes:**
```zig
var arena = std.heap.ArenaAllocator.init(alloc);
defer arena.deinit();
const a = arena.allocator();
// allocate everything for this request with `a`, then drop at end
```


📝 **Rule of thumb:** Arena for bursts, GPA for correctness & tests, FixedBuffer when you know the ceiling.

## 🎯 Public API Design (0.16-friendly)

### 🏗️ Shape Your Types
```zig
pub const Client = struct {
    allocator: std.mem.Allocator,
    // private fields…

    pub const Options = struct {
        timeout_ms: u32 = 5_000,
        max_inflight: u32 = 4,
        // add more defaults here
    };

    pub fn init(alloc: std.mem.Allocator, opts: Options) !Client { ... }
    pub fn deinit(self: *Client) void { ... }
};
```

### 🎯 Keep Error Sets Small & Stable

Prefer named, minimal error sets and map internals into them:

```zig
pub const NetError = error{
    Timeout, Closed, ConnectionReset, Canceled, ResourceExhausted, Protocol,
};
pub fn call(...) NetError!void { ... }
```

### 🚫 No Hidden Allocation in "Getters"

If you must return owned data, take an allocator and document ownership:

```zig
pub fn readAll(self: *Reader, alloc: std.mem.Allocator) ![]u8 { ... }
```

### 📖 Use Reader/Writer When Streaming

Mirror std.io.Reader/Writer for composability; don’t expose raw sockets in your public API.

### 🔗 Interfaces via "vtables" (function-pointer structs)
```zig
pub const Transport = struct {
    openStream: fn (*Context) !Stream,
    close:      fn (*Context) void,
};
```

This keeps core packages transport-agnostic while adapters implement the table.

### ✍️ Naming & Style

Types UpperCamel, functions lowerCamel.

init/deinit, open/close, start/stop, read/write, begin/end pairs.

Avoid anytype in public APIs; pin generic params with comptime when needed.

## 🧪 Testing, Fuzzing, and Contracts

Unit tests co-located with code:

```zig
test "parses header" { ... }
```


Behavioral contracts: run the same suite against a mock and a real adapter (e.g., in-memory vs QUIC).

Golden traces: for protocol stacks, assert byte-exact frames.

Property tests (with GhostSpec or your harness): reorder/drop/inject to ensure no deadlocks/leaks.

CI must run with GPA leak checks on and fail on public API changes without a version bump.

## ⚡ Concurrency, Async, and Cancellation

Prefer structured concurrency: pass a Deadline/timeout, propagate Canceled.

Never block reactor threads with heavy CPU; add a worker thread or queue.

Use backpressure: explicit “budgets” (bytes/messages) enforced in core; adapters pause/resume reads.

## 📊 Logging & Observability

Emit machine-parsable logs (.jsonl); no printf soup.

Carry a trace id (uuid) through entrypoints; expose counters (success/error/latency buckets).

Make logging pluggable: accept an interface or function pointer for log(level, msg, fields).

## 🛠️ Build Systems & Feature Flags

### 🎚️ When to Use Modular Build Flags

Use flags when a feature:

Has heavy deps (crypto/h3), or

Is OS-specific (io_uring/kqueue), or

Changes code size materially, or

Is an adapter/backend (e.g., HTTP/3, QUIC).

### 💡 Examples

-Dio_uring=true|false

-Dkqueue=true|false

-Dhttp3=true|false

-Ddatagrams=true|false

-Dzstd=true|false

-Dmtls=true|false

### 📍 Where to Put Them

Transports/adapters (Ring 1) carry OS/network flags.

Core libraries (Ring 0/2) do not have OS/network flags—only codec toggles like -Dprotobuf/-Djson.

### 📋 When to Keep a Flat Build

Single-purpose apps/CLIs with minimal external deps.

Libraries where the conditional behavior is purely runtime (configuration, not code shape).

Early prototypes—add flags only when size/perf justification is clear.

### 🔧 build.zig Patterns

Minimal options surface:

```zig
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const http3 = b.option(bool, "http3", "Enable HTTP/3") orelse false;
    const datagrams = b.option(bool, "datagrams", "Enable QUIC datagrams") orelse true;

    const mod = b.addModule("mylib", .{
        .root_source_file = .{ .path = "src/lib.zig" },
        .target = target,
        .optimize = optimize,
    });

    const opts = b.addOptions();
    opts.addOption(bool, "http3", http3);
    opts.addOption(bool, "datagrams", datagrams);
    mod.addOptions("mylib-options", opts);
}
```


Consume in code:

```zig
const build_opts = @import("mylib-options");
comptime {
    if (build_opts.http3) @compileLog("HTTP/3 enabled");
}
```


Presets (documented only; no extra code):

-Dprofile=minimal → set flags for smallest build

-Dprofile=web → H3 on, datagrams on, zstd on

-Dprofile=enterprise → everything on

Keep defaults minimal for library consumers. Enable heavy features explicitly.

## 🏷️ Versioning & Stability

SemVer per package; bump minor when public error sets or exported symbols change.

Publish a manifest (YAML or build.zig.zon) pinning known-good versions across your stack.

Add an API guard CI step that diffs public symbols and fails on unannounced changes.

## ⚠️ FFI & Unsafe

Keep FFI behind a narrow, well-documented module (ffi/); convert to Zig types at the boundary.

Mark unsafes with a comment explaining why safe is impossible.

Zero hidden ownership transfer across FFI—document who frees.

## 🦴 Library Skeletons (Drop-in Templates)

### 🔄 Transport-agnostic Core + Adapter Seam
```zig
// core/transport.zig
pub const Stream = struct {
    writeFrame: fn (kind: u8, payload: []const u8) !void,
    readFrame:  fn (alloc: std.mem.Allocator) !Frame,
    cancel:     fn () void,
};
pub const Conn = struct { openStream: fn () !Stream, close: fn () void };
pub const Transport = struct { connect: fn (alloc: std.mem.Allocator, ep: []const u8) !Conn };
```

Adapter provides the functions, core never imports the transport.

### ⚙️ Init/deinit + Options Pattern
```zig
pub const Server = struct {
    alloc: std.mem.Allocator,
    // …
    pub const Options = struct {
        backlog: u32 = 128,
        deadline_ms: u32 = 30_000,
    };

    pub fn init(alloc: std.mem.Allocator, opts: Options) !Server { ... }
    pub fn deinit(self: *Server) void { ... }
};
```

## ✅ Practical Checklists

Before tagging a library release

 Public error sets reviewed (small & named)

 No hidden allocations in public APIs

 init/deinit parity & docs updated

 CI: unit + contract + leak checks pass

 README: 10-minute quickstart compiles cleanly

 CHANGELOG: breaking changes called out

Before enabling a new build flag

 Code size change measured

 Runtime perf impact measured

 Flag scoped to adapter/backends (not core)

 Default remains OFF (unless truly harmless)

## 🚨 Common Gotchas in Zig 0.16.0-dev

### 📋 ArrayList API Changes
Always construct with `init(alloc)` and `deinit()` it. Prefer `ArrayListUnmanaged` when you manage lifetime elsewhere.

### 💉 Allocator Propagation
Pass `alloc` all the way down—don't "regrab" `std.heap.page_allocator` inside helpers.

### 🚫 Avoid `catch unreachable`
Don't use it. Map to your public error set; keep `unreachable` for logic you truly proved impossible.

### ⚠️ Prevent `anyerror` Leakage
At your public boundary, narrow errors to a named set.

## 📝 TL;DR

- **💉 Inject allocators**, use arenas for bursty scopes
- **🎯 Keep public APIs** tiny, explicit, and allocation-free unless you're given one
- **🔧 Separate core logic** from OS/transport adapters; put build flags in adapters, not core
- **✅ Tests + contracts + small error sets** = stable, upgradable libraries
- **🎚️ Default builds** should be minimal; make heavy features opt-in

---

*This guide targets Zig 0.16.0-dev. Keep APIs small, memory explicit, and features modular for maintainable Zig code.*


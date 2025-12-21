# 🔄 Zig Async (0.16+): A Short, Practical Guide

**TL;DR:** Keep your public APIs sync-shaped, pass capability objects in (allocator and an Io), and treat suspension as an implementation detail. Zig is actively landing a new Io interface and std.io changes to support "colorless" async; design so you won't need to churn later.

## 1️⃣ Public API Shape (Stable)

### 🎯 Sync Surface, Async Inside
Expose normal functions that return `!T` or `!void`. Let implementations suspend internally. Don't leak frames/futures in public types. (Avoid "function coloring".)

### 🔗 Use Reader/Writer
Compose with `std.io.*`. Keep streaming via interfaces, not sockets/FDs. When needed, pass extra options (`deadline_ms`, `max_inflight`) explicitly.

### 🎯 Tiny Error Sets
Map transport/io errors into `error.{Timeout, Closed, ConnectionReset, Canceled, ResourceExhausted, Protocol}` and stick to them across adapters.

## 2️⃣ Pass Capabilities: Allocator and Io

**Pattern:** Accept an `Allocator` (today) and an `Io` handle (as Zig's new std lands). Treat `Io` like `Allocator`: a parameter you thread through. This future-proofs you against std.io's ongoing rewrite.

```zig
pub const Options = struct { deadline_ms: u32 = 5_000 };

pub fn fetch(alloc: std.mem.Allocator, io: *Io, opts: Options, req: Request)
    !Response
{
    // Implementation may suspend; callers don't care.
}
```


**💡 Migration Tip:** Until the new Io is in the release you target, keep a thin adapter layer so you can swap your event loop / runtime without touching APIs.

## 3️⃣ Cancellation, Deadlines, Backpressure

### ⏰ Deadlines
Always accept a deadline (monotonic ms or optional). Enforce in your core; translate to transport-specific cancellation (e.g., QUIC reset / socket cancel).

### 💰 Budgeted I/O
Track `max_inflight_bytes`/messages in core; adapters pause/resume reads. This avoids deadlocks and makes tests deterministic.

## 4️⃣ Blocking vs Non-blocking

### 🚫 Never Block the Reactor
If you must do blocking syscalls/CPU work, hand off to a worker thread/pool and integrate results back through your Io/event loop.

### 🛡️ One Path for Both
Keep a single code path that works with "sync today, async tomorrow" by isolating the actual wait points behind Io. (This is the migration sweet spot as std.io changes land.)

## 5️⃣ Tests You Need

### 🤝 Contract Tests
Run tests over two backends: an in-memory/mock Io and your real network Io. The same suite must pass on both.

### 🏆 Golden Traces
For protocol stacks (byte-for-byte frames).

### 🎲 Fuzz Testing
Fuzz the decoders (frames, headers) and property-test loss/reorder; no panics, bounded memory.

## 6️⃣ Build & Structure

### 🔧 Keep Async a Backend Choice
Core packages: no OS/runtime flags. Put OS/event-loop flags in transport/adapters (e.g., `-Dio_uring`, `-Dkqueue`) and heavy features (HTTP/3, zstd) there—not in core.

### 🎯 Minimal Defaults
Ship with async features off unless explicitly requested; document presets (minimal/web/enterprise).

## 7️⃣ Migration Notes (What's Changing in Zig 0.16.0-dev)

### 🔄 New Io Interface Coming
Zig 0.16.0-dev is introducing a new Io interface (passed like Allocator) and making breaking changes to std.io to support "colorless" async & better I/O composition. Target that shape now to minimize churn.

### 🔮 Async/Await Returns
There's active work around bringing back async/await ergonomics atop the new I/O model. Keep your APIs sync-shaped so you can adopt keywords/features later without breaking users.

### ⚠️ Key 0.16.0-dev Changes
- `std.io.Reader`/`Writer` interfaces are being redesigned
- New capability-based Io parameter pattern
- Potential return of async/await syntax
- Better integration with event loops
- Improved support for "colorless" async functions

## ✅ Copy-Paste Checklist

- ✅ Public APIs are sync-shaped (`!T`), no frames/futures exposed
- ✅ Accept `Allocator` and an `Io` handle (or a shim until Io lands)
- ✅ Deadlines + cancel are parameters, not globals
- ✅ `Reader`/`Writer` everywhere; no raw FDs in public types
- ✅ Tiny, stable error set; adapters map into it
- ✅ One contract test suite runs over mock Io and real Io
- ✅ Blocking work uses workers; reactor never blocks
- ✅ Async/OS flags live in adapters; core has codec/runtime-free flags only

---

*This guide targets Zig 0.16.0-dev and the upcoming std.io redesign. As the async story evolves, these patterns will keep your code forward-compatible.*

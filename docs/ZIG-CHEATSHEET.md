# Zig Cheatsheet

A compact reference for working with the Zig programming language (0.17.0-dev). Great for new users and cross-platform systems development.

---

## 🔧 Toolchain Setup

```bash
zig version                   # Check installed version
zig help                      # View help menu
```

---

## 📁 Project Structure

```bash
zig init-exe                  # Initialize an executable project
zig init-lib                  # Initialize a library project
```

---

## 🚀 Build & Run

```bash
zig build                     # Build project using build.zig
zig build run                 # Build and run executable
zig build test                # Run tests
```

---

## 🔨 Compilation Examples

```bash
zig build-exe main.zig        # Compile a standalone Zig source
zig build-lib lib.zig         # Compile Zig to a static/dynamic library
zig build-obj file.zig        # Emit an object file
```

---

## 🧪 Testing

```bash
zig test test.zig             # Run tests in a Zig source file
```

---

## 📦 Dependency Management

- Zig uses `build.zig.zon` for dependency resolution
- Use `zig fetch` to add dependencies automatically
- Dependencies are cached in the global cache

```bash
zig fetch --save https://github.com/user/repo/archive/main.tar.gz
```

```zig
// build.zig.zon
.{
    .name = "my-project",
    .version = "0.1.0",
    .dependencies = .{
        .example = .{
            .url = "https://github.com/user/example/archive/commit.tar.gz",
            .hash = "sha256:...",
        },
    },
}
```

---

## 🛠 Debugging & Analysis

```bash
zig build --verbose           # Show full build output
zig run file.zig              # Run a script directly
```

---

## 📁 Output Options

```bash
zig build-exe -O ReleaseSafe main.zig  # Safer release mode
zig build-exe -O ReleaseFast main.zig  # Fastest optimized build
```

---

## 📚 Documentation

- Official book: [https://ziglang.org/learn/](https://ziglang.org/learn/)
- Zig reference: [https://ziglang.org/documentation/master/](https://ziglang.org/documentation/master/)

---

## 🧼 Cleanup

```bash
rm -rf zig-out/                 # Remove build outputs manually
zion clean                      # zion dev tool - cleansup zig cache
```

---

## 🛠 Helpful Tips

- Use `@import("std")` for standard utilities
- Prefer `.zig.zon` for managing package metadata
- Check `build.zig` for custom build steps
- Use `std.ArrayList(T)` instead of `std.ArrayList(T, allocator)` (0.16.0+)
- Zig 0.17.0-dev includes continued std.io redesign and Io capability pattern
- Memory management is explicit - always handle allocations/deallocations

---

---

## Zig 0.16.0+ Breaking Changes

### ArrayList Changes
```zig
// Old (pre-0.16.0)
var list = std.ArrayList(i32).init(allocator);

// New (0.16.0+)
var list = std.ArrayList(i32).init(allocator);
// ArrayList API remains similar but some methods have changed
```

### Async/Await Removed
- **Async/await has been removed** from Zig 0.16.0
- Use explicit threading with `std.Thread`
- Consider event loops or cooperative multitasking patterns

```zig
// Use std.Thread for concurrency
const thread = try std.Thread.spawn(.{}, myFunction, .{});
thread.join();
```

### Other Notable Changes
- Improved error handling and diagnostics
- Better compile-time evaluation
- Enhanced cross-compilation support
- Updated standard library APIs

---

For more: [https://ziglang.org/](https://ziglang.org/) or try `man zig`


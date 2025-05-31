# Zig Cheatsheet

A compact reference for working with the Zig programming language. Great for new users and cross-platform systems development.

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
- You can also fetch packages via `zig fetch` or manually using `git`.

```zig
.{
    .name = "example",
    .url = "https://github.com/user/example/archive/commit.tar.gz",
    .hash = "sha256:...",
},
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
```

---

## 🛠 Helpful Tips

- Use `@import("std")` for standard utilities
- Prefer `.zig.zon` for managing package metadata
- Check `build.zig` for custom build steps

---

For more: [https://ziglang.org/](https://ziglang.org/) or try `man zig`


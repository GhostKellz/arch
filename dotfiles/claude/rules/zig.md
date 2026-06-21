---
paths:
  - "**/*.zig"
  - "**/build.zig.zon"
---

# Zig conventions

- Use Zig master (dev); std lib is at `/opt/zig-dev`.
- Use the built-in test runner and `zig fmt` to keep quality and style consistent.
- Pull dependencies with `zig fetch` and pin via the refs flag; never use local paths unless explicitly told.
- Use the build system's feature flags to enable/disable functionality and minimize binary size.
- For container runs, add Valgrind memory-leak auditing where applicable.

## Versioning (single source of truth = build.zig.zon)
1. Define `.version = "x.y.z"` in `build.zig.zon`.
2. In `build.zig`: `const build_zon = @import("build.zig.zon");` then expose via options:
   ```zig
   const options = b.addOptions();
   options.addOption([]const u8, "version", build_zon.version);
   // module import: .{ .name = "build_options", .module = options.createModule() }
   ```
3. In source: `const build_options = @import("build_options"); pub const VERSION = build_options.version;`
4. Never hardcode version strings in source, comments, or examples — always reference `VERSION`.

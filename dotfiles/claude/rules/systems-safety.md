---
paths:
  - "**/*.zig"
  - "**/*.rs"
  - "**/*.c"
  - "**/*.h"
  - "**/*.cpp"
  - "**/*.hpp"
---

# Systems safety (NASA Power-of-10, adapted)

For systems / low-level code (Zig, Rust, C/C++):

- Bound every loop with a fixed upper limit; no unbounded recursion.
- Minimize dynamic allocation after init; prefer fixed buffers or arenas and free deterministically.
- Check every fallible return — never silently discard errors (`try` / `?` / explicit handling; no ignored `Result`).
- Keep functions small (fit on one screen) and variable scope as narrow as possible.
- Assert preconditions and invariants at boundaries; validate all external input.
- Build clean: zero warnings (`-D warnings`, warning-free `zig build`).

---
paths:
  - "**/*.rs"
  - "**/Cargo.toml"
  - "**/Cargo.lock"
---

# Rust conventions

- Edition 2024 only (never 2021); Rust 1.90+ required.
- Before done: `cargo fmt`, `cargo clippy -- -D warnings`, `cargo test`.
- Use a workspace for multi-crate repos; share deps via `[workspace.dependencies]` and inherit with `version.workspace = true`.
- Version is single-source-of-truth in the workspace `Cargo.toml`; member crates inherit it. Never hardcode versions elsewhere.
- Gate optional functionality behind feature flags to keep builds lean.
- Use macros to cut real boilerplate — not to add cleverness.
- Audit dependencies with `cargo audit` / `cargo deny`; keep advisories clear or tracked under `docs/advisories/`.

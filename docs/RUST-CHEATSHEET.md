# Rust Cheatsheet

A minimal Rust reference guide for common workflows with `cargo`. Ideal for quick development cycles, CI hygiene, and clean formatting.

---

## 🔧 Setup & Formatting

```bash
rustup update                      # Update Rust toolchain
cargo fmt                         # Format code using rustfmt
```

---

## 🧪 Linting and Checking

```bash
cargo check                       # Syntax check, build-free validation
cargo clippy --all-targets --all-features -- -D warnings
                                  # Full Clippy lint pass, CI grade
```

---

## ✅ Running Tests

```bash
cargo test                        # Run all unit/integration tests
```

---

## 🚀 Build and Run

```bash
cargo build                       # Build in debug mode
cargo run                         # Compile and run main.rs
cargo build --release            # Optimized release build
```

---

## 📦 Dependency Management

```bash
cargo add <crate>                # Add a dependency (requires cargo-edit)
cargo rm <crate>                 # Remove a dependency
cargo upgrade                    # Upgrade all dependencies
```

---

## 🧪 Benchmarking & Examples

```bash
cargo bench                      # Run benchmarks (requires criterion)
cargo run --example <name>       # Run example from examples/
```

---

## 🧼 Cleaning

```bash
cargo clean                      # Remove target directory
```

---

## 🔧 Other Useful Commands

```bash
cargo doc --open                 # Build and open documentation
cargo tree                       # Show crate dependency tree
```

---

## 🛠 Helpful Tips

- Use `rust-analyzer` in your editor for advanced completions
- Consider enabling `#[deny(warnings)]` in `lib.rs`/`main.rs`
- Check `.cargo/config.toml` for project-specific overrides

---

For more: [https://doc.rust-lang.org/book/](https://doc.rust-lang.org/book/) or `man cargo`


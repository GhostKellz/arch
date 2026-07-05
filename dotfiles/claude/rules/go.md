---
paths:
  - "**/*.go"
  - "**/go.mod"
  - "**/go.sum"
---

# Go conventions

- Target the current stable Go (1.24+); set `go` directive in `go.mod` to match. Never a deprecated toolchain.
- Before done: `gofmt -l` (or `gofumpt`), `go vet ./...`, `go test ./...`. Wire `golangci-lint run` where the repo uses it.
- Check every `err` — an ignored error is a silent failure. Wrap with `%w` (`fmt.Errorf`); don't discard context.
- Pass `context.Context` through I/O boundaries with deadlines/cancellation; never store it in a struct.
- `exec.Command` with explicit args — never `sh -c` on untrusted input. Same for SQL: parameterized, never concatenated.
- Concurrency: no goroutine leaks (every one has a clear exit), bound channels, guard shared state (`-race` in test).
- Prefer the stdlib; add a dependency only when it earns its keep. `go mod tidy` before commit.
- Table-driven tests with subtests (`t.Run`); `t.Parallel()` where safe.
- Audit with `govulncheck ./...`; track anything unresolved under `docs/advisories/`.

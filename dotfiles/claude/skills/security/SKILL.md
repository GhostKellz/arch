---
name: security
description: Review your OWN code for vulnerabilities and design a fix — OWASP-style appsec plus LLM/agentic-AI risks and per-language footguns (Rust, Zig, Go, Python, TS/JS). Use when asked to security-review a change/PR, threat-model a feature, harden an endpoint or parser, check for injection / authz / secret-handling / SSRF / deserialization bugs, or review an LLM/tool-calling/MCP integration. Read-only analysis: it reports findings and proposes fixes, it does not run exploits. Triggers: "security review", "is this safe", "threat model this", "check for vulnerabilities", "harden this", reviewing auth/input-handling/agent code.
allowed-tools: Read, Grep, Glob
---

# Security review (own projects)

Defensive review of code we control, to ship it more securely. This skill
**reads and reasons** — it flags issues and proposes fixes; it does not run
exploits or offensive tooling (that's a separate, sandboxed, authorized-only
activity). In-house variant seeded from OWASP 2025 + LLM/agentic guidance,
kept lean and read-only.

## How to review
1. **Map the trust boundaries first.** Where does untrusted input enter (HTTP
   params/body/headers, CLI args, files, env, network, LLM output, other
   services)? Every boundary is a place to validate + encode.
2. **Follow the taint.** Trace untrusted data to every sink (SQL, shell, file
   path, HTML, deserializer, template, redirect, subprocess). Unvalidated flow
   = the bug.
3. **Rank by exploitability × blast radius**, not by count. Report the few that
   matter with `file:line`, the concrete attack, and the minimal fix. Don't
   drown a real RCE in style nits.
4. **Propose the smallest correct fix** — parameterize, encode at the sink,
   validate at the boundary, drop the privilege. Root cause, not a band-aid.

## OWASP-style checklist (web/API/service)
- **Injection** — SQL/NoSQL/OS-command/LDAP: parameterized queries / prepared
  statements; never string-concat untrusted input into a query, shell, or path.
- **Broken access control** — authorize every request server-side on the object
  *and* the action (IDOR: `/orders/{id}` must check ownership). Deny by default.
- **AuthN / session** — no home-rolled crypto; vetted password hashing (argon2/
  bcrypt/scrypt); secure/HttpOnly/SameSite cookies; rotate + expire tokens.
- **SSRF** — validate/allowlist outbound URLs; block link-local/metadata
  (`169.254.169.254`), internal ranges, and redirect-based bypasses.
- **Unsafe deserialization / parsers** — never turn untrusted bytes into rich
  objects (native object deserializers, unsafe YAML loaders, language gobs); use
  data-only formats and cap sizes.
- **Secrets** — none hardcoded; fetch at runtime (see the `secrets` skill);
  scan the diff before commit; keep them out of logs and error messages.
- **XXE / path traversal / open redirect** — disable external entities;
  canonicalize + confine paths to a base dir; allowlist redirect targets.
- **Crypto** — TLS for data in transit; AEAD (AES-GCM/ChaCha20-Poly1305);
  CSPRNG for anything security-bearing (see the `secrets` skill's generation).
- **Error handling** — fail closed; don't leak stack traces/internal detail to
  clients; log the detail server-side (a silent swallowed error is a security bug).
- **Dependencies** — audit the tree (`cargo audit`/`cargo deny`, `govulncheck`,
  `npm audit`, `pip-audit`); pin/lock; ties into `docs/advisories/` (repo-docs).

## LLM / agentic-AI risks (OWASP LLM Top 10, condensed)
Review any prompt/tool-calling/MCP/agent code for:
- **Prompt injection (LLM01)** — untrusted content (web pages, files, tool
  output, user text) can carry instructions. Never concatenate it into a
  privileged system prompt; keep a trust boundary between instructions and data.
- **Insecure output handling (LLM02)** — treat model output as untrusted:
  don't feed it to a shell/SQL/`eval` or render it unescaped. Validate first.
- **Excessive agency (LLM06)** — least-privilege tools; human-in-the-loop for
  destructive/irreversible actions; scope MCP/tool tokens read-only where able.
- **Sensitive-info disclosure (LLM07)** — the egress guardrail: secrets/client
  data a tool returns stay in-session; never persist/commit/hand to a vendor.
- **Supply chain (LLM03/05)** — vet models, skills, and MCP servers before use
  (see the `skill-audit` skill); pin sources.
- **Unbounded consumption (LLM10)** — rate-limit + cap tokens/tool-calls/loops;
  guard against runaway cost and recursive tool storms.

## Per-language footguns
- **Rust** — audit every `unsafe` block for the invariant it must uphold; no
  `.unwrap()`/`.expect()`/`panic!` on attacker-reachable paths (DoS); integer
  overflow in release (`wrapping_*`/`checked_*`); `Command` without a shell, args
  as a vector (no shell interpolation); validate at deserialization.
- **Zig** — allocator ownership + `errdefer` on every failable alloc; explicit
  bounds (no implicit slicing past length); handle every error (no swallowed
  `catch`); watch C-interop boundaries for lifetime/ownership mismatches.
- **Go** — check every `err` (an ignored error is a silent failure); `context`
  deadlines on all I/O; `exec.Command` with explicit args, never `sh -c` on
  untrusted input; guard goroutine leaks and unbounded channels.
- **Python** — don't `eval`/`exec` or run native-object/`yaml` loaders on
  untrusted data; `subprocess` with a list + `shell=False`; parameterized DB
  queries; the `secrets` module (not `random`) for tokens.
- **TS/JS** — no `eval`/`Function`/`child_process` on untrusted input; encode
  output to prevent XSS (framework escaping, CSP); prototype-pollution on merge/
  clone of untrusted objects; validate at the boundary (zod/…), not just types.

## Output format
Group findings by severity (Critical / High / Medium / Low), each with:
`file:line` · what an attacker does · the minimal fix. Note explicitly what you
checked and found clean, so the review reads as complete rather than a pile of
maybes. Skip theoretical issues that aren't reachable in this code.

## See also
- `skill-audit` — vetting third-party skills/MCPs before they run in-session.
- `secrets` — runtime secret fetch, generation entropy, leaked-secret scanning.
- `systems-safety` rule — NASA Power-of-10 for Rust/Zig/C/C++ (loads on those files).

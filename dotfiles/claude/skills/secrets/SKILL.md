---
name: secrets
description: Handle and protect secrets — GitHub/GitLab PATs, SSH key passphrases, sudo/server creds, API keys/tokens, .env values, private-brain-tier and Hudu client secrets. Fetch at runtime from the keyring (secret-tool / pass), never persist to plaintext, env-in-git, shell history, the public dotfiles mirror, or the tracked brain tier. Also scan for leaked/exposed secrets before committing (gitleaks/trufflehog) and use CI-native secret stores. Triggers: needing a credential, "scan for secrets", "check for exposed credentials", "find hardcoded keys/API keys", rotating secrets.
---

# Secrets handling

One rule everything else follows: **a secret is fetched at runtime from an
agent-guarded store, used in-session, and never persisted** — not to a plaintext
file, not to an env var that lands in git, not to shell history, not to the
public `~/arch` dotfiles mirror, not to the tracked (public) brain tier, and not
echoed back into chat.

## What counts as a secret
- On-prem creds for servers you SSH into, and **sudo passwords**.
- **GitHub / GitLab PATs**, deploy keys, SSH **key passphrases**.
- API keys / tokens (Cloudflare, SMTP, Hudu, etc.).
- Anything in a `.env`, or in the **private brain tier** (`~/brain/private/`).
- **Hudu** client secrets (passwords, asset configs) — see the `hudu` skill.

## Where secrets live (house layout)
| Situation | Store | Fetch |
|---|---|---|
| Workstation, desktop session (default) | Secret Service (gnome-keyring) | `secret-tool lookup …` |
| Headless / over SSH / want git-versioned | `pass` (GPG-backed) | `pass show …` |
| Client secrets | Hudu (MCP, OAuth-scoped) | via `hudu` skill |
| Notes that *reference* a secret | `~/brain/private/` (gitignored, local-only) | never pushed |
| One-off script / CI | `chmod 600` env file or CI secret store | env at runtime |

Deep reference lives in the brain: `[[Keyring]]` (secret-tool vs `pass`,
gpg-agent/ssh-agent, the choosing table). Don't duplicate it — read it if needed.

## Fetch at runtime — never inline the value
Resolve into a variable with a clear error if it's missing (the `gitlab.sh`
pattern), so nothing lands on disk or in history:

```bash
# store once (prompts — nothing on the command line / in history)
secret-tool store --label='GitLab CK-Arch' service gitlab account ck-arch

# resolve at runtime
TOKEN="${TOKEN:-$(secret-tool lookup service gitlab account ck-arch 2>/dev/null)}"
TOKEN="${TOKEN:?missing — run: secret-tool store … service gitlab account ck-arch}"
```

`pass` equivalent: `pass insert gitlab/ck-arch` then `pass show gitlab/ck-arch`.

## Generating a secret (enough entropy)
When you need to *mint* one, use cryptographic randomness — never a human-typed
string or a predictable pattern:
```bash
openssl rand -base64 32        # generic token / API secret
openssl rand -hex 32           # hex form
pwgen -s 32 1                  # random password
ssh-keygen -t ed25519 -a 64 -f ./key   # keypair (passphrase-protect it)
```
Pipe straight into the store (`… | secret-tool store …` / `pass insert`) so the
value never sits in a file or in history.

## Never do
- No `export TOKEN=…` in `.zshrc`/dotfiles that get mirrored to `~/arch`.
- No secret pasted into a Bash command that lands in shell history or logs, and
  none echoed back into this transcript.
- No committing a `.env`; confirm it's gitignored before any `git add`.
- No copying a fetched secret into the public brain tier or the `~/arch` mirror.
- No caching a value "for later" — see rotation.

## Rotation reality
Secrets/passwords rotate every few months. So:
- Always fetch **fresh**; never hardcode or cache a past value.
- If auth suddenly fails, assume it rotated — re-pull the current value from the
  store (and update the consuming MCP/config), don't debug it as a code bug.
- Rotating is a single re-`store` / `pass insert` — the consumer picks up the new
  value with no code change.

When a secret has **multiple consumers**, rotate zero-downtime (don't revoke
first and cause an outage): mint the new value → update every consumer/MCP/config
to it → verify they authenticate → *then* revoke the old one. On any suspected
leak, skip the graceful path — revoke immediately and treat it as compromised.

## Egress guardrail (mirrors `~/.claude/CLAUDE.md`)
Anything a secret-bearing tool or MCP returns is **read-only, in-session**
context. It must NEVER flow outward: no commits, no push to the public mirror or
tracked brain tier, no memory/mempalace capture, no hand-off to Codex or other
vendors, no scratch files. Pull the minimum, use it, don't persist it. If unsure
whether surfacing a secret is warranted, stop and ask.

## Scanning for leaked secrets
Before any commit/push — especially to the public `~/arch` mirror or the tracked
brain tier — scan for secrets that slipped in:
- Preferred tools (pattern + entropy): `gitleaks detect --no-banner` (staged-only:
  `gitleaks protect --staged`) or `trufflehog filesystem .` / `trufflehog git file://.`.
- Fallback when neither is installed — the grep reflex used all session:
  ```bash
  grep -rnE 'AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{36}|glpat-[A-Za-z0-9_-]{20}|-----BEGIN [A-Z ]*PRIVATE KEY|(password|api[_-]?key|secret|token)\s*=\s*[^ $]' .
  ```
- Wire it as a **pre-commit hook** so it can't be forgotten.
- On a hit: the secret is compromised → **rotate/revoke it**, then scrub history
  (`git filter-repo`), not just delete the line.

## In CI/CD (their stack — not Vault/cloud)
Secrets belong in the platform's own store, never in the repo:
- **GitHub Actions:** repo / org / environment **Secrets**; reference
  `${{ secrets.X }}`; `echo "::add-mask::$V"` for anything derived at runtime;
  never `echo` a secret to logs.
- **GitLab CI:** **masked + protected** CI/CD variables (protected = protected
  branches only; file-type for certs/kubeconfigs).
- **Skip** HashiCorp Vault, AWS Secrets Manager, Azure Key Vault, GCP Secret
  Manager, K8s External-Secrets/CSI, envelope encryption (KEK/DEK), and
  zero-knowledge schemes — not the current stack; don't scaffold them
  speculatively. Revisit only if one is actually adopted.

## See also
- `hudu` skill — client secrets via the Hudu MCP (same egress rule).
- `acme` skill — TLS cert private keys are secrets too (issuance/renewal).
- `ssh` skill — remote host creds + sudo over a PTY.
- brain `[[Keyring]]` / `[[Secure Agent Access]]` — the deep references.

# Global Working Agreement (Codex)

Durable defaults for OpenAI Codex. Keep this file lean: specific stack knowledge
belongs in Codex skills or repo-local `AGENTS.md`.

## Workflow

- Read the relevant files before editing.
- Keep changes scoped to the requested behavior.
- Prefer existing repo conventions over new abstractions.
- For non-trivial work, state the approach before broad edits.
- If evidence contradicts the plan, stop and re-plan.

## Verification

- Do not call work done without proof.
- Run the smallest meaningful test first, then broader checks when risk warrants.
- For CI changes, mirror the CI command locally when practical.
- For frontend work, verify rendered behavior, not just compilation.

## Git

- Never rewrite history unless explicitly asked.
- Do not stage unrelated files.
- Do not commit secrets, generated state, caches, or local machine files.
- Commit messages should explain why, not only what.

## Security

- Fetch secrets at runtime from approved stores such as `secret-tool`, `pass`, or
  CI-native secret variables.
- Never put plaintext credentials in commands, docs, approval rules, or chat.
- Treat any plaintext credential in a Codex rule as exposed and rotate it.
- Use least-privilege command approvals.

## Codex Config

- Codex command approval rules are machine-local and must not be mirrored.
- `auth.json`, SQLite state, logs, sessions, caches, and shell snapshots are
  private runtime state.
- Keep portable skills/plugins secret-free and suitable for this dotfiles mirror.

## Relationship to Claude

Claude and Codex share the same engineering standards, but not the same config
format. Claude skills are source material; Codex skills should be written
Codex-native and kept compact.

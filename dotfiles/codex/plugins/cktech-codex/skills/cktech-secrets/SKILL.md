---
name: cktech-secrets
description: Handle CKTech secrets safely in Codex. Use for credentials, API tokens, SSH key passphrases, sudo passwords, CI/CD variables, .env values, Hudu/client secrets, secret scanning, leak response, and rotation. Fetch secrets at runtime; never persist, echo, commit, or place plaintext values into Codex rules or approval commands.
---

# CKTech Secrets

- Fetch secrets at runtime from `secret-tool`, `pass`, Hudu, or CI-native secret stores.
- Never put secrets in commands, approval rules, tracked files, public brain notes, or chat.
- Treat plaintext credentials in `~/.codex/rules/default.rules` as exposed and rotate them.
- Before commits touching config/auth/deploy paths, scan with the repo's existing secret scanner if present.
- If a secret is missing, ask the user to store it; do not invent placeholders that might be committed.

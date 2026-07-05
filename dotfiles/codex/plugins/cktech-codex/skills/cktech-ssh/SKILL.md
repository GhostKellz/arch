---
name: cktech-ssh
description: Use for CKTech SSH, SCP, rsync, remote sudo, server access, homelab VM, Tailscale, Proxmox SDN, or login debugging. Prefer key-based auth with explicit options, diagnose local SSH config first, and avoid sshpass/plaintext-password approval rules.
---

# CKTech SSH

Baseline probe:

```bash
ssh -F /dev/null -i /home/chris/.ssh/id_ed25519 -o IdentitiesOnly=yes -o BatchMode=yes -o ConnectTimeout=8 -o StrictHostKeyChecking=accept-new user@host 'hostname; id'
```

- Use the same option discipline for `scp` and `rsync -e`.
- For sudo, prefer key auth plus PTY; if a password is required, fetch from a secret store and pass through stdin only.
- Never use `sshpass -p ...` or add password-bearing approval rules.
- Check Tailscale/DNS/reachability before blaming credentials.

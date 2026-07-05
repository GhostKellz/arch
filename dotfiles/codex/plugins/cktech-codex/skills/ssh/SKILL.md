---
name: ssh
description: Use this skill for any SSH, SCP, rsync, remote sudo, server access, homelab VM, Tailscale, Proxmox SDN, or "can you log into this box" task. Prefer key-based auth with explicit SSH options, diagnose the local SSH method before blaming remote credentials, and handle password/sudo prompts deliberately.
---

# SSH Handling

Use this skill whenever you need to reach a remote host, copy files, inspect a service, or run sudo remotely.

The default assumption is: **the user's host and credentials are probably fine; your SSH method may be wrong.** Verify methodically before saying the server, password, or key is bad.

## Core Pattern

Prefer key-based auth first, with a clean SSH config:

```bash
ssh -F /dev/null \
  -i /home/chris/.ssh/id_ed25519 \
  -o IdentitiesOnly=yes \
  -o BatchMode=yes \
  -o ConnectTimeout=8 \
  -o StrictHostKeyChecking=accept-new \
  user@host 'hostname; id'
```

Why:
- `-F /dev/null` bypasses broken local client config.
- `IdentitiesOnly=yes` prevents trying a pile of wrong keys.
- `BatchMode=yes` makes key-auth failures explicit instead of hanging.
- `ConnectTimeout=8` keeps exploration tight.
- `StrictHostKeyChecking=accept-new` handles first contact without disabling host-key safety entirely.

If this succeeds, keep using the same option set for follow-up commands.

## Known Local SSH Trap

On this workstation, a bad local SSH config has previously broken otherwise-valid access:

```text
/etc/ssh/ssh_config.d/20-systemd-ssh-proxy.conf
```

Symptoms can look like wrong credentials or a broken remote host. Bypass local config with `-F /dev/null` before concluding that.

## Known Hosts Trap

`~/.ssh/known_hosts` on this workstation has previously accumulated junk lines (e.g. `getaddrinfo echo: Name or service not known` stderr appended by a broken tool). When that happens, `ssh-keygen -R host` prints the removal but then **refuses to write the file** ("not a valid known_hosts file. Not replacing existing known_hosts file because of errors") — so the stale key silently survives and the host-key mismatch persists.

Fix: filter the file explicitly, verify, then replace:

```bash
grep -v -e '^STALE_IP ' -e '^getaddrinfo ' ~/.ssh/known_hosts > ~/.ssh/known_hosts.clean
chmod 600 ~/.ssh/known_hosts.clean && mv ~/.ssh/known_hosts.clean ~/.ssh/known_hosts
ssh-keygen -F STALE_IP   # must return nothing
```

A host-key-changed warning right after the user re-staged a VM on a reused IP is expected — clean the entry and continue; do not treat it as MITM in that context.

## Connection Triage

When SSH fails, classify the failure:

```bash
ssh -F /dev/null -i /home/chris/.ssh/id_ed25519 \
  -o IdentitiesOnly=yes \
  -o BatchMode=yes \
  -o ConnectTimeout=8 \
  -o StrictHostKeyChecking=accept-new \
  user@host 'hostname; id'
```

Interpretation:
- `Permission denied (publickey)` means key auth failed for that user/host.
- `Connection timed out` means routing/firewall/listener path, not credentials.
- `No route to host` means routing/VPN/SDN path.
- `Connection refused` means the host is reachable but SSH is not listening or firewall actively rejected it.
- Host-key warnings mean host identity state changed; stop and report before overriding.

If key auth fails and the user provided a password, test password auth explicitly instead of guessing:

```bash
ssh -F /dev/null \
  -o PreferredAuthentications=password,keyboard-interactive \
  -o PubkeyAuthentication=no \
  -o ConnectTimeout=8 \
  -o StrictHostKeyChecking=accept-new \
  user@host 'hostname; id'
```

If an interactive prompt is required, allocate a TTY:

```bash
ssh -tt -F /dev/null \
  -o PreferredAuthentications=password,keyboard-interactive \
  -o PubkeyAuthentication=no \
  -o ConnectTimeout=8 \
  -o StrictHostKeyChecking=accept-new \
  user@host
```

Do not claim the password is wrong until you have tried the correct auth mode and checked local SSH config bypass.

## Remote Sudo

Use sudo deliberately. If sudo can read stdin on the remote host, this pattern is concise:

```bash
ssh -F /dev/null \
  -i /home/chris/.ssh/id_ed25519 \
  -o IdentitiesOnly=yes \
  -o ConnectTimeout=8 \
  -o StrictHostKeyChecking=accept-new \
  user@host 'printf "%s\n" "PASSWORD" | sudo -S sh -c "hostname; id; systemctl status service --no-pager"'
```

**Critical failure signature:** if `sudo -S` over a non-PTY session returns `Authentication failed, try again` even with the correct password, the PAM stack likely requires a real TTY. This looks exactly like a wrong password but is not. Do NOT blame the password after one failed `sudo -S` attempt — switch method first.

The proven one-shot pattern (verified working on Ubuntu hosts here): pipe the password into `ssh -tt` so sudo reads it through the allocated PTY:

```bash
printf '%s\n' 'PASSWORD' | ssh -tt -F /dev/null \
  -i /home/chris/.ssh/id_ed25519 \
  -o IdentitiesOnly=yes \
  -o ConnectTimeout=8 \
  -o StrictHostKeyChecking=accept-new \
  user@host 'sudo -S -p "" -k whoami; echo status:$?'
```

Notes:
- `-tt` forces PTY allocation even with piped stdin (single `-t` is not enough).
- `-p ""` suppresses the prompt; `-k` forces a fresh authentication so the test is unambiguous.
- Drop `BatchMode=yes` when using `-tt` with piped input.
- Validate with `sudo -k whoami` first; only then run the real command chain, e.g. `'cd /path && sudo -S -p "" ./script.sh && sudo systemctl status foo --no-pager'` (later sudos reuse the cached credential).

Do not keep retrying the same failed sudo pattern. Change the method.

## Copying Files

Use the same SSH options with `scp`:

```bash
scp -F /dev/null \
  -i /home/chris/.ssh/id_ed25519 \
  -o IdentitiesOnly=yes \
  -o ConnectTimeout=8 \
  -o StrictHostKeyChecking=accept-new \
  local-file user@host:/remote/path
```

For directories or repeat syncs, prefer `rsync`:

```bash
rsync -az \
  -e 'ssh -F /dev/null -i /home/chris/.ssh/id_ed25519 -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new' \
  ./local-dir/ user@host:/remote/dir/
```

## Quoting Rules

Keep remote commands simple. Prefer single quotes around the remote command and double quotes inside:

```bash
ssh ... user@host 'docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"'
```

For complex multi-step work:
- Prefer copying a small script to the remote host and running it.
- Avoid fragile nested quote piles.
- Avoid here-docs unless absolutely necessary.

For passwords containing an exclamation mark, wrap the password in single
quotes so the shell keeps it literal (double quotes in an interactive bash can
trigger history expansion):

```bash
'ExamplePw1!'   # placeholder — keep real passwords in pass/secret-tool, not here
```

Do not misdiagnose the exclamation mark as history expansion unless you are actually in an interactive shell where history expansion is enabled.

## Verification Checklist

Before saying "done" on remote work:

- Confirm identity:
  ```bash
  hostname; id
  ```
- Confirm target service state:
  ```bash
  systemctl status name --no-pager
  docker ps
  ```
- Confirm the externally relevant endpoint from the expected source host:
  ```bash
  curl -i http://host:port/_ping
  ```
- If changing firewall/network behavior, test both allowed and denied behavior when possible.
- Report exact host, path, service, and verification result.

## Failure Discipline

Do not say:
- "The credentials are wrong" after one failed attempt.
- "The server is down" without checking route, port, and auth mode.
- "SSH is broken" without trying `-F /dev/null`.

Do say:
- "Key auth failed for this user/host; password auth has not been tested yet."
- "The TCP path is failing before authentication."
- "Sudo requires a TTY; switching to an interactive sudo validation pattern."

## Common CKTech Pattern

For the user's homelab and CKTech hosts, the usual first attempt is:

```bash
ssh -F /dev/null \
  -i /home/chris/.ssh/id_ed25519 \
  -o IdentitiesOnly=yes \
  -o BatchMode=yes \
  -o ConnectTimeout=8 \
  -o StrictHostKeyChecking=accept-new \
  USER@IP 'hostname; id'
```

Then escalate only if needed. Keep host-specific credentials out of committed files and summaries.

## Host-specific references

Per-host access details (runner hosts, service names, key paths) are kept out of this
skill body. Read the machine/cluster inventory on demand when a task targets a specific
host: `~/.claude/reference/infrastructure.md`. For hosts whose sudo requires a real TTY,
apply the PTY `printf ... | ssh -tt ... 'sudo -S -p "" -k ...'` pattern above — a non-PTY
`sudo -S` failure there is a method problem, not a wrong password.

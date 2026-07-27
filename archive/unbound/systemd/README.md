# Unbound Systemd Service and Timer 🌟

> **GhostKellz Networking Stack** — Resilient. Private. Tuned for Performance.

---

# 📅 Purpose

This directory contains the **systemd** service and timer for keeping **Unbound**'s root hints file (`root.hints`) fresh and updated **automatically**.

- Ensures your Unbound resolver always has the latest list of root DNS servers.
- Enhances DNSSEC validation reliability.
- Hardens your local DNS infrastructure against stale records or outages.

---

# 📂 Folder Layout

| File | Purpose |
|:-----|:--------|
| `update-root-hints.service` | Systemd service unit to update `root.hints` |
| `update-root-hints.timer` | Systemd timer to run the service daily |

---

# ⚙️ Service Details

### `update-root-hints.service`

- **Description:**
  - Downloads the latest root hints from [internic.net](https://www.internic.net/domain/named.cache).
  - Overwrites `/var/lib/unbound/root.hints`.
  - Restarts the `unbound` service immediately after updating.

- **ExecStart Command:**
```bash
wget -O /var/lib/unbound/root.hints https://www.internic.net/domain/named.cache && systemctl restart unbound
```

- **Run User:**
  - `root` (requires permission to restart Unbound and write to `/var/lib/unbound/`)

### `update-root-hints.timer`

- **Schedule:**
  - Executes **daily** at **03:00 AM**.
  - Ensures minimum disruption and up-to-date root information.

- **Timer Type:**
  - `OnCalendar=daily`

---

# 🔧 Installation

1. Copy the files into `/etc/systemd/system/`:
```bash
sudo cp update-root-hints.service /etc/systemd/system/
sudo cp update-root-hints.timer /etc/systemd/system/
```

2. Enable and start the timer:
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now update-root-hints.timer
```

3. Check timer status:
```bash
systemctl list-timers | grep update-root-hints
```

---

# 🚧 Troubleshooting

| Problem | Solution |
|:--------|:---------|
| Root hints not updating | Ensure `wget` is installed. Test manual command first. |
| Timer not firing | Run `systemctl daemon-reload` and re-enable the timer. |
| Unbound fails to restart | Check `/var/log/unbound/unbound.log` for hints. Validate `root.hints` file integrity. |
| Permissions error | Ensure `update-root-hints.service` runs as `root` and `/var/lib/unbound/` is writable. |

**Manual Force Update Command:**
```bash
sudo systemctl start update-root-hints.service
```

---

# 🚀 Why This Matters

Without updated root hints:
- DNSSEC trust chains can break.
- Queries may fail or be slower.
- Your system is vulnerable to outdated resolver behavior.

This service guarantees that **GhostKellz Infrastructure** remains **secure, reliable, and fast**. ✨

> 👻 Stay verified. Stay resilient. — GhostKellz Networking Stack


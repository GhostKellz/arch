---
name: cktech-systemd
description: Write and debug CKTech systemd services, timers, sockets, drop-ins, and socket-proxyd units. Use for service ordering, Requires/After, restart policy, bind timing, daemon-reload, journal inspection, and host-native integrations.
---

# CKTech systemd

- Use unit/drop-in files deliberately; run `systemctl daemon-reload` after changes.
- Inspect with `systemctl status`, `journalctl -u`, and `systemctl cat`.
- For sockets, verify both `.socket` and `.service` units.
- Be explicit about `Requires=`, `After=`, restart behavior, users/groups, and bind addresses.
- Avoid broad root services when a scoped user/service account works.

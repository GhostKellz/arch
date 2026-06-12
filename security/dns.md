# DNS infrastructure

Internal split-horizon DNS, hardened so every client resolves through a filtered
resolver and nothing is allowed to bypass it (enforced at the FortiGate — see
[`fortigate.md`](fortigate.md)).

## Resolvers

**Primary — Technitium + unbound** (`10.0.0.2`, group `CKEL-DNS-SERVERS`)
- Technitium is the front-end / authoritative + filtering resolver clients point at.
- unbound sits behind it as the validating recursive resolver (DNSSEC, root hints).
- Serves internal zones and recursion for the estate.

**Backup — PiHole + unbound** (secondary)
- PiHole front-end (ad/tracker + blocklist filtering) with unbound behind it for
  recursion, mirroring the primary's model so failover keeps both filtering and
  validation.
- Listed in the `CKEL-DNS-SERVERS` group alongside the primary.

## Enforcement (FortiGate)

- `DNS Servers Outbound (15)` — only the resolver hosts may send outbound DNS.
- `Block unauthorized DNS (16)` — denies DNS egress from any other host; clients cannot
  use their own resolver or public DoH/DoT to bypass filtering.
- `CK-Arch DNS Tools (36)` — admin workstation may reach root name servers for diagnostics.

Net effect: every lookup on the network goes through Technitium (or the PiHole backup),
both of which filter, so the FortiGate web filter and the DNS-layer blocklists reinforce
each other.

## Clients

- Workstations/servers point at `10.0.0.2` (Technitium) with the PiHole backup as
  secondary.
- **ck-arch workstation:** points at the internal resolvers via NetworkManager
  (`ipv4.dns 10.0.0.2`). It **no longer runs a local unbound instance** — recursion is
  handled upstream by the resolver hosts. Local firewalling on the workstation is
  **nftables** (see [`../networking/nftables.md`](../networking/nftables.md)).

## Notes

- unbound now lives **only on the dedicated resolver hosts** (primary + backup), not on
  the Arch workstation. The legacy workstation unbound config under
  `../networking/unbound/` is retained for reference only and is no longer deployed on
  ck-arch.

# FortiGate 90G — edge security architecture

Perimeter firewall for the cktech estate. FortiGate 90G, FortiOS 7.4.12, LAN gateway
`10.0.0.1`. Default-deny in both directions; traffic is filtered in layers before it
ever reaches a host.

## SD-WAN / WAN

Internet uses the SD-WAN zone `wan-failover-link` (members `wan1` + `port2`), with
load-balancing / failover across the two uplinks:

| Member | Interface IP | Gateway | Role |
|--------|--------------|---------|------|
| `wan1`  | *(Fidium public /23)* | *(Fidium gw)* | **Fidium 2.5 GbE fiber — primary** (~6 ms) |
| `port2` | *(Comcast public /23)* | *(Comcast gw)* | **Comcast cable — backup** (~40 ms) |

- The `wan2` port was repurposed into the `lan` software switch (so the LAN side gets a
  2.5 GbE uplink); `lan` (`10.0.0.1/24`) bundles `wan2 + port1 + port3 + port4`.
- A second SD-WAN zone `virtual-wan-link` also exists (default).
- **SD-WAN SLA / health checks:** `Fidium` probe (ping the fiber gateway, tight thresholds
  15 ms / 5 ms jitter / 2% loss) drives the fiber-primary decision; generic probes
  (Cloudflare `1.1.1.1`, `Default_DNS` `10.0.0.2`, Google DNS `8.8.8.8`) at 35/10/25.
  Failed SLA withdraws the static route so traffic rolls to cable.

SD-WAN rules prefer fiber and fail over to cable, so DNS, the CrowdSec feed pull, and
published services survive a single-circuit outage. A **standby generator** backs the
whole house, so the edge stays up through power loss (UPS bridges the gap).

## VLAN segmentation

All segments are `/24` with the **VLAN ID = 3rd octet**, gateway `.1`, on the FortiGate.
Inter-VLAN routing is policy-controlled (default-deny; explicit allow per need).

| VLAN | Subnet | Purpose |
|------|--------|---------|
| `lan`   | `10.0.0.0/24`  | Primary home/core net (software switch, 2.5 GbE) |
| `WAP10` | `10.0.10.0/24` | Wireless APs / WiFi clients |
| `PVE20` | `10.0.20.0/24` | Proxmox lab |
| `DMZ30` | `10.0.30.0/24` | DMZ — thallium public-facing (see `dmz.md`) |
| `LAB40` | `10.0.40.0/24` | Lab; a `LAB-40F` FortiGate feeds 2 Hyper-V hosts |
| `GIA50` | `10.0.50.0/24` | Guest WiFi (isolated) |
| `IOT60` | `10.0.60.0/24` | IoT devices |
| `DEV70` | `10.0.70.0/24` | Dev |

## Inbound posture (to published services)

Default-deny. An inbound connection to a published service (DMZ30 / nginx) must clear,
in order:

1. **Geo allowlist (default-deny by country)** — `GEO-IP-ALLOWED` address group permits
   **only**: United States, Canada, Denmark, Sweden, Ireland, Switzerland, Japan,
   United Kingdom, France, Germany. Any other source country is dropped. `Allow
   Cloudflare` permits CF ranges in front of the proxied services.
2. **IP threat feeds** — known-bad IPs are dropped even from allowed countries (see feed
   list below). Policy `Block Lists (25)`.
3. **Scanner feeds** — `Blocked Services (26)`.
4. **SSL/TLS full deep inspection** — decrypts so the L7 engines see real payloads.
5. **App Control (L7) → IPS** on the inspected flow.
6. Reaches the published service (`NGINX (8)` — geo-allowed HTTPS to nginx).

## Outbound posture (client egress)

`DNS forced through Technitium → App Control (L7) → IPS → Web Filtering → SD-WAN`.
Per-VLAN egress policies (`DMZ30/LAB40/GIA50/IOT60/DEV70 Internet`) route out the
SD-WAN zone.

## External threat feeds (consumed locally)

The 90G pulls these as external IP threat feeds and applies them as block lists:

**Reputation / C2 / malware**
- Crowdsec Threat Feed *(self-hosted — see [`crowdsec/threatfeed.md`](crowdsec/threatfeed.md))*
- C2 All, Cobalt Strike IP
- ELLIO Community Threat Feed
- Emerging Threats, Emerging Threats Compromised, Emerging Threats IP
- GreenSnow Block List, log4j
- Tor Exit Nodes, TOR Feeds
- AlienVault Critical, BadGuys List

**Scanner feeds (Blocked Services)**
- CriminalIP, Cyber.Casa, Hadrian, Internet.Census.Group, InterneTTL, LeakIX,
  Malicious.Server, NetScout, ONYPHE, Phishing.Server, Rapid7, Recyber, Shadowserver,
  Shodan, Stretchoid, Tenable.io.Cloud, UK.NCSC

**Geo**
- `GEO-IP-ALLOWED` (allowlist, above), `Allow Cloudflare`

## UTM / security profiles

Policies run **full SSL/TLS deep inspection** (not cert-only) so L7 engines see
decrypted traffic.

- **Application Control (L7):** per-zone profiles —
  - `block-high-risk` — drops high-risk app categories
  - `CKEL` / `CKEL-STRICT` / `CKEL-GUEST` — monitor/allow scaled by trust level
  - `default`, `wifi-default` (WiFi offload)
- **IPS (Intrusion Prevention):** signature-based exploit/attack blocking on inspected
  flows.
- **Web Filtering:** category/URL filtering on egress, paired with the forced-DNS posture
  (DNS resolved only through the filtered Technitium resolver; web filter enforces at
  HTTP/S).

## DNS control (enforced at the edge)

All clients are forced through the internal **Technitium** resolver (`CKEL-DNS-SERVERS`):

- `DNS Servers Outbound (15)` — only the Technitium server(s) may send outbound DNS.
- `Block unauthorized DNS (16)` — denies DNS egress from every other host, so no client
  can bypass Technitium with its own resolver / public DoH/DoT.
- `CK-Arch DNS Tools (36)` — admin workstation may reach root name servers for diagnostics.

Full DNS infrastructure (Technitium + unbound primary, PiHole + unbound backup) is in
[`dns.md`](dns.md).

## Remote management

**Tailscale only** — no WAN-exposed RDP/SSH. Servers, the CrowdSec engine, and the
thallium mirror are reached over the tailnet (`100.64.0.0/10`). See
[`../networking/tailscale.md`](../networking/tailscale.md).

## Public exposure

A single mini-PC (**thallium**) in a DMZ segment (DMZ30) is the only public-facing host,
locked down so a compromise can't pivot into the LAN. See [`dmz.md`](dmz.md).

## Layered summary

```
                         ┌───────────────────────── FortiGate 90G ─────────────────────────┐
 INBOUND  ── geo allowlist (10 countries) → threat feeds → scanner feeds → SSL deep
            inspect → App Control (L7) → IPS → published service (DMZ30/nginx)
 OUTBOUND ── forced DNS (Technitium) → App Control (L7) → IPS → Web Filter → SD-WAN
            (fiber primary / cable backup)
 MGMT     ── Tailscale only
                         └──────────────────────────────────────────────────────────────────┘
```

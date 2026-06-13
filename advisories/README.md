# Security Advisories & Incident Reviews

Archive of security incidents, supply-chain / dependency reviews, CVE writeups, and the
detection checks we ran for each. Distinct from `~/arch/security/`, which holds defensive
*setup* (CrowdSec, FortiGate, DMZ, DNS).

## Layout

| Dir | Purpose |
|-----|---------|
| `incidents/` | Supply-chain compromises, breaches, mass-malware events + our scan results |
| `cve/` | Individual CVE writeups and the local mitigation we applied |
| `checks/` | Reusable detection scripts / IOC scanners, kept for re-runs |

## Incidents

| Date | Incident | Severity | Affected? | Doc |
|------|----------|----------|-----------|-----|
| 2026-06-11 | AUR supply-chain — "Atomic Arch" (atomic-lockfile / js-digest) | CVSS 8.7 | No | [incidents/2026-06-11-aur-atomic-arch.md](incidents/2026-06-11-aur-atomic-arch.md) |

## CVEs

| CVE | Component | Severity | Mitigated? | Doc |
|-----|-----------|----------|------------|-----|
| CVE-2026-34982 | Vim/Neovim modeline RCE | CVSS 8.2 | Yes | [cve/cve-2026-34982-vim-modeline.md](cve/cve-2026-34982-vim-modeline.md) |

## Checks

| Script | Use |
|--------|-----|
| [checks/aur-atomic-arch-scan.sh](checks/aur-atomic-arch-scan.sh) | Scan a host for Atomic Arch AUR IOCs (re-runnable) |

# Badge palette & templates

House style: `style=for-the-badge`, `logoColor=white` (use `black` on light
colours like Linux yellow / Alpine), brand-hex colour per tech, 6–9 badges per
`<p align="center">` block. **Tech only — no CI/build/coverage/status badges.**

## Primary block (copy, then fill real tech)
```markdown
<p align="center">
  <img src="https://img.shields.io/badge/<LANGUAGE>-<HEX>?style=for-the-badge&logo=<slug>&logoColor=white" alt="<LANGUAGE>">
  <img src="https://img.shields.io/badge/<FRAMEWORK>-<HEX>?style=for-the-badge&logo=<slug>&logoColor=white" alt="<FRAMEWORK>">
  <img src="https://img.shields.io/badge/<DATABASE>-<HEX>?style=for-the-badge&logo=<slug>&logoColor=white" alt="<DATABASE>">
  <img src="https://img.shields.io/badge/<CACHE_OR_RUNTIME>-<HEX>?style=for-the-badge&logo=<slug>&logoColor=white" alt="<CACHE_OR_RUNTIME>">
  <img src="https://img.shields.io/badge/<STYLING>-<HEX>?style=for-the-badge&logo=<slug>&logoColor=white" alt="<STYLING>">
  <img src="https://img.shields.io/badge/<DEPLOYMENT>-<HEX>?style=for-the-badge&logo=<slug>&logoColor=white" alt="<DEPLOYMENT>">
</p>
```

## Optional second block — libraries / features / quality / license
```markdown
<p align="center">
  <img src="https://img.shields.io/badge/<LIBRARY>-<HEX>?style=for-the-badge" alt="<LIBRARY>">
  <img src="https://img.shields.io/badge/<FEATURE_OR_QUALITY>-<HEX>?style=for-the-badge" alt="<FEATURE>">
  <img src="https://img.shields.io/badge/License-<SPDX>-<HEX>?style=for-the-badge" alt="License">
</p>
```

Badges may be wrapped in `<a href="…">` links (nvcontrol/strix do; others don't) —
optional. `nvcontrol` uses the `[![alt](url)](link)` markdown form with
`.svg?style=for-the-badge`; both render identically.

## Colour + logo reference (verified from the repos)
| Tech | Hex | logo slug |
|------|-----|-----------|
| Go | `00ADD8` | `go` |
| Rust | `B7410E` (or orange `FF6B1B`) | `rust` |
| TypeScript | `3178C6` | `typescript` |
| Zig | `F7A41D` | `zig` |
| Python | `3776AB` | `python` |
| SvelteKit | `FF3E00` | `svelte` |
| Astro | `BC52EE` | `astro` |
| Leptos | `0D89D4` | `webassembly` |
| Alpine.js | `8BC0D0` | `alpinedotjs` (logoColor=black) |
| Tailwind CSS | `06B6D4` | `tailwindcss` |
| PostgreSQL | `4169E1` | `postgresql` |
| Redis | `DC382D` | `redis` |
| SQLite | `003B57` | `sqlite` |
| Docker | `2496ED` | `docker` |
| Linux | `FCC624` | `linux` (logoColor=black) |
| Arch Linux | `1793D1` | `arch-linux` |
| Wayland | `1793D1` | `wayland` |
| NVIDIA | `76B900` | `nvidia` |
| Proxmox | `E57000` | `proxmox` |
| Btrfs | `8A2BE2` | `linux` |
| Chromium | `4285F4` | `googlechrome` |
| Tokio | `4E5EE4` | (none) |
| chi (Go router) | `00ADD8` | (none) |
| pgx | `4169E1` | (none) |
| Ollama / custom | `111111` | (none) |
| OIDC | `7C3AED` | (none) |
| License MIT | `blue`/`0078D4` | (none) |
| License AGPLv3 | `green`/`008000` | (none) |
| License FSL-1.1-ALv2 | `A21CAF` | (none) |

For a tech not listed: use its official brand colour and the shields.io `logo=`
slug from simpleicons.org; fall back to a solid colour with no logo if none exists.

## Selection rules
- Order: language → key framework/runtime → database → cache/session → styling → deployment.
- Keep 6–9 per block; split into a second block rather than overflowing one line.
- Represent **important dependencies and the real stack**, not every transitive dep.
- Never: build/CI, coverage, "maintained", version-from-CI, downloads, project-status.

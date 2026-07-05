---
paths:
  - "**/*.nix"
  - "**/flake.nix"
  - "**/flake.lock"
---

# Nix conventions

- Flakes only — no channels, no `nix-env`. Pin inputs in `flake.lock`; bump deliberately with `nix flake update` (or a single input).
- Before done: `nix flake check` and `nix fmt` (alejandra or nixfmt-rfc-style — match the repo's formatter).
- Dev environments are `devShells` consumed via `nix develop` (wire `direnv` + `use flake` for auto-activation). Don't install dev tooling globally.
- Keep derivations reproducible: no impure builds, no network in build phases, no unpinned `fetch*` (always a hash/`rev`).
- Prefer `pkgs.mkShell`/`buildEnv` composition over ad-hoc scripts; keep expressions declarative and one concern per file.
- On Arch-primary hosts Nix is for dev shells/packaging, not system management — don't reach for NixOS modules unless the target is actually NixOS.
- Cache-friendly: rely on `cache.nixos.org`; add a project binary cache only when builds are genuinely heavy.

---
name: cktech-hudu
description: Use self-hosted Hudu at hudu.cktechx.com from Codex via MCP. Trigger when the user asks for client documentation, client assets, passwords/secrets, procedures, MSP runbooks, Hudu search/update work, or moving patterns between Hudu and the Obsidian brain. Enforces that Hudu is the client-confidential source of truth and must not leak into the public brain.
---

# CKTech Hudu

## Model

Hudu is self-hosted at `hudu.cktechx.com`.

It is the client-confidential system of record for:

- client companies,
- assets and configurations,
- passwords and secrets,
- procedures and runbooks,
- client-specific M365/infra/security documentation.

Hudu is separate from the Obsidian brain:

- `~/brain/wiki/` -> public/general knowledge, published at `brain.ckelley.dev`.
- `~/brain/private/` -> local-only personal/home-lab/security notes.
- Hudu -> client-confidential MSP documentation and secrets.

## Access

Prefer the native Hudu MCP over ad hoc API scripts.

Preferred transport:

- Streamable HTTP MCP endpoint from Hudu.
- OAuth auth.
- No API key in config files.

Use API-key fallback only if the native MCP is insufficient and the user explicitly approves.

## Safety Rules

- Do not copy client-specific Hudu data into `~/brain/wiki/`.
- Do not paste passwords, API keys, tenant secrets, or client identifiers into chat or files.
- Do not write Hudu secrets to shell history, Codex rules, repo docs, or public notes.
- When creating generalized brain notes from Hudu context, remove client names, hostnames, IPs, tenant IDs, diagrams, and identifying details.
- If the user asks for a reusable pattern, file the pattern in the brain and keep the client specifics in Hudu.

## Workflow

For Hudu-backed work:

1. Identify the client/company or asset scope.
2. Query Hudu through MCP.
3. Summarize only the minimum needed context.
4. Draft changes with clear target object/page/procedure.
5. Ask before write/update actions unless the user explicitly requested the update.
6. If a lesson is reusable, generalize it into the appropriate brain tier without client identifiers.

## Boundary Examples

Good public-brain note:

- "How to structure a FortiGate firmware upgrade checklist."

Keep in Hudu:

- "Client X FortiGate serial, WAN IP, admin URL, backup password, and exact change window."

Good private-brain note:

- "My home-lab Wazuh/Grafana integration gotcha."

Keep in Hudu:

- "Client Y Wazuh manager endpoint, enrolled agents, and tenant-specific response runbook."

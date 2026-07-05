# Skill audit findings

Read-on-demand record of third-party skills evaluated for adoption, with the
verdict and rationale for each. Methodology lives in the `skill-audit` skill;
this is the decision log so choices aren't re-litigated. Verdicts use that
skill's matrix: **adopt verbatim / author-fresh variant / sandbox-only / reject**.

## Security & OWASP

| Skill | Source | License | Tools | Verdict | Why |
|---|---|---|---|---|---|
| `claude-code-owasp` | agamm | permissive-unclear | Read/Grep/Glob | **author-fresh** | Content clean and genuinely useful (OWASP 2025 + LLM01–10 + agentic/MCP risks + per-language quirks Rust/Go/Py/TS). Read-only, no exfil/injection. License not crisp → re-author lean in-house rather than copy verbatim. |
| `threat-modeling` (STRIDE) | dralgorhythm/claude-agentic-framework | — | none | additive | Clean, no tool grants. STRIDE prompts are additive; fold the useful bits into the in-house security skill rather than adopting five separate overlapping skills. |
| `security-review` | dralgorhythm | — | none | redundant | Overlaps agamm's review coverage; skip as a separate skill. |
| `application-security` | dralgorhythm | — | none | redundant | 2021-era, overlaps the above. Skip. |
| `identity-access` | dralgorhythm | — | none | additive-niche | Clean; keep only if an IAM task actually comes up. |
| `compliance` | dralgorhythm | — | none | niche | SOC2/compliance framing — not current need. Skip. |
| `secskills` (16 offensive skills) | trilwu | — | Bash+Read+Write+Grep+Glob+WebFetch, **PROACTIVE** | **sandbox-only** | Prose is content-clean (HackTricks-style enumeration, no covert exfil/injection). But six sub-agents grant Bash proactively and skills ship ready-to-run backdoor/persistence/reverse-shell commands. High structural risk — isolated, non-privileged use only; never in the always-on set. |

**Action taken:** author one lean in-house **security** skill seeded from
agamm's OWASP 2025 + LLM/agentic material + language quirks, read-only tools,
house style. Do not import trilwu; if authorized pentest work is needed, run it
sandboxed.

## GitLab & IaC

| Skill | Source | License | Verdict | Why |
|---|---|---|---|---|
| `gitlab-*` skill set (21) | `gitlab-org/ai/skills` | MIT | **adopt (selective)** | Official, MIT, supersedes third-party. Wins: `glab`, `gitlab-pipeline-watch` (clean `scripts/pipeline-watch.py`, `subprocess.run(["glab","api",…])`), `gitlab-babysit-mr` (3 clean bash scripts). |
| `claude-glab-skill` | henricook | MIT | redundant | Good reference but overlaps the official `glab` skill. Author one lean in-house glab skill instead (hardcode the self-hosted instance). |
| `gitlab-ci-patterns` | Microck/ordinary-claude-skills | MIT | reject/redundant | Overlaps `rules/ci.md`; uses deprecated `only:` syntax. Keep CI policy in the rule, not a skill. |
| `terraform-skill` | antonbabenko | Apache-2.0 | **adopt verbatim** | 2100+ stars, clean, no tool grants. Gold-standard Terraform guidance. Adopt with attribution. |

Note: "TheBushidoCollective GitLab CI/CD Best Practices" was a **misattribution** —
that org publishes `gh`/GitHub-CLI skills, not the referenced GitLab skill. No
reputable Zig / nftables / Proxmox skills found in the scour.

**Action taken (planned):** one lean in-house `glab` CLI skill (self-hosted
instance hardcoded, GLQL passthrough, `glab api` pagination + message-escaping
gotchas); adopt official `gitlab-pipeline-watch` + `gitlab-babysit-mr` verbatim
(attributed, scripts vendored, different activation); keep CI policy in
`rules/ci.md`; adopt `terraform-skill` (Apache-2.0) or re-author lean.

## Secrets-management marketplace skills (evaluated, mostly rejected)

Three enterprise "secrets management" skills were reviewed for ideas only
(scanning-for-secrets; a Vault/AWS/Azure/GCP CI-CD skill; melodic-software's
enterprise one with Vault engines, KEK/DEK envelope encryption, zero-knowledge,
K8s CSI). **Verdict: author-fresh, extract-only.** Kept the stack-relevant
pieces — entropy generation, zero-downtime rotation ordering, gitleaks/trufflehog
scanning, GitHub Actions `::add-mask::` + GitLab masked/protected variables — and
folded them into the in-house `secrets` skill. Explicitly **skipped** Vault, the
cloud secret managers, K8s External-Secrets/CSI, and envelope/zero-knowledge
schemes as off-stack; the `secrets` skill documents that skip so it isn't
scaffolded speculatively later.

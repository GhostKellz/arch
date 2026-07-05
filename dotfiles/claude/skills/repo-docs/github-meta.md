# .github/ meta templates

Copy these into `.github/`, then adapt the domain-specific fields (env inputs,
the `dropdown` options, the support/diagnostics commands, the ecosystems).

## ISSUE_TEMPLATE/bug_report.yml
Modern **form schema** (not legacy markdown). Adapt the env `input`s and the
`dropdown` to the project's domain.
```yaml
name: Bug report
description: Report a regression, runtime failure, packaging problem, or hardware-specific issue.
title: "[bug] "
labels:
  - bug
body:
  - type: markdown
    attributes:
      value: |
        Before filing, include diagnostics / a support bundle when possible.
        ```bash
        <project> doctor --support --output ~/.local/state/<project>/support.tar.gz
        ```
  - type: textarea
    id: summary
    attributes:
      label: Summary
      description: What is broken?
    validations:
      required: true
  - type: textarea
    id: repro
    attributes:
      label: Steps to reproduce
      placeholder: |
        1. Run ...
        2. Observe ...
    validations:
      required: true
  - type: textarea
    id: expected
    attributes:
      label: Expected behavior
    validations:
      required: true
  - type: textarea
    id: actual
    attributes:
      label: Actual behavior
    validations:
      required: true
  - type: input
    id: version
    attributes:
      label: Version
      placeholder: <project> 0.1.0
    validations:
      required: true
  - type: input
    id: distro
    attributes:
      label: Distribution / OS
      placeholder: Arch Linux / Ubuntu 24.04
    validations:
      required: true
  - type: dropdown
    id: area
    attributes:
      label: Area
      options:
        - install / packaging
        - runtime
        - networking
        - storage
        - security
        - docs
    validations:
      required: true
  - type: textarea
    id: diagnostics
    attributes:
      label: Diagnostics and attachments
      description: Paste key output; mention any attached support bundle.
  - type: textarea
    id: changes
    attributes:
      label: What changed before this started?
      placeholder: |
        - package upgrade
        - config change
        - resumed from suspend
```

## ISSUE_TEMPLATE/feature_request.yml
```yaml
name: Feature request
description: Suggest a new capability, workflow improvement, or support enhancement.
title: "[feature] "
labels:
  - enhancement
body:
  - type: textarea
    id: problem
    attributes:
      label: Problem statement
      description: What problem are you trying to solve?
    validations:
      required: true
  - type: textarea
    id: proposal
    attributes:
      label: Proposed behavior
      description: Describe the feature or workflow you want.
    validations:
      required: true
  - type: textarea
    id: context
    attributes:
      label: Context
      description: Hardware/software/deployment context if relevant.
  - type: textarea
    id: alternatives
    attributes:
      label: Alternatives considered
      description: Workarounds or existing commands you already tried.
```

## ISSUE_TEMPLATE/config.yml
```yaml
blank_issues_enabled: true
contact_links:
  - name: Support / diagnostics workflow
    url: https://github.com/<owner>/<repo>/blob/main/docs/support.md
    about: Run the support-bundle + diagnostics steps before filing runtime, packaging, or security issues.
```

## dependabot.yml
`version: 2`, one entry per ecosystem actually present, weekly, grouped, and
**`update-types: [minor, patch]` only** (major is reviewed by hand). Always keep
a `github-actions` entry — it's what stops workflows drifting onto deprecated
action versions.
```yaml
version: 2
updates:
  - package-ecosystem: "cargo"        # or gomod / npm — one block per ecosystem
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
    groups:
      cargo-minor-and-patch:
        patterns:
          - "*"
        update-types:
          - "minor"
          - "patch"

  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
    groups:
      github-actions:
        patterns:
          - "*"
```
Multi-stack variants: add a `gomod` block at `/backend` + an `npm` block at
`/frontend` (nexus), or extra `cargo` blocks per workspace crate + a `docker`
block at the deploy dir (strix). Secondary workspaces use a lower
`open-pull-requests-limit` (5).

## Self-hosted GitHub Actions runners — version hygiene
When editing workflows for a self-hosted runner, verify action versions are
current before committing (this is routinely gotten wrong):
```bash
# what major versions exist for an action
gh api repos/actions/checkout/releases --jq '.[].tag_name' | head
```
- Pin to the latest major (`actions/checkout@v5`, `actions/setup-*@vN`); don't
  copy an old `@v3`/`@v2` from memory.
- `runs-on:` matches the runner's registered labels (`[self-hosted, linux, x64]`),
  not `ubuntu-latest`.
- The `github-actions` dependabot group above keeps these from going stale.

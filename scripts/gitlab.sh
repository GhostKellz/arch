#!/usr/bin/env zsh
set -euo pipefail

# Create a CK Technology GitLab repository with the same baseline quality as
# the GitHub bootstrap scripts: full license text, useful docs, security policy,
# advisory tracking, and language-aware initialization.
#
# GitLab token lookup:
#   secret-tool store --label='GitLab CK-Arch' service gitlab account ck-arch
#
# Environment overrides:
#   GITLAB_TOKEN       Personal access token for project creation API
#   GITLAB_HOST        Defaults to git.cktechx.com
#   GITLAB_NAMESPACE   Optional numeric namespace_id for GitLab groups
#   BASE_DIR           Defaults to /data/projects

GITLAB_HOST="${GITLAB_HOST:-git.cktechx.com}"
BASE_DIR="${BASE_DIR:-/data/projects}"
NAMESPACE_PATH="${GITLAB_NAMESPACE:-}"
GITLAB_TOKEN="${GITLAB_TOKEN:-$(secret-tool lookup service gitlab account ck-arch 2>/dev/null || true)}"
GITLAB_TOKEN="${GITLAB_TOKEN:?No token - run: secret-tool store --label='GitLab CK-Arch' service gitlab account ck-arch}"

echo -n "Enter new CKTech GitLab repo name: "
read repo
repo="${repo:l}"

echo -n "One-line description: "
read description
[[ -z "$description" ]] && description="One-line description of $repo."

echo -n "Project language (rust/go/zig/python/js/node/bun/none): "
read lang
lang="${lang:l}"

echo -n "License (mit/apache/proprietary/fsl): "
read license
license="${license:l}"
[[ -z "$license" ]] && license="mit"

echo -n "Make repository private? (y/n): "
read private_input
[[ "$private_input" =~ ^[Yy]$ ]] && visibility="private" || visibility="public"

echo -n "Create GitLab CI stub? (y/n): "
read ci_input

echo -n "Add GitLab topics? (comma-separated, or leave blank): "
read topics

owner="CK Technology LLC"

render() {
  local output="$1"
  local content
  content=$(cat)
  content=${content//__REPO__/$repo}
  content=${content//__DESCRIPTION__/$description}
  content=${content//__OWNER__/$owner}
  content=${content//__GITLAB_HOST__/$GITLAB_HOST}
  print -r -- "$content" > "$output"
}

license_label() {
  case "$license" in
    apache) print -r -- "Apache-2.0" ;;
    proprietary) print -r -- "Proprietary" ;;
    fsl) print -r -- "FSL-1.1-ALv2" ;;
    *) print -r -- "MIT" ;;
  esac
}

license_badge() {
  case "$license" in
    apache) print -r -- "Apache--2.0-blue" ;;
    proprietary) print -r -- "Proprietary-111827" ;;
    fsl) print -r -- "FSL--1.1--ALv2-A21CAF" ;;
    *) print -r -- "MIT-blue" ;;
  esac
}

repo_url_path() {
  if [[ -n "$NAMESPACE_PATH" ]]; then
    print -r -- "$repo"
  else
    print -r -- "$repo"
  fi
}

if [[ -e "$BASE_DIR/$repo" ]]; then
  echo "Refusing to overwrite existing path: $BASE_DIR/$repo" >&2
  exit 1
fi

mkdir -p "$BASE_DIR/$repo"
cd "$BASE_DIR/$repo"

write_license() {
  case "$license" in
    apache)
      if [[ -f /data/scripts/APACHE2.0-LICENSE ]]; then
        cp /data/scripts/APACHE2.0-LICENSE LICENSE
      else
        render LICENSE <<'TEMPLATE_EOF'
Apache License
Version 2.0, January 2004
http://www.apache.org/licenses/

Copyright 2026 __OWNER__

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0
TEMPLATE_EOF
      fi
      ;;
    proprietary)
      render LICENSE <<'TEMPLATE_EOF'
Proprietary License

Copyright (c) 2026 __OWNER__

All rights reserved.

This software and associated documentation files (the "Software") are the
confidential and proprietary property of __OWNER__. Unauthorized copying,
modification, distribution, sublicensing, or use of the Software is prohibited
except as expressly permitted by a written agreement with __OWNER__.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND NONINFRINGEMENT.
TEMPLATE_EOF
      ;;
    fsl)
      render LICENSE <<'TEMPLATE_EOF'
Functional Source License, Version 1.1, ALv2 Future License

## Abbreviation

FSL-1.1-ALv2

## Notice

Copyright 2026 __OWNER__

## Terms and Conditions

### Licensor ("We")

The party offering the Software under these Terms and Conditions.

### The Software

The "Software" is each version of the software that we make available under
these Terms and Conditions, as indicated by our inclusion of these Terms and
Conditions with the Software.

### License Grant

Subject to your compliance with this License Grant and the Patents,
Redistribution and Trademark clauses below, we hereby grant you the right to
use, copy, modify, create derivative works, publicly perform, publicly display
and redistribute the Software for any Permitted Purpose identified below.

### Permitted Purpose

A Permitted Purpose is any purpose other than a Competing Use. A Competing Use
means making the Software available to others in a commercial product or
service that:

1. substitutes for the Software;
2. substitutes for any other product or service we offer using the Software
   that exists as of the date we make the Software available; or
3. offers the same or substantially similar functionality as the Software.

Permitted Purposes specifically include using the Software:

1. for your internal use and access;
2. for non-commercial education;
3. for non-commercial research; and
4. in connection with professional services that you provide to a licensee
   using the Software in accordance with these Terms and Conditions.

### Patents

To the extent your use for a Permitted Purpose would necessarily infringe our
patents, the license grant above includes a license under our patents. If you
make a claim against any party that the Software infringes or contributes to
the infringement of any patent, then your patent license to the Software ends
immediately.

### Redistribution

The Terms and Conditions apply to all copies, modifications and derivatives of
the Software.

If you redistribute any copies, modifications or derivatives of the Software,
you must include a copy of or a link to these Terms and Conditions and not
remove any copyright notices provided in or with the Software.

### Disclaimer

THE SOFTWARE IS PROVIDED "AS IS" AND WITHOUT WARRANTIES OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING WITHOUT LIMITATION WARRANTIES OF FITNESS FOR A PARTICULAR
PURPOSE, MERCHANTABILITY, TITLE OR NON-INFRINGEMENT.

IN NO EVENT WILL WE HAVE ANY LIABILITY TO YOU ARISING OUT OF OR RELATED TO THE
SOFTWARE, INCLUDING INDIRECT, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES,
EVEN IF WE HAVE BEEN INFORMED OF THEIR POSSIBILITY IN ADVANCE.

### Trademarks

Except for displaying the License Details and identifying us as the origin of
the Software, you have no right under these Terms and Conditions to use our
trademarks, trade names, service marks or product names.

## Grant of Future License

We hereby irrevocably grant you an additional license to use the Software under
the Apache License, Version 2.0 that is effective on the second anniversary of
the date we make the Software available. On or after that date, you may use the
Software under the Apache License, Version 2.0, in which case the following
will apply:

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License.

You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.
TEMPLATE_EOF
      ;;
    mit|*)
      render LICENSE <<'TEMPLATE_EOF'
MIT License

Copyright (c) 2026 __OWNER__

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
TEMPLATE_EOF
      ;;
  esac
}

write_gitignore() {
  case "$lang" in
    rust)
      cat > .gitignore <<'EOF'
# Rust
/target
**/*.rs.bk
EOF
      ;;
    go)
      cat > .gitignore <<'EOF'
# Go
/bin/
*.exe
*.test
*.out
vendor/
go.work.sum
EOF
      ;;
    zig)
      cat > .gitignore <<'EOF'
# Zig
.zig-cache/
zig-out/
zig-pkg/
*.o
*.exe
EOF
      ;;
    python)
      cat > .gitignore <<'EOF'
# Python
__pycache__/
*.pyc
*.pyo
*.pyd
.venv/
env/
venv/
dist/
build/
*.egg-info/
EOF
      ;;
    js|node|bun)
      cat > .gitignore <<'EOF'
# Node / Bun
node_modules/
dist/
build/
coverage/
*.log
npm-debug.log*
yarn-error.log
.env
.env.local
EOF
      ;;
    *)
      : > .gitignore
      ;;
  esac

  cat >> .gitignore <<'EOF'

# Local workflow / scratch
.env
.env.*
!.env.example
CLAUDE.md
archive/
tasks/

# Editor / OS
.vscode/
.idea/
*.swp
*.swo
.DS_Store
Thumbs.db
EOF
}

initialize_language() {
  case "$lang" in
    rust)
      cargo init --bin --name "$repo" .
      ;;
    go)
      go mod init "git.${GITLAB_HOST#git.}/$repo" || true
      mkdir -p cmd/"$repo"
      cat > cmd/"$repo"/main.go <<EOF
package main

import "fmt"

func main() {
	fmt.Println("$repo")
}
EOF
      ;;
    zig)
      cat > build.zig <<'EOF'
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "app",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe);
}
EOF
      mkdir -p src
      cat > src/main.zig <<'EOF'
const std = @import("std");

pub fn main() !void {
    try std.io.getStdOut().writer().print("hello\n", .{});
}
EOF
      ;;
    python)
      mkdir -p src/"$repo"
      touch src/"$repo"/__init__.py
      cat > pyproject.toml <<EOF
[project]
name = "$repo"
version = "0.1.0"
description = "$description"
requires-python = ">=3.11"

[build-system]
requires = ["setuptools>=68"]
build-backend = "setuptools.build_meta"
EOF
      ;;
    js|node)
      cat > package.json <<EOF
{
  "name": "$repo",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "test": "node --test"
  }
}
EOF
      ;;
    bun)
      cat > package.json <<EOF
{
  "name": "$repo",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "test": "bun test"
  }
}
EOF
      ;;
    none|*)
      ;;
  esac
}

write_docs() {
  mkdir -p docs/advisories docs/development tasks
  : > tasks/todo.md

  render README.md <<'TEMPLATE_EOF'
<h1 align="center">__REPO__</h1>

<p align="center">
  <strong>__DESCRIPTION__</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/License-__LICENSE_BADGE__?style=for-the-badge" alt="License">
</p>

---

## Overview

__DESCRIPTION__

## Status

Early development.

## Quick Start

```bash
# Add project-specific setup here.
```

## Documentation

Full documentation lives in [docs/](docs/README.md).

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Security

To report a vulnerability, see [SECURITY.md](SECURITY.md).

## License

Licensed under __LICENSE_LABEL__ - see [LICENSE](LICENSE).
TEMPLATE_EOF
  perl -0pi -e "s/__LICENSE_LABEL__/$(license_label)/g; s/__LICENSE_BADGE__/$(license_badge)/g" README.md

  render docs/README.md <<'TEMPLATE_EOF'
# __REPO__ Documentation

__DESCRIPTION__

## Documentation Map

```mermaid
flowchart TD
    Start["Start here"] --> Readme["../README.md"]
    Start --> Changelog["../CHANGELOG.md"]
    Start --> Dev["development/roadmap.md"]
    Start --> Adv["advisories/README.md"]
    Adv --> Deps["advisories/dependencies.md"]
    Adv --> Accepted["advisories/accepted.md"]
    Adv --> Resolved["advisories/resolved.md"]
```

## Current Surface

- Early repository scaffold
- Language-specific initialization
- Standard security, contributing, license, and advisory files

## Directory Structure

```text
docs/
├── README.md
├── advisories/
│   ├── README.md
│   ├── dependencies.md
│   ├── accepted.md
│   └── resolved.md
└── development/
    └── roadmap.md
```

## Conventions

- One concept per page.
- Filenames are lowercase and hyphenated.
- Mermaid diagrams are used where they clarify structure or flow.
- Docs should describe implemented behavior; planned work should be labeled.
TEMPLATE_EOF

  render CONTRIBUTING.md <<'TEMPLATE_EOF'
# Contributing To __REPO__

## Overview

Thanks for your interest in contributing to __REPO__.

## Development Setup

```bash
git clone git@__GITLAB_HOST__:__REPO__.git
cd __REPO__
```

Run the project-specific formatter, tests, and linters before opening a merge
request.

## Workflow

- Keep changes focused.
- Use Conventional Commits.
- Add tests for behavior changes.
- Update docs under `docs/` for user-visible changes.

```bash
git checkout -b feat/my-change
git commit -m "feat: describe change"
```

## Documentation Style

- Root `README.md` is the overview and quick start.
- `docs/README.md` is the single docs index.
- Topic files are lowercase and hyphenated.
- Advisory records live under `docs/advisories/`.

## Security

- Never commit secrets.
- Do not log credentials.
- Do not add hidden network behavior.
- Report vulnerabilities privately through [SECURITY.md](SECURITY.md).
TEMPLATE_EOF

  render SECURITY.md <<'TEMPLATE_EOF'
# Security Policy

## Reporting A Vulnerability

Do not open public GitLab issues for security vulnerabilities.

Report privately to CK Technology maintainers. Include:

- vulnerability description and impact
- reproduction steps or proof of concept
- affected component and commit/version
- suggested remediation, if known

## Supported Versions

__REPO__ is pre-1.0. Only the default branch receives security fixes.

| Version | Supported |
|---------|-----------|
| `main` | yes |
| older tags | no |

## Disclosure Policy

We follow coordinated disclosure. Please allow a reasonable window to ship a fix
before public discussion.

## Baseline Rules

- No secrets in the repository.
- No credentials in logs.
- `.env` files are ignored by default.
- Security advisory decisions are tracked in `docs/advisories/`.
TEMPLATE_EOF

  render CHANGELOG.md <<'TEMPLATE_EOF'
# Changelog

All notable changes to __REPO__ are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project scaffold.

<!--
On release, copy the [Unreleased] entries under a new dated heading, e.g.:

  ## [1.0.0] - 2026-07-05

Then reset [Unreleased] to empty groups and add a link reference at the bottom:

  [1.0.0]: https://__GITLAB_HOST__/ghostkellz/__REPO__/-/tags/v1.0.0

Change groups (in this order; omit any that are empty):
  Added       new features
  Changed     changes in existing functionality
  Deprecated  soon-to-be removed features
  Removed     now-removed features
  Fixed       bug fixes
  Security    vulnerability fixes

Semantic Versioning - given MAJOR.MINOR.PATCH, increment the:
  MAJOR  for incompatible API changes
  MINOR  for backward-compatible new functionality
  PATCH  for backward-compatible bug fixes
-->

[Unreleased]: https://__GITLAB_HOST__/ghostkellz/__REPO__/-/commits/main
TEMPLATE_EOF

  render docs/development/roadmap.md <<'TEMPLATE_EOF'
# Development Roadmap

## Current Status

Early repository scaffold.

## Next

- Define project scope.
- Add build and validation commands.
- Add CI jobs.
- Expand documentation for implemented behavior.
TEMPLATE_EOF

  render docs/advisories/README.md <<'TEMPLATE_EOF'
# Advisories

This section tracks dependency and security advisory decisions.

## Contents

- [Dependencies](dependencies.md)
- [Accepted](accepted.md)
- [Resolved](resolved.md)

## Triage Workflow

```mermaid
flowchart TD
    Found["advisory found"] --> Reachable{"reachable?"}
    Reachable -- no --> Accept["document in accepted.md"]
    Reachable -- yes --> Fixable{"fix available?"}
    Fixable -- yes --> Patch["upgrade or patch"]
    Patch --> Verify["test and rescan"]
    Verify --> Resolve["document in resolved.md"]
    Fixable -- no --> Mitigate["mitigate or pin"]
    Mitigate --> Accept
```
TEMPLATE_EOF

  render docs/advisories/dependencies.md <<'TEMPLATE_EOF'
# Dependency Inventory

Record dependencies, scanner output, and audit notes here.

## Current Status

Initial scaffold. Add project-specific dependency inventory once dependencies are
introduced.
TEMPLATE_EOF

  render docs/advisories/accepted.md <<'TEMPLATE_EOF'
# Accepted Advisories

Security advisories or dependency risks that are knowingly accepted.

| Advisory | Package | Severity | Rationale | Review date |
|----------|---------|----------|-----------|-------------|
| _(none)_ | | | | |
TEMPLATE_EOF

  render docs/advisories/resolved.md <<'TEMPLATE_EOF'
# Resolved Advisories

Security advisories that have been remediated.

| Advisory | Package | Issue | Resolved by | Date |
|----------|---------|-------|-------------|------|
| _(none)_ | | | | |
TEMPLATE_EOF
}

write_ci() {
  if [[ ! "$ci_input" =~ ^[Yy]$ ]]; then
    return
  fi

  case "$lang" in
    rust)
      cat > .gitlab-ci.yml <<'EOF'
stages:
  - test

test:
  image: rust:latest
  stage: test
  script:
    - cargo fmt --all -- --check
    - cargo test --workspace
EOF
      ;;
    go)
      cat > .gitlab-ci.yml <<'EOF'
stages:
  - test

test:
  image: golang:latest
  stage: test
  script:
    - go test ./...
EOF
      ;;
    *)
      cat > .gitlab-ci.yml <<'EOF'
stages:
  - test

test:
  stage: test
  script:
    - echo "Add project validation commands"
EOF
      ;;
  esac
}

write_license
write_gitignore
initialize_language
write_docs
write_ci

git init
git branch -M main
git add .
git commit -m "Initial commit"

project_payload='{
  name: $name,
  path: $name,
  description: $description,
  visibility: $visibility,
  initialize_with_readme: false
}'

if [[ -n "$topics" ]]; then
  project_payload="$project_payload + { tag_list: ($topics | split(\",\") | map(gsub(\"^\\\\s+|\\\\s+$\"; \"\")) | map(select(length > 0))) }"
fi

payload=$(jq -n \
  --arg name "$repo" \
  --arg description "$description" \
  --arg visibility "$visibility" \
  --arg namespace "$NAMESPACE_PATH" \
  --arg topics "$topics" \
  "$project_payload + if \$namespace != \"\" then {namespace_id: (\$namespace | tonumber)} else {} end")

response=$(curl -fsS \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data "$payload" \
  "https://$GITLAB_HOST/api/v4/projects")

ssh_url=$(jq -r '.ssh_url_to_repo' <<<"$response")

if [[ -z "$ssh_url" || "$ssh_url" == "null" ]]; then
  echo "GitLab did not return an SSH URL. Response:" >&2
  echo "$response" >&2
  exit 1
fi

git remote add origin "$ssh_url"
git push -u origin main

echo
echo "GitLab repo created and pushed:"
echo "$ssh_url"

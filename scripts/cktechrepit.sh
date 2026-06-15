#!/usr/bin/env zsh

# Prompt for repo name
echo -n "Enter new CKTech GitHub repo name (e.g. ghostwin): "
read repo

# Prompt for language (used to generate .gitignore)
echo -n "Project language (rust/go/zig/python/js/node/bun/none): "
read lang

# Prompt for private or public visibility
echo -n "Make repository private? (y/n): "
read private_input
[[ "$private_input" =~ ^[Yy]$ ]] && visibility="--private" || visibility="--public"

# Optional: add GitHub topics
echo -n "Add GitHub topics? (space-separated, or leave blank): "
read topics

# Prompt for GitHub Actions workflow stub (handy for self-hosted runners)
echo -n "Create empty GitHub Actions workflow stub? (y/n): "
read workflow_input

# GitHub owner and a safe template renderer.
# render() reads a template from stdin (use a quoted heredoc so backticks and
# $ stay literal) and substitutes __REPO__ / __OWNER__ placeholders.
owner="CK-Technology"
render() {
  local content
  content=$(cat)
  content=${content//__REPO__/$repo}
  content=${content//__OWNER__/$owner}
  print -r -- "$content" > "$1"
}

# Set working directory
cd /data/projects || exit 1
mkdir "$repo"
cd "$repo" || exit 1

# LICENSE
cat <<EOF > LICENSE
MIT License

Copyright (c) 2026 CK Technology LLC

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
EOF

# .gitignore: language-specific section.
# Note: Cargo.lock is intentionally NOT ignored (committed for reproducible builds).
case "$lang" in
  rust)
    cat <<EOF > .gitignore
# Rust
/target
**/*.rs.bk
EOF
    ;;
  go)
    cat <<EOF > .gitignore
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
    cat <<EOF > .gitignore
# Zig
.zig-cache/
zig-out/
zig-pkg/
*.o
*.exe
EOF
    ;;
  python)
    cat <<EOF > .gitignore
# Python
__pycache__/
*.pyc
*.pyo
.venv/
env/
venv/
EOF
    ;;
  js|node|bun)
    cat <<EOF > .gitignore
# Node / Bun
node_modules/
dist/
build/
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

# Common section appended for every project
cat <<EOF >> .gitignore

# Local workflow / scratch (not committed)
tasks/
CLAUDE.md
archive/

# Editor / OS
.vscode/
.idea/
*.swp
*.swo
.DS_Store
Thumbs.db
EOF

# Standardized project scaffold
mkdir -p tasks docs
: > tasks/todo.md
: > docs/README.md

render README.md <<'TEMPLATE_EOF'
# __REPO__

> One-line description of __REPO__.

## Status

Early development.

## Documentation

See [docs/](docs/README.md).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Security

To report a vulnerability, see [SECURITY.md](SECURITY.md).

## License

MIT — see [LICENSE](LICENSE).
TEMPLATE_EOF

render CONTRIBUTING.md <<'TEMPLATE_EOF'
# Contributing to __REPO__

Thanks for your interest in contributing to __REPO__! This guide covers the
basics for getting changes merged.

## Getting Started

1. Fork the repository on GitHub.
2. Clone your fork and create a feature branch from `main`:

```bash
git clone https://github.com/__OWNER__/__REPO__
cd __REPO__
git checkout -b feature/your-change
```

## Development Workflow

- Keep changes focused; one logical change per pull request.
- Match the existing code style and run the project's formatter/linter.
- Add or update tests for any behavior change.
- Update documentation under `docs/` when relevant.

## Commit Messages

Follow Conventional Commits:

```
type(scope): short description
```

Common types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`.

## Pull Requests

Before opening a PR:

- Rebase on the latest `main`.
- Ensure the build, tests, and linters pass.
- Describe **what** changed and **why**.

## Reporting Bugs

Open an [issue](https://github.com/__OWNER__/__REPO__/issues) with steps to
reproduce, expected vs. actual behavior, and environment details.

## License

By contributing, you agree your contributions are licensed under the MIT License.
TEMPLATE_EOF

render SECURITY.md <<'TEMPLATE_EOF'
# Security Policy

## Reporting a Vulnerability

**Please do not open public GitHub issues for security vulnerabilities.**

Report privately through GitHub's
[private vulnerability reporting](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing-information-about-vulnerabilities/privately-reporting-a-security-vulnerability)
("Report a vulnerability" under the repository's **Security** tab), or by
contacting the maintainers directly.

Please include:

- A description of the vulnerability and its impact
- Steps to reproduce or a proof of concept
- Affected component(s) and version/commit
- Any suggested remediation, if known

### Response Targets

| Stage | Target |
|-------|--------|
| Acknowledgement | within 72 hours |
| Initial assessment | within 7 days |
| Fix / mitigation | depends on severity |
| Public disclosure | coordinated, after a fix is available |

These are good-faith targets, not contractual SLAs.

## Supported Versions

__REPO__ is pre-1.0. Only the latest commit on the default branch receives
security fixes.

| Version | Supported |
|---------|-----------|
| `main` (latest) | ✅ |
| older tags | ❌ |

## Disclosure Policy

We follow coordinated disclosure. Please allow a reasonable window to ship a fix
before public discussion. Reporters who wish to be credited will be acknowledged.
TEMPLATE_EOF

# GitHub Actions stub (optional)
if [[ "$workflow_input" =~ ^[Yy]$ ]]; then
  mkdir -p .github/workflows
  touch .github/workflows/main.yml
fi

# Initialize git and push
git init
git add .
git commit -m "Initial commit"

# Create the repository under CK-Technology org
gh repo create "CK-Technology/$repo" \
  $visibility \
  --source=. \
  --remote=origin \
  --push

# Set SSH remote explicitly
git remote set-url origin "git@github.com:CK-Technology/$repo.git"

# Enable Dependabot security updates (alerts + automated fixes).
# These are repo-level toggles, not a workflow or committed file, so new repos
# don't depend on the org "auto-enable for new repositories" default.
gh api -X PUT "repos/$owner/$repo/vulnerability-alerts" --silent \
  && echo "✅ Dependabot vulnerability alerts enabled"
gh api -X PUT "repos/$owner/$repo/automated-security-fixes" --silent \
  && echo "✅ Dependabot automated security fixes enabled"

# Apply topics if provided
if [[ -n "$topics" ]]; then
  gh repo edit "CK-Technology/$repo" --add-topic ${(s: :)topics}
fi

# Confirmation
echo "\n✅ Repo '$repo' created under CK-Technology and pushed."
git remote -v


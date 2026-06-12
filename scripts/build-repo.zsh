#!/usr/bin/env zsh

# Prompt for repo name
echo -n "Enter new GitHub repo name (e.g. dotshot): "
read repo

# Prompt for main language (for .gitignore)
echo -n "Project language (rust/zig/python/js/none): "
read lang

# Prompt for license choice
echo -n "License (mit/apache): "
read license

# Set working path
cd /data/projects || exit
mkdir "$repo"
cd "$repo" || exit

# Create base files
echo "# $repo" > README.md

# Create LICENSE based on user choice
case "$license" in
  apache)
    cp /data/scripts/APACHE2.0-LICENSE LICENSE
    ;;
  *)
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
    ;;
esac

# Create .gitignore by language
case "$lang" in
  rust)
    cat <<EOF > .gitignore
/target
**/*.rs.bk
tasks/
CLAUDE.md
EOF
    ;;
  zig)
    cat <<EOF > .gitignore
.zig-cache/
zig-out/
zig-pkg/
tasks
*.o
*.exe
CLAUDE.md
EOF
    ;;
  python)
    cat <<EOF > .gitignore
__pycache__/
*.pyc
*.pyo
*.pyd
.venv/
env/
venv/
tasks/
archive/
EOF
    ;;
  js)
    cat <<EOF > .gitignore
node_modules/
dist/
npm-debug.log
yarn-error.log
tasks/
archive/
EOF
    ;;
  *)
    touch .gitignore
    ;;
esac

# Create empty GitHub Actions workflow
mkdir -p .github/workflows
touch .github/workflows/main.yml

# Initialize git
git init
git add .
git commit -m "Initial commit: bootstrap"

# Create GitHub repo (SSH, public, push it)
gh repo create "ghostkellz/$repo" \
  --public \
  --source=. \
  --remote=origin \
  --push

# Ensure SSH is used for future pushes
git remote set-url origin "git@github.com:ghostkellz/$repo.git"

# Confirmation
echo "\n✅ Repo '$repo' created at /data/projects/$repo and pushed via SSH"
git remote -v


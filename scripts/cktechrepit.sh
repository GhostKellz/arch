#!/usr/bin/env zsh

# Prompt for repo name
echo -n "Enter new CKTech GitHub repo name (e.g. ghostwin): "
read repo

# Prompt for language (used to generate .gitignore)
echo -n "Project language (rust/zig/python/js/none): "
read lang

# Optional: Prompt for private or public
echo -n "Make repository private? (y/n): "
read private_input
[[ "$private_input" =~ ^[Yy]$ ]] && visibility="--private" || visibility="--public"

# Set working directory
cd /data/projects || exit
mkdir "$repo"
cd "$repo" || exit

# Base files
echo "# $repo" > README.md
cat <<EOF > LICENSE
MIT License

Copyright (c) 2025 CK Technology LLC

Permission is hereby granted, free of charge, to any person obtaining a copy
...
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND...
EOF

# Create .gitignore
case "$lang" in
  rust)
    echo "/target\nCargo.lock\n**/*.rs.bk" > .gitignore ;;
  zig)
    echo "/zig-cache/\n/zig-out/\n*.o\n*.exe" > .gitignore ;;
  python)
    echo "__pycache__/\n*.pyc\n.venv/\nvenv/" > .gitignore ;;
  js)
    echo "node_modules/\ndist/\nnpm-debug.log" > .gitignore ;;
  *)
    touch .gitignore ;;
esac

# Setup GitHub Actions stub
mkdir -p .github/workflows
touch .github/workflows/main.yml

# Git init
git init
git add .
git commit -m "Initial commit"

# Create org repo
gh repo create "cktechnology/$repo" \
  $visibility \
  --source=. \
  --remote=origin \
  --push

# Use SSH remote
git remote set-url origin "git@github.com:cktechnology/$repo.git"

# Confirmation
echo "\n✅ Repo '$repo' created under CK Technology and pushed."
git remote -v


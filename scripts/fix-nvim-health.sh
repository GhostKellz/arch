#!/usr/bin/env bash

echo "🔍 Running :checkhealth..."
output=$(nvim --headless "+checkhealth" +qa 2>/dev/null)

echo "$output" | grep -E "vim.lsp.get_active_clients|client.request|vim.validate" >/dev/null || {
  echo "✅ No known deprecated calls found. All good!"
  exit 0
}

echo "⚠️ Deprecated calls detected in your plugins."
read -p "Would you like to automatically patch them? (y/N): " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || exit 1

targets=$(grep -rl --null \
  -e 'vim.lsp.get_active_clients' \
  -e 'client.request' \
  -e 'vim.validate(' \
  ~/.local/share/nvim/lazy/)

for file in $targets; do
  echo "📦 Patching $file"
  cp "$file" "$file.bak.$(date +%s)"
  sed -i \
    -e 's/vim.lsp.get_active_clients/vim.lsp.get_clients/g' \
    -e 's/\([^:.]\)client\.request/\1client:request/g' \
    "$file"
done

echo "✅ All applicable files patched and backed up (.bak.TIMESTAMP)"
echo "🔁 Reload Neovim or restart to apply changes."
#!/usr/bin/env bash

echo "🔍 Running :checkhealth..."
output=$(nvim --headless "+checkhealth" +qa 2>/dev/null)

echo "$output" | grep -E "vim.lsp.get_active_clients|client.request|vim.validate" >/dev/null || {
  echo "✅ No known deprecated calls found. All good!"
  exit 0
}

echo "⚠️ Deprecated calls detected in your plugins."
read -p "Would you like to automatically patch them? (y/N): " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || exit 1

targets=$(grep -rl --null \
  -e 'vim.lsp.get_active_clients' \
  -e 'client.request' \
  -e 'vim.validate(' \
  ~/.local/share/nvim/lazy/)

for file in $targets; do
  echo "📦 Patching $file"
  cp "$file" "$file.bak.$(date +%s)"
  sed -i \
    -e 's/vim.lsp.get_active_clients/vim.lsp.get_clients/g' \
    -e 's/\([^:.]\)client\.request/\1client:request/g' \
    "$file"
done

echo "✅ All applicable files patched and backed up (.bak.TIMESTAMP)"
echo "🔁 Reload Neovim or restart to apply changes."


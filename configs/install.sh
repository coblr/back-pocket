#!/bin/bash
#
# Symlinks config files from this repo to their expected locations.
# Safe to re-run — uses ln -sf to overwrite existing symlinks.

CONFIGS="$(cd "$(dirname "$0")" && pwd)"

echo "Installing configs from: $CONFIGS"
echo ""

# Ensure target directories exist
mkdir -p ~/.config

# --- Full directory symlinks ---

echo "Linking nvim..."
rm -rf ~/.config/nvim
ln -sf "$CONFIGS/nvim" ~/.config/nvim

echo "Linking ghostty..."
rm -rf ~/.config/ghostty
ln -sf "$CONFIGS/ghostty" ~/.config/ghostty

echo "Linking oh-my-posh..."
rm -rf ~/.config/oh-my-posh
ln -sf "$CONFIGS/oh-my-posh" ~/.config/oh-my-posh

# --- Individual file symlinks ---

echo "Linking tmux..."
ln -sf "$CONFIGS/tmux/.tmux.conf" ~/.tmux.conf

# ~/.zshrc is a machine-local loader, not a symlink, because installers such as
# Aikido append to ~/.zshrc and would otherwise write into this repo.
echo "Setting up zshrc loader..."
ZSHRC_SOURCE="source \"$CONFIGS/zsh/.zshrc\""
if [[ -L ~/.zshrc || ! -e ~/.zshrc ]]; then
  rm -f ~/.zshrc
  {
    echo "# Machine-local loader. Not tracked: installers such as Aikido append here,"
    echo "# so their lines stay on this machine instead of landing in back-pocket."
    echo "# Personal machine-specific config goes in ~/.zshrc.local instead."
    echo "$ZSHRC_SOURCE"
  } > ~/.zshrc
  echo "  Wrote ~/.zshrc loader"
elif ! grep -qF "$ZSHRC_SOURCE" ~/.zshrc; then
  cp ~/.zshrc ~/.zshrc.pre-back-pocket
  { echo "$ZSHRC_SOURCE"; echo; cat ~/.zshrc.pre-back-pocket; } > ~/.zshrc
  echo "  Prepended the loader line to existing ~/.zshrc (backup at ~/.zshrc.pre-back-pocket)"
else
  echo "  ~/.zshrc already loads the shared config, skipping"
fi

echo "Linking claude code config..."
mkdir -p ~/.claude
ln -sf "$CONFIGS/claude/CLAUDE.md" ~/.claude/CLAUDE.md
ln -sf "$CONFIGS/claude/statusline.sh" ~/.claude/statusline.sh
if [[ ! -e ~/.claude/settings.json ]]; then
  cp "$CONFIGS/claude/settings.json" ~/.claude/settings.json
  echo "  Copied settings.json template (edit for machine-specific config)"
else
  echo "  settings.json already exists, skipping (template at $CONFIGS/claude/settings.json)"
fi

echo ""
echo "Done! Open a new shell to pick up changes."
echo ""
echo "NOTE: You may also want to create ~/.zshrc.local for machine-specific"
echo "config (work env vars, project aliases, etc). See README.md for details."
echo "NOTE: Claude Code settings at ~/.claude/settings.json are copied (not linked)"
echo "from the template. Add machine-specific config (env vars, MCP permissions) directly."

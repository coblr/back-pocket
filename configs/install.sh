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

echo "Linking zshrc..."
ln -sf "$CONFIGS/zsh/.zshrc" ~/.zshrc

echo ""
echo "Done! Open a new shell to pick up changes."
echo ""
echo "NOTE: You may also want to create ~/.zshrc.local for machine-specific"
echo "config (work env vars, project aliases, etc). See README.md for details."

#!/usr/bin/env zsh
set -e

INSTALL_DIR="$HOME/.config/lcars-zsh"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_LINE='source "$HOME/.config/lcars-zsh/lcars.zsh"'

mkdir -p "$INSTALL_DIR"
cp "$SCRIPT_DIR/lcars.zsh" "$INSTALL_DIR/lcars.zsh"

if ! grep -qF "$SOURCE_LINE" "$HOME/.zshrc" 2>/dev/null; then
  printf '\n# LCARS Zsh Theme\n%s\n' "$SOURCE_LINE" >> "$HOME/.zshrc"
  echo "Added source line to ~/.zshrc"
else
  echo "Source line already present in ~/.zshrc"
fi

echo "LCARS theme installed to $INSTALL_DIR"
echo "Restart your shell or run: source ~/.zshrc"

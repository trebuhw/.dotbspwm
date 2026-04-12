#!/usr/bin/env bash

set -euo pipefail

# =========================================================
# NixOS bspwm — skrypt poinstalacyjny (uruchom tylko RAZ)
# =========================================================

echo "==> Stowing dotfiles..."
if [ -d "$HOME/.dotbspwm" ]; then
  cd "$HOME/.dotbspwm"
  stow --target="$HOME" \
    Xresources bat bin bspwm btop dmrc fastfetch fish fonts geany \
    ghostty gtkrc icons nsxiv nvim scripts starship themes tmux \
    vim wallpaper wezterm yazi zathura
  echo "    OK"
else
  echo "!! Katalog ~/.dotbspwm nie znaleziony, pomijam stow"
fi

# =========================================================
# bspwm tabbed — kompilacja (make install)
# Na NixOS wymagane jest nix-shell z zależnościami build
# =========================================================
echo "==> Building bspwm tabbed..."
if [ -d "$HOME/.config/bspwm/tabbed" ]; then
  cd "$HOME/.config/bspwm/tabbed"
  # Tymczasowe środowisko z narzędziami do kompilacji
  nix-shell -p gnumake gcc xorg.libX11 xorg.libXft --run "make clean && sudo make install"
  echo "    OK"
else
  echo "!! Katalog ~/.config/bspwm/tabbed nie znaleziony, pomijam"
fi

# =========================================================
# XDG user dirs
# =========================================================
echo "==> Updating XDG user dirs..."
xdg-user-dirs-update

echo ""
echo "==> Gotowe! Możesz się wylogować i zalogować ponownie."

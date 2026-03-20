#!/usr/bin/env bash

set -euo pipefail

echo "==> Installing base dependencies..."
sudo pacman -S --needed base-devel git

echo "==> Installing yay (AUR helper)..."
if [ ! -d "$HOME/yay-bin" ]; then
  git clone https://aur.archlinux.org/yay-bin.git "$HOME/yay-bin"
fi

cd "$HOME/yay-bin"
makepkg -si --noconfirm

echo "==> Installing packages..."
sudo pacman -S --needed \
  bat btop chromium dunst eza fastfetch feh fish geany geany-plugins \
  ghostty git gvfs neovim nsxiv numlockx nwg-look pulsemixer rofi starship stow sxhkd \
  thunar thunar-archive-plugin thunar-volman tmux trash-cli tree tumbler vim \
  xclip xdg-user-dirs xorg-xrandr xorg-xsetroot yazi zathura zoxide

echo "==> Updating XDG user dirs..."
xdg-user-dirs-update

echo "==> Stowing dotfiles..."
if [ -d "$HOME/.dotbspwm" ]; then
  cd "$HOME/.dotbspwm"
  stow \
    Xresources bat bin bspwm btop dmrc fastfetch fish fonts geany \
    ghostty gtkrc icons nsxiv nvim scripts starship themes tmux \
    vim wallpaper wezterm yazi zathura
else
  echo "!! Directory ~/.dotbspwm not found, skipping stow"
fi

echo "==> Installing bspwm tabbed..."
if [ -d "$HOME/.config/bspwm/tabbed" ]; then
  cd "$HOME/.config/bspwm/tabbed"
  sudo make clean install
else
  echo "!! tabbed directory not found, skipping"
fi

sudo chsh $USER -s /usr/bin/fish && echo "Now log out"

echo "==> Done, restart PC!"

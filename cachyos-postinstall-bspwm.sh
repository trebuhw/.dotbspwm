#!/usr/bin/env bash

set -euo pipefail

# === Jednorazowe sudo — odświeżaj token co 60s w tle ===
echo "==> Podaj hasło sudo (jednorazowo)..."
sudo -v
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

echo "==> Installing base dependencies..."
sudo pacman -S --needed --noconfirm base-devel git

echo "==> Installing yay (AUR helper)..."
if [ ! -d "$HOME/yay-bin" ]; then
  git clone https://aur.archlinux.org/yay-bin.git "$HOME/yay-bin"
fi

cd "$HOME/yay-bin"
makepkg -si --noconfirm

echo "==> Installing packages..."
sudo pacman -S --needed --noconfirm \
  bat btop chromium dunst eza fastfetch feh firefox fish geany geany-plugins \
  ghostty git gvfs lm_sensors neovim nsxiv numlockx nwg-look picom polybar pulsemixer \
  rofi starship stow sxhkd thunar thunar-archive-plugin thunar-volman tlp \
  tmux trash-cli tree tumbler unzip vim xarchiver xclip xdg-user-dirs \
  xorg-xrandr xorg xorg-xsetroot yazi zathura zoxide

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

echo "==> Copy TLP config..."
sudo cp ~/.dotbspwm/etc/.config/tlp.conf /etc/tlp.conf

echo "==> Enable & Start TLP config..."
sudo systemctl enable --now tlp

echo "==> Change shell to fish..."
sudo chsh "$USER" -s /usr/bin/fish && echo "Now log out"

echo "==> Done, restart PC!"

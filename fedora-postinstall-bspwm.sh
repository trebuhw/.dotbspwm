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

# -------------------------------------------------------
# Fedora: włącz RPM Fusion (potrzebne m.in. do chromium)
# -------------------------------------------------------
echo "==> Enabling RPM Fusion repositories..."
sudo dnf install -y \
  "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
  "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

# -------------------------------------------------------
# Bazowe narzędzia developerskie (odpowiednik base-devel)
# -------------------------------------------------------
echo "==> Installing base dependencies..."
sudo dnf install -y \
  @development-tools git

# Nagłówki potrzebne do kompilacji tabbed (i każdego innego suckless):
# libX11-devel      — Xlib headers (X11/Xlib.h)
# libXft-devel      — Xft headers (X11/Xft/Xft.h)
# libXinerama-devel — na wypadek patchy z Xineramą
# fontconfig-devel  — wymagane przez Xft
echo "==> Installing X11 devel headers (for compiling tabbed)..."
sudo dnf install -y \
  libX11-devel \
  libXft-devel \
  libXinerama-devel \
  fontconfig-devel

# -------------------------------------------------------
# X11
# Fedora Workstation używa Wayland + GDM, ale bspwm
# wymaga Xorg. Nie trzeba @base-x (już zainstalowany),
# wystarczy sam serwer + xinit + narzędzia.
# -------------------------------------------------------
echo "==> Installing X11..."
# xorg-x11-server-Xorg  — serwer X, główny wymóg bspwm
# xorg-x11-xinit        — dostarcza startx i szkielet /etc/X11/xinit/
# xorg-x11-server-utils — dostarcza xsetroot i xrandr
sudo dnf install -y \
  xorg-x11-server-Xorg \
  xorg-x11-xinit \
  xorg-x11-server-utils

# -------------------------------------------------------
# Główna lista pakietów
# -------------------------------------------------------
echo "==> Installing packages..."
sudo dnf install -y \
  bat \
  btop \
  chromium \
  dunst \
  eza \
  fastfetch \
  feh \
  firefox \
  fish \
  geany \
  geany-plugins-common \
  git \
  gvfs \
  lm_sensors \
  neovim \
  numlockx \
  polybar \
  rofi \
  starship \
  stow \
  sxhkd \
  bspwm \
  thunar \
  thunar-archive-plugin \
  thunar-volman \
  tlp \
  tmux \
  trash-cli \
  tree \
  tumbler \
  unzip \
  vim \
  xarchiver \
  xclip \
  xdg-user-dirs \
  yazi \
  zathura \
  zathura-pdf-poppler \
  zoxide

# Uwaga: eza może być orphaned na Fedorze 42+.
# Jeśli instalacja się nie powiodła, zainstaluj ją ręcznie:
#   EZA_VER=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep tag_name | cut -d '"' -f4)
#   curl -Lo /tmp/eza.tar.gz "https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz"
#   tar -xf /tmp/eza.tar.gz -C /tmp && sudo mv /tmp/eza /usr/local/bin/

# -------------------------------------------------------
# COPR: pakiety niedostępne w oficjalnych repozytoriach
# -------------------------------------------------------

# ghostty — terminal emulator
echo "==> Installing ghostty (via COPR)..."
sudo dnf copr enable -y pgdev/ghostty
sudo dnf install -y ghostty

# nsxiv — image viewer
echo "==> Installing nsxiv (via COPR)..."
sudo dnf copr enable -y mamg22/nsxiv
sudo dnf install -y nsxiv

# nwg-look — GTK theme manager
echo "==> Installing nwg-look (via COPR)..."
sudo dnf copr enable -y tofik/nwg-shell
sudo dnf install -y nwg-look

# pulsemixer — brak w oficjalnych repo ani w COPR, instalacja przez pip
echo "==> Installing pulsemixer (via pip)..."
pip3 install --user pulsemixer
# lub zainstaluj globalnie: sudo pip3 install pulsemixer

# -------------------------------------------------------
# XDG dirs
# -------------------------------------------------------
echo "==> Updating XDG user dirs..."
xdg-user-dirs-update

# -------------------------------------------------------
# Stow dotfiles
# -------------------------------------------------------
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

# -------------------------------------------------------
# bspwm tabbed
# -------------------------------------------------------
echo "==> Installing bspwm tabbed..."
if [ -d "$HOME/.config/bspwm/tabbed" ]; then
  cd "$HOME/.config/bspwm/tabbed"
  sudo make clean install
else
  echo "!! tabbed directory not found, skipping"
fi

# -------------------------------------------------------
# TLP
# -------------------------------------------------------
echo "==> Copy TLP config..."
sudo cp ~/.dotbspwm/etc/.config/tlp.conf /etc/tlp.conf

echo "==> Enable & Start TLP..."
sudo systemctl enable --now tlp

# -------------------------------------------------------
# Zmiana powłoki na fish
# -------------------------------------------------------
echo "==> Change shell to fish..."
# Na Fedorze fish jest w /usr/bin/fish — upewnij się, że jest w /etc/shells
grep -qxF '/usr/bin/fish' /etc/shells || echo '/usr/bin/fish' | sudo tee -a /etc/shells
sudo chsh "$USER" -s /usr/bin/fish && echo "Now log out"

echo "==> Done, restart PC!"

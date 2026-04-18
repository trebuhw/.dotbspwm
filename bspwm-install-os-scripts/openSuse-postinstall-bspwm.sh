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

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
zypper_in() {
  sudo zypper --non-interactive install --no-recommends "$@"
}

# ---------------------------------------------------------------------------
# Bazowe narzędzia developerskie
# ---------------------------------------------------------------------------
echo "==> Installing base dependencies..."
zypper_in git make gcc gcc-c++ automake autoconf pkg-config

# ---------------------------------------------------------------------------
# OBS / zewnętrzne repozytoria
# ---------------------------------------------------------------------------
# packman-essentials — potrzebny m.in. dla niektórych kodeków
echo "==> Adding Packman repository..."
if ! sudo zypper repos | grep -q packman; then
  sudo zypper ar --refresh \
    "https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/" \
    packman
  sudo zypper --gpg-auto-import-keys refresh packman
fi

# ---------------------------------------------------------------------------
# Główne pakiety
# ---------------------------------------------------------------------------
echo "==> Installing packages..."
zypper_in \
  bat btop chromium dunst eza fastfetch feh firefox fish geany geany-plugins \
  git gthumb gvfs lm_sensors neovim numlockx picom polybar pulsemixer \
  rofi starship stow sxhkd thunar thunar-plugin-archive thunar-plugin-volman \
  tlp tmux trash-cli tree tumbler unzip vim xarchiver xclip \
  xdg-user-dirs xrandr xsetroot yazi zathura zoxide

# Ghostty — dostępny przez OBS (home:lhc:ghostty lub flatpak)
echo "==> Installing ghostty..."
if ! command -v ghostty &>/dev/null; then
  if ! sudo zypper repos | grep -q "ghostty"; then
    sudo zypper ar --refresh \
      "https://download.opensuse.org/repositories/home:/lhc:/ghostty/openSUSE_Tumbleweed/" \
      ghostty-obs
    sudo zypper --gpg-auto-import-keys refresh ghostty-obs
  fi
  zypper_in ghostty || {
    echo "!! ghostty niedostępny przez OBS — spróbuj: flatpak install flathub com.mitchellh.ghostty"
  }
fi

# nsxiv — może wymagać OBS (graphics:tools) gdy nie ma w głównym repo
echo "==> Installing nsxiv..."
zypper_in nsxiv 2>/dev/null || {
  echo "!! nsxiv nie znaleziony w repo — próba przez OBS graphics:tools..."
  if ! sudo zypper repos | grep -q "graphics_tools"; then
    sudo zypper ar --refresh \
      "https://download.opensuse.org/repositories/graphics/openSUSE_Tumbleweed/" \
      graphics_tools
    sudo zypper --gpg-auto-import-keys refresh graphics_tools
  fi
  zypper_in nsxiv || echo "!! nsxiv niedostępny — pomiń lub zainstaluj ręcznie"
}

# nwg-look — dostępny przez OBS (home:nwg-piotr)
echo "==> Installing nwg-look..."
zypper_in nwg-look 2>/dev/null || {
  if ! sudo zypper repos | grep -q "nwg"; then
    sudo zypper ar --refresh \
      "https://download.opensuse.org/repositories/home:/nwg-piotr/openSUSE_Tumbleweed/" \
      nwg-piotr
    sudo zypper --gpg-auto-import-keys refresh nwg-piotr
  fi
  zypper_in nwg-look || echo "!! nwg-look niedostępny — pomiń lub użyj flatpak"
}

# ---------------------------------------------------------------------------
# XDG user dirs
# ---------------------------------------------------------------------------
echo "==> Updating XDG user dirs..."
xdg-user-dirs-update

# ---------------------------------------------------------------------------
# Stow dotfiles
# ---------------------------------------------------------------------------
echo "==> Stowing dotfiles..."
if [ -d "$HOME/.dotbspwm" ]; then
  cd "$HOME/.dotbspwm"
  stow \
    Xresources bat bin bspwm btop dmrc fastfetch fish fonts geany \
    ghostty gtkrc icons nsxiv nvim scripts starship themes tmux \
    vim wallpaper wezterm yazi zathura
else
  echo "!! Katalog ~/.dotbspwm nie znaleziony, pomijam stow"
fi

# ---------------------------------------------------------------------------
# bspwm tabbed
# ---------------------------------------------------------------------------
echo "==> Installing bspwm tabbed..."
if [ -d "$HOME/.config/bspwm/tabbed" ]; then
  cd "$HOME/.config/bspwm/tabbed"
  sudo make clean install
else
  echo "!! Katalog tabbed nie znaleziony, pomijam"
fi

# ---------------------------------------------------------------------------
# TLP
# ---------------------------------------------------------------------------
echo "==> Copy TLP config..."
sudo cp ~/.dotbspwm/etc/.config/tlp.conf /etc/tlp.conf

echo "==> Enable & Start TLP..."
sudo systemctl enable --now tlp

# ---------------------------------------------------------------------------
# Domyślna powłoka: fish
# ---------------------------------------------------------------------------
echo "==> Change shell to fish..."
# Na Tumbleweed chsh jest w util-linux
sudo chsh "$USER" -s /usr/bin/fish && echo "Wyloguj się aby zmiana powłoki zadziałała"

echo "==> Done, uruchom ponownie komputer!"

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
apt_in() {
  sudo apt-get install -y --no-install-recommends "$@"
}

# ---------------------------------------------------------------------------
# Aktualizacja list pakietów
# ---------------------------------------------------------------------------
echo "==> Updating package lists..."
sudo apt-get update

# ---------------------------------------------------------------------------
# Bazowe narzędzia developerskie
# ---------------------------------------------------------------------------
echo "==> Installing base dependencies..."
apt_in build-essential git curl wget ca-certificates gpg

# ---------------------------------------------------------------------------
# Główne pakiety z oficjalnych repozytoriów
# ---------------------------------------------------------------------------
echo "==> Installing packages..."
apt_in \
  bat btop chromium dunst feh firefox-esr fish geany geany-plugins \
  git gvfs lm-sensors neovim numlockx picom polybar pulsemixer \
  rofi stow sxhkd thunar thunar-archive-plugin thunar-volman \
  tlp tmux trash-cli tree tumbler unzip vim xarchiver xclip \
  xdg-user-dirs x11-xserver-utils xorg zathura zoxide

# Uwaga: bat instaluje się jako 'batcat' na Debianie — tworzymy alias
if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
  mkdir -p "$HOME/.local/bin"
  ln -sf /usr/bin/batcat "$HOME/.local/bin/bat"
  echo "!! Utworzono symlink bat -> batcat w ~/.local/bin"
fi

# ---------------------------------------------------------------------------
# eza — nie ma w oficjalnym repo Debian stable, instalujemy z GitHub releases
# ---------------------------------------------------------------------------
echo "==> Installing eza..."
if ! command -v eza &>/dev/null; then
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc |
    sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" |
    sudo tee /etc/apt/sources.list.d/gierens.list
  sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
  sudo apt-get update
  apt_in eza
fi

# ---------------------------------------------------------------------------
# fastfetch — nie w repo Debian stable, instalujemy z GitHub releases
# ---------------------------------------------------------------------------
echo "==> Installing fastfetch..."
if ! command -v fastfetch &>/dev/null; then
  FF_VER=$(curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest |
    grep '"tag_name"' | cut -d'"' -f4)
  wget -q "https://github.com/fastfetch-cli/fastfetch/releases/download/${FF_VER}/fastfetch-linux-amd64.deb" \
    -O /tmp/fastfetch.deb
  sudo dpkg -i /tmp/fastfetch.deb
  rm /tmp/fastfetch.deb
fi

# ---------------------------------------------------------------------------
# starship — instalator oficjalny
# ---------------------------------------------------------------------------
echo "==> Installing starship..."
if ! command -v starship &>/dev/null; then
  curl -sS https://starship.rs/install.sh | sudo sh -s -- --yes
fi

# ---------------------------------------------------------------------------
# zoxide — nie w repo Debian stable, instalujemy z GitHub releases
# ---------------------------------------------------------------------------
echo "==> Installing zoxide..."
if ! command -v zoxide &>/dev/null; then
  curl -sSf https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi

# ---------------------------------------------------------------------------
# polybar — może wymagać kompilacji lub backports
# ---------------------------------------------------------------------------
echo "==> Installing polybar..."
apt_in polybar 2>/dev/null || {
  echo "!! polybar niedostępny w repo — próba z backports..."
  if ! grep -q "backports" /etc/apt/sources.list /etc/apt/sources.list.d/*.list 2>/dev/null; then
    CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")
    echo "deb http://deb.debian.org/debian ${CODENAME}-backports main" |
      sudo tee /etc/apt/sources.list.d/backports.list
    sudo apt-get update
  fi
  apt_in -t "$(. /etc/os-release && echo "$VERSION_CODENAME")-backports" polybar ||
    echo "!! polybar niedostępny — zainstaluj ręcznie z https://github.com/polybar/polybar"
}

# ---------------------------------------------------------------------------
# ghostty — instalujemy z PPA/deb release
# ---------------------------------------------------------------------------
echo "==> Installing ghostty..."
if ! command -v ghostty &>/dev/null; then
  GHOSTTY_VER=$(curl -s https://api.github.com/repos/ghostty-org/ghostty/releases/latest |
    grep '"tag_name"' | cut -d'"' -f4)
  wget -q "https://github.com/ghostty-org/ghostty/releases/download/${GHOSTTY_VER}/ghostty-${GHOSTTY_VER}-linux-x86_64.tar.gz" \
    -O /tmp/ghostty.tar.gz 2>/dev/null &&
    sudo tar -xzf /tmp/ghostty.tar.gz -C /usr/local/bin ghostty &&
    rm /tmp/ghostty.tar.gz ||
    echo "!! ghostty niedostępny jako binarny release — spróbuj: flatpak install flathub com.mitchellh.ghostty"
fi

# ---------------------------------------------------------------------------
# nsxiv
# ---------------------------------------------------------------------------
echo "==> Installing nsxiv..."
apt_in nsxiv 2>/dev/null || {
  echo "!! nsxiv niedostępny — próba kompilacji ze źródeł..."
  apt_in libimlib2-dev libx11-dev libxft-dev libexif-dev libgif-dev libtiff-dev \
    libwebp-dev librsvg2-dev
  git clone https://github.com/nsxiv/nsxiv.git /tmp/nsxiv
  cd /tmp/nsxiv
  sudo make install
  rm -rf /tmp/nsxiv
}

# ---------------------------------------------------------------------------
# yazi
# ---------------------------------------------------------------------------
echo "==> Installing yazi..."

# Funkcja do instalacji paczki .deb
install_yazi_deb() {
  # Pobierz najnowszą wersję z GitHub
  LATEST_URL=$(curl -s https://api.github.com/repos/sxyazi/yazi/releases/latest |
    jq -r '.assets[] | select(.name | endswith(".deb")) | .browser_download_url')

  if [ -z "$LATEST_URL" ]; then
    echo "!! Nie udało się znaleźć najnowszej paczki yazi .deb"
    return 1
  fi

  echo "==> Pobieranie $LATEST_URL..."
  TMP_DEB=$(mktemp --suffix=.deb)
  curl -L "$LATEST_URL" -o "$TMP_DEB"

  echo "==> Instalacja yazi..."
  sudo dpkg -i "$TMP_DEB" || sudo apt -f install -y

  rm -f "$TMP_DEB"
}

# Sprawdź, czy yazi jest zainstalowane
if ! command -v yazi >/dev/null 2>&1; then
  echo "!! yazi nie znaleziono — instalacja najnowszej wersji .deb"
  # Zainstaluj zależności potrzebne do działania yazi
  sudo apt update
  sudo apt install -y ffmpeg p7zip-full jq poppler-utils fd-find ripgrep fzf imagemagick curl

  install_yazi_deb
else
  echo "==> yazi już zainstalowane"
fi

# ---------------------------------------------------------------------------
# nwg-look
# ---------------------------------------------------------------------------
echo "==> Installing nwg-look..."
apt_in nwg-look 2>/dev/null ||
  echo "!! nwg-look niedostępny — użyj: flatpak install flathub io.github.nwg_piotr.nwg-look"

# ---------------------------------------------------------------------------
# Czcionki JetBrains Mono
# ---------------------------------------------------------------------------
echo "==> Installing JetBrains Mono fonts..."
apt_in fonts-jetbrains-mono 2>/dev/null || {
  echo "!! fonts-jetbrains-mono niedostępny — instalacja ręczna..."
  FONT_DIR="$HOME/.local/share/fonts/JetBrainsMono"
  mkdir -p "$FONT_DIR"
  wget -q "https://github.com/JetBrains/JetBrainsMono/releases/latest/download/JetBrainsMono.zip" \
    -O /tmp/JetBrainsMono.zip
  unzip -qo /tmp/JetBrainsMono.zip "fonts/ttf/*.ttf" -d /tmp/jbm
  mv /tmp/jbm/fonts/ttf/*.ttf "$FONT_DIR/"
  fc-cache -f
  rm -rf /tmp/JetBrainsMono.zip /tmp/jbm
}

# ---------------------------------------------------------------------------
# XDG user dirs
# ---------------------------------------------------------------------------
echo "==> Updating XDG user dirs..."
xdg-user-dirs-update

# ---------------------------------------------------------------------------
# Stow dotfiles
# ---------------------------------------------------------------------------
echo "==> Installing stow..."
apt_in stow

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
# bspwm + tabbed
# ---------------------------------------------------------------------------
echo "==> Installing bspwm..."
apt_in bspwm

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
sudo chsh "$USER" -s /usr/bin/fish && echo "Wyloguj się aby zmiana powłoki zadziałała"

echo "==> Done, uruchom ponownie komputer!"

#!/usr/bin/env bash
set -euo pipefail

### VARIABLES
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/.dotfiles"
TEMP_DIR="$(mktemp -d)"
LOG_FILE="$HOME/bspwm-install.log"

ONLY_CONFIG=false

trap 'rm -rf "$TEMP_DIR"' EXIT

### COLORS
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

msg() { echo -e "${CYAN}➜ $*${NC}"; }
err() {
  echo -e "${RED}ERROR: $*${NC}"
  exit 1
}

exec > >(tee -a "$LOG_FILE") 2>&1

### ARGUMENTS
while [[ $# -gt 0 ]]; do
  case $1 in
  --only-config) ONLY_CONFIG=true ;;
  --help)
    echo "Usage: $0 [--only-config]"
    exit 0
    ;;
  *) err "Unknown option $1" ;;
  esac
  shift
done

### DETECT DISTRO
if [[ -f /etc/os-release ]]; then
  . /etc/os-release
  case "$ID" in
  debian | ubuntu) ;;
  *) err "Unsupported distro: $ID (Debian/Ubuntu only)" ;;
  esac
else
  err "Cannot detect distro"
fi

### PACKAGES
PACKAGES=(
  xorg xbacklight xbindkeys xvkbd xinput
  build-essential bspwm sxhkd xdotool libnotify-bin
  polybar dunst feh nwg-look
  network-manager-gnome lxpolkit
  thunar thunar-archive-plugin thunar-volman
  gvfs-backends dialog mtools cifs-utils fd-find unzip
  pavucontrol pulsemixer pamixer pipewire-audio
  avahi-daemon acpi acpid xfce4-power-manager flameshot
  qimgv xdg-user-dirs-gtk fonts-font-awesome fonts-terminus
  cmake meson ninja-build curl pkg-config wget git
  picom rofi stow desktop-base
)

### INSTALL PACKAGES
install_packages() {
  msg "Updating system..."
  sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
  sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

  msg "Installing packages..."
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${PACKAGES[@]}"

  msg "Enabling services..."
  sudo systemctl enable avahi-daemon acpid
}

### INSTALL BROWSER
install_browser() {
  msg "Installing browser..."
  if apt-cache show firefox-esr >/dev/null 2>&1; then
    sudo apt install -y firefox-esr
  else
    sudo apt install -y firefox
  fi
}

### INSTALL DOTFILES (STOW)
install_dotfiles() {
  msg "Linking dotfiles using GNU Stow..."
  [ -d "$DOTFILES_DIR" ] || err ".dotfiles directory not found"
  cd "$DOTFILES_DIR"
  # Stow każdej paczki/directory w .dotfiles
  for dir in */; do
    pkg="${dir%/}"
    msg "Stowing $pkg..."
    stow -R --target="$HOME" "$pkg"
  done
}

### BUILD TABBED
build_tabbed() {
  if [[ -d "$HOME/.config/bspwm/tabbed" ]]; then
    msg "Building tabbed..."
    cd "$HOME/.config/bspwm/tabbed"
    make clean
    make
    sudo make install
  fi
}

### INSTALL GHOSTTY
install_ghostty() {
  msg "Installing ghostty..."
  wget -qO- \
    https://codeberg.org/justaguylinux/butterscripts/raw/branch/main/ghostty/install_ghostty.sh |
    bash
}

### INSTALL ST TERMINAL
install_st() {
  msg "Installing st terminal..."
  wget -O "$TEMP_DIR/install_st.sh" \
    https://codeberg.org/justaguylinux/butterscripts/raw/branch/main/st/install_st.sh
  chmod +x "$TEMP_DIR/install_st.sh"
  bash "$TEMP_DIR/install_st.sh"
}

### INSTALL FONTS
install_fonts() {
  msg "Installing Nerd Fonts..."
  wget -qO- \
    https://codeberg.org/justaguylinux/butterscripts/raw/branch/main/theming/install_nerdfonts.sh |
    bash
}

### INSTALL THEME
install_theme() {
  msg "Installing theme..."
  wget -qO- \
    https://codeberg.org/justaguylinux/butterscripts/raw/branch/main/theming/install_theme.sh |
    bash
}

### INSTALL LIGHTDM
install_dm() {
  msg "Installing LightDM..."
  wget -O "$TEMP_DIR/install_lightdm.sh" \
    https://codeberg.org/justaguylinux/butterscripts/raw/branch/main/system/install_lightdm.sh
  chmod +x "$TEMP_DIR/install_lightdm.sh"
  bash "$TEMP_DIR/install_lightdm.sh"
}

### BANNER
clear
echo -e "${CYAN}"
echo " ----------------"
echo " |   trebuhw   | "
echo " ----------------"
echo " | bspwm setup | "
echo " ----------------"
echo -e "${NC}"

read -p "Install BSPWM? (y/n) " -n 1 -r
echo
[[ ! $REPLY =~ ^[Yy]$ ]] && exit

### INSTALLATION FLOW
if [[ "$ONLY_CONFIG" = false ]]; then
  install_packages
  install_browser
  install_ghostty
  install_st
fi

install_dotfiles
build_tabbed

if [[ "$ONLY_CONFIG" = false ]]; then
  install_fonts
  install_theme
  install_dm
fi

### DONE
echo
echo -e "${GREEN}Installation complete!${NC}"
echo
echo "1. Log out"
echo "2. Select 'bspwm' in your display manager"
echo "3. Press Super+H for keybindings"
echo
echo "Log file: $LOG_FILE"

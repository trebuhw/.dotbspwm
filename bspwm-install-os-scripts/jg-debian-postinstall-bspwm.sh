#!/usr/bin/env bash

set -euo pipefail

### COLORS
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
NC="\e[0m"

### BANNER
clear
echo -e "${CYAN}"
echo " --------------------"
echo " |     trebuhw      |"
echo " --------------------"
echo " | install dotfiles |"
echo " --------------------"
echo -e "${NC}"

echo
read -rp "Install dotfiles? [y/N]: " answer

case "$answer" in
[yY] | [yY][eE][sS])
  echo -e "${GREEN}Starting installation...${NC}"
  ;;
*)
  echo -e "${RED}Installation cancelled.${NC}"
  exit 0
  ;;
esac

### LOG FILE
LOGFILE="$HOME/dotfiles_install.log"

exec > >(tee -a "$LOGFILE") 2>&1

### LOG START
echo
echo -e "${BLUE}[INFO]${NC} Dotfiles installation started: $(date)"
echo -e "${BLUE}[INFO]${NC} Log file: $LOGFILE"
echo

### LOG FUNCTIONS
info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

ok() {
  echo -e "${GREEN}[OK]${NC} $1"
}

warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

err() {
  echo -e "${RED}[ERROR]${NC} $1"
}

### BACKUP FUNCTION
backup() {
  local target="$1"

  if [ -e "$target" ]; then
    local backup="${target}.bak"

    if [ -e "$backup" ]; then
      backup="${target}.bak.$(date +%s)"
    fi

    mv "$target" "$backup"
    ok "Backup: $target -> $backup"
  else
    warn "$target not found, skipping"
  fi
}

info "Creating backups..."

# ~/
backup ~/.bash_logout
backup ~/.bashrc
backup ~/.dmrc
backup ~/.gtkrc-2.0
backup ~/.profile
backup ~/.Xresources

# ~/.config
backup ~/.config/bash
backup ~/.config/bspwm

### DOTFILES DIR
DOTDIR="$HOME/.dotbspwm"

if [ ! -d "$DOTDIR" ]; then
  err "Directory $DOTDIR does not exist"
  exit 1
fi

cd "$DOTDIR"

### CHECK STOW
if ! command -v stow >/dev/null 2>&1; then
  err "stow is not installed"
  exit 1
fi

info "Running stow..."

for pkg in \
  bash \
  bat \
  bin \
  bspwm \
  btop \
  dmrc \
  fastfetch \
  fish \
  fonts \
  geany \
  ghostty \
  gtkrc \
  icons \
  nsxiv \
  nvim \
  profile \
  themestmux \
  wallpaper \
  wezterm \
  Xresources \
  yazi \
  zathura; do
  if [ -d "$pkg" ]; then
    info "Stowing $pkg"
    stow "$pkg"
    ok "$pkg linked"
  else
    warn "Package $pkg not found"
  fi
done

echo
ok "Dotfiles installation complete"
info "Finished: $(date)"

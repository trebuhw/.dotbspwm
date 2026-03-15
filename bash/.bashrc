#!/usr/bin/env bash
# Modular .bashrc configuration

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ============================================================================
# SHELL OPTIONS
# ============================================================================

stty -ixon
shopt -s histappend checkwinsize cdspell dirspell autocd globstar nocaseglob extglob

# ============================================================================
# HISTORY CONFIGURATION
# ============================================================================

export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups
export HISTIGNORE="ls:ll:cd:pwd:exit:clear:history"
export HISTTIMEFORMAT="%F %T "
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# ============================================================================
# ENVIRONMENT VARIABLES
# ============================================================================

export PATH="$HOME/scripts:$HOME/.local/bin:/usr/local/go/bin:$HOME/.cargo/bin:$PATH"
export EDITOR=$(command -v nvim || command -v vim || command -v micro || echo nano)
export VISUAL="$EDITOR"
export LESS='-R -F -X -i -P %f (%i/%m) '
export LESSHISTFILE=/dev/null
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

# ============================================================================
# START FISH (jeśli dostępny) — rób to PRZED ładowaniem reszty configa
# ============================================================================

if command -v fish &>/dev/null && [ "$SHLVL" -eq 1 ]; then
  exec fish
fi

# ============================================================================
# LOAD MODULAR CONFIGURATIONS (tylko gdy fish niedostępny)
# ============================================================================

BASH_CONFIG_DIR="$HOME/.config/bash"

if [ -d "$BASH_CONFIG_DIR" ]; then
  for config in "$BASH_CONFIG_DIR"/*.bash; do
    [ -f "$config" ] && source "$config" || true
  done
  if [ -d "$BASH_CONFIG_DIR/functions" ]; then
    for func in "$BASH_CONFIG_DIR/functions"/*.bash; do
      [ -f "$func" ] && source "$func" || true
    done
  fi
fi

# ============================================================================
# COMPLETION
# ============================================================================

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

[ -f /usr/share/bash-completion/completions/git ] &&
  . /usr/share/bash-completion/completions/git

# ============================================================================
# LOCAL OVERRIDES
# ============================================================================

[ -f "$HOME/.bashrc.local" ] && . "$HOME/.bashrc.local"
[ -f "$HOME/.alias.bash" ] && . "$HOME/.alias.bash"

# ============================================================================
# ALIASES
# ============================================================================

source ~/.dotbspwm/fish/.config/fish/alias.fish


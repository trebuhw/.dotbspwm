# ~/.config/fish/config.fish

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# ══════════════════════════════════════════════════════════════════════════════
#  ENVIRONMENT
# ══════════════════════════════════════════════════════════════════════════════

# Starship
# set fish_greeting
# starship init fish | source

set -g STARSHIP_COMMAND_TIMEOUT 10
set -gx EDITOR nvim
set -gx GDK_BACKEND x11
set -gx MICRO_TRUECOLOR 1

# PATH
fish_add_path /usr/bin
fish_add_path /usr/local/share/bin
fish_add_path ~/.local/bin
fish_add_path ~/.local/share/bin

set -g fish_prompt_pwd_dir_length 0

# ══════════════════════════════════════════════════════════════════════════════
#  SYNTAX HIGHLIGHTING
# ══════════════════════════════════════════════════════════════════════════════

set -U fish_color_command brgreen
set -U fish_color_error brred
set -U fish_color_param white
set -U fish_color_quote yellow
set -U fish_color_comment 585858
set -U fish_color_operator brcyan
set -U fish_color_autosuggestion 585858

# ══════════════════════════════════════════════════════════════════════════════
#  PLUGINS / TOOLS
# ══════════════════════════════════════════════════════════════════════════════

# zoxide (j zamiast cd)
if type -q zoxide
    zoxide init fish --cmd j | source
end

# FZF — Catppuccin Mocha
set -Ux FZF_DEFAULT_OPTS "\
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

# ══════════════════════════════════════════════════════════════════════════════
#  ALIASES
# ══════════════════════════════════════════════════════════════════════════════

if test -f $HOME/.config/fish/alias.fish
    source $HOME/.config/fish/alias.fish
end
#if test -f $HOME/.dotfiles/fish/.config/fish/alias.fish
#    source $HOME/.dotfiles/fish/.config/fish/alias.fish
#end

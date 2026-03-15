# ~/.config/fish/conf.d/prompt.fish
# Ładowany automatycznie przy starcie sesji

# ── Session header ────────────────────────────────────────────────────────────
function fish_greeting
    # Detect window manager
    set -l wm "$XDG_CURRENT_DESKTOP"
    if test -z "$wm"; set wm "$DESKTOP_SESSION"; end
    if test -z "$wm"
        for w in dwm i3 sway openbox bspwm xfwm4 kwin mutter herbstluftwm qtile xmonad fluxbox icewm awesome jwm fvwm leftwm spectrwm ratpoison cwm wmii
            if pgrep -x "$w" &>/dev/null
                set wm "$w"
                break
            end
        end
    end
    if test -z "$wm"; set wm unknown; end

    # OS info
    set -l os    (grep "^NAME" /etc/os-release 2>/dev/null | cut -d'"' -f2)
    set -l os_id (grep "^ID="  /etc/os-release 2>/dev/null | cut -d'=' -f2)
    if test -z "$os";    set os Debian;    end
    if test -z "$os_id"; set os_id debian; end

    # OS icon (Nerd Font) — printf wymagane do unicode w Fish
    set -l os_icon (printf '\u2699')
    switch "$os_id"
        case debian;  set os_icon (printf '\uf306')
        case ubuntu;  set os_icon (printf '\uf31b')
        case arch;    set os_icon (printf '\uf303')
        case fedora;  set os_icon (printf '\uf30a')
        case manjaro; set os_icon (printf '\uf312')
    end

    # Kernel — major.minor.patch only
    set -l kernel_short (uname -r | awk -F'[.-]' '{
        if ($1 && $2 && $3) print $1"."$2"."$3
        else if ($1 && $2)  print $1"."$2
        else                print $1
    }')

    # Shell version
    set -l shell_ver (fish --version 2>&1 | grep -oP '[\d.]+' | head -1)
    if test -z "$shell_ver"; set shell_ver unknown; end

    echo -n "  "
    set_color 585858;       echo -n "─ "
    set_color ff00af;       echo -n "$os_icon "
    set_color --bold white; echo -n "$os"
    set_color 585858;       echo -n " · "
    set_color cyan;         echo -n "$kernel_short"
    set_color 585858;       echo -n " · "
    set_color yellow;       echo -n "$wm"
    set_color 585858;       echo -n " · "
    set_color magenta;      echo -n "fish $shell_ver"
    set_color 585858;       echo -n " ─"
    set_color normal
    echo -e "\n"
end

# ── Git branch helper ─────────────────────────────────────────────────────────
function _prompt_git
    git rev-parse --is-inside-work-tree &>/dev/null; or return
    set -l branch (git symbolic-ref --short HEAD 2>/dev/null)
    if test -z "$branch"
        set branch (git rev-parse --short HEAD 2>/dev/null)
    end
    test -n "$branch"; or return
    set -l dirty ""
    if git status --porcelain --ignore-submodules=dirty -uno 2>/dev/null | grep -q .
        set dirty "*"
    end
    echo -n " ($branch$dirty)"
end

# ── Command duration helper ───────────────────────────────────────────────────
function _prompt_duration
    # $CMD_DURATION jest w ms — pokazuj tylko gdy >= 1000ms
    test $CMD_DURATION -lt 1000; and return
    set -l ms $CMD_DURATION
    set -l result ""

    if test $ms -ge 3600000
        set result (math -s0 $ms / 3600000)"h "(math -s0 "$ms % 3600000 / 60000")"m"
    else if test $ms -ge 60000
        set result (math -s0 $ms / 60000)"m "(math -s0 "$ms % 60000 / 1000")"s"
    else if test $ms -ge 1000
        # Pokazuj ms tylko gdy < 10s
        if test $ms -lt 10000
            set result (math -s1 $ms / 1000)"s"
        else
            set result (math -s0 $ms / 1000)"s"
        end
    end

    echo -n " · $result"
end

# ── Main prompt ───────────────────────────────────────────────────────────────
function fish_prompt
    set -l last_status $status

    # Line 1: time  user  [ssh]  at  hostname  in  cwd  (git)  [duration]
    set_color brblack;  echo -n (date "+%T")" "
    set_color brgreen;  echo -n (whoami)

    if test -n "$SSH_CLIENT"
        echo -n " "
        set_color brred; echo -n "[ssh]"
    end

    set_color brwhite;  echo -n " at "
    set_color bryellow; echo -n (hostname -s)
    set_color brwhite;  echo -n " in "
    set_color brblue;   echo -n (prompt_pwd)
    set_color brcyan;   echo -n (_prompt_git)
    set_color 585858;   echo -n (_prompt_duration)
    set_color normal
    echo ""

    # Line 2: ✔/✘  $
    if test $last_status -eq 0
        set_color brgreen; echo -n "✔ "
    else
        set_color brred;   echo -n "✘ $last_status "
    end
    set_color brcyan; echo -n "\$ "
    set_color normal
end

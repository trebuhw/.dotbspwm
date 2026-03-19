#!/bin/bash

HISTORY_FILE="$HOME/.clipboard_history"
MAX_ENTRIES=50
ROFI_PROMPT="Wybierz wpis do schowka:"

# Funkcja dodająca wpis do historii
add_to_history() {
  local entry="$1"
  if [ -n "$entry" ] && ! grep -Fxq "$entry" "$HISTORY_FILE" 2>/dev/null; then
    echo "$entry" >>"$HISTORY_FILE"
    tail -n $MAX_ENTRIES "$HISTORY_FILE" >"$HISTORY_FILE.tmp" && mv "$HISTORY_FILE.tmp" "$HISTORY_FILE"
  fi
}

# Funkcja wyświetlająca menu rofi
show_menu() {
  echo "🧹 Wyczyść schowek" >>"$HISTORY_FILE"

  selected=$(tac "$HISTORY_FILE" | rofi -dmenu \
    -i \
    -lines 10 \
    -p "$ROFI_PROMPT" \
    -theme ~/.config/bspwm/rofi/config.rasi)

  sed -i '/🧹 Wyczyść schowek$/d' "$HISTORY_FILE"

  if [ "$selected" == "🧹 Wyczyść schowek" ]; then
    echo -n "" | xclip -selection clipboard
    echo -n "" | xclip -selection primary
    >"$HISTORY_FILE"

  elif [ -n "$selected" ]; then
    echo -n "$selected" | xclip -selection clipboard
    echo -n "$selected" | xclip -selection primary
  fi
}

# Jeśli uruchomiony z argumentem "menu"
if [ "$1" == "menu" ]; then
  show_menu
  exit 0
fi

# Daemon w tle – nasłuchuje obu schowków
last_clip=""
mkdir -p "$(dirname "$HISTORY_FILE")"
touch "$HISTORY_FILE"

while true; do
  clip_clipboard=$(xclip -o -selection clipboard 2>/dev/null)
  clip_primary=$(xclip -o -selection primary 2>/dev/null)

  current_clip="$clip_clipboard"
  [ -z "$current_clip" ] && current_clip="$clip_primary"

  if [ -n "$current_clip" ] && [ "$current_clip" != "$last_clip" ]; then
    last_clip="$current_clip"
    add_to_history "$current_clip"
  fi

  sleep 0.5
done

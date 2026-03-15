#!/usr/bin/env bash

# ==========================================================
#  SKRYPT BACKUPU – SYNC STANU FAKTYCZNEGO
# ==========================================================
#
# Ten skrypt kopiuje katalogi źródłowe do backupu lokalnego i na pendrive,
# synchronizując stan faktyczny: jeśli plik/katalog został usunięty w źródle,
# zostanie usunięty także z backupu (opcja --delete).
#
# Jak używać:
# chmod +x backup.sh
# ./backup.sh [ścieżka_do_pendrive]
#
# Wykluczenia można ustawić w EXCLUDES. Wykluczone pliki/katalogi nie będą usuwane.
# ==========================================================

set -o pipefail

# =========================
# KONFIGURACJA
# =========================

RSYNC_OPTS_LOCAL=(-av --delete)                                                       # backup lokalny z synchronizacją
RSYNC_OPTS_REMOTE=(-av --delete --no-perms --no-owner --no-group --copy-unsafe-links) # backup na pendrive

LOCAL_BACKUP="$HOME/Backup"
REMOTE_BACKUP="${1:-/run/media/hubert/Ventoy/Omarchy/Backup}"

SOURCES=(
  "$HOME/Szablony $LOCAL_BACKUP/Szablony"
  "$HOME/Dokumenty $LOCAL_BACKUP/Dokumenty"
  "$HOME/Obrazy $LOCAL_BACKUP/Obrazy"
  "$HOME/.git-credentials $LOCAL_BACKUP/.git-credentials"
  "$HOME/.gitconfig $LOCAL_BACKUP/.gitconfig"
  "$HOME/.ssh $LOCAL_BACKUP/.ssh"
  "$HOME/.local/share/bin/backup-restore.sh $LOCAL_BACKUP/"
)

# Wykluczenia dla każdego źródła (w tej samej kolejności co SOURCES)
EXCLUDES=(
  ""               # .config/chromium
  ""               # Szablony
  "tmp sekret.txt" # Dokumenty
  ""               # Obrazy
  ""               # .git-credentials
  ""               # .gitconfig
  ""               # .ssh
  ""               # backup-restore.sh
)

# Wykluczenia dodatkowe dla pendrive (symlinki Chromium)
PENDRIVE_EXCLUDES=(
  "SingletonCookie"
  "SingletonLock"
  "SingletonSocket"
)

LOG_FILE="$HOME/Backup/backup_errors.log"

# =========================
# FUNKCJA BACKUPU
# =========================
backup_to() {
  local DEST="$1"
  local -n OPTS="$2"
  local -n P_EXCLUDES="$3"

  echo ">>> Backup do: $DEST"

  for i in "${!SOURCES[@]}"; do
    entry="${SOURCES[$i]}"
    SRC="${entry%% *}"
    LOCAL_TARGET="${entry##* }"

    # docelowa ścieżka w tym backupie
    if [[ "$DEST" == "$LOCAL_BACKUP" ]]; then
      TARGET="$LOCAL_TARGET"
    else
      TARGET="$DEST/${LOCAL_TARGET#$LOCAL_BACKUP/}"
    fi

    if [[ ! -e "$SRC" ]]; then
      echo "⚠ Pomijam – źródło nie istnieje: $SRC"
      continue
    fi

    echo "Backup:"
    echo "  Źródło : $SRC"
    echo "  Cel    : $TARGET"

    if [[ -d "$SRC" ]]; then
      mkdir -p "$TARGET"
    else
      mkdir -p "$(dirname "$TARGET")"
    fi

    # przygotowanie wykluczeń jako tablica
    RSYNC_EXCLUDES=()

    for excl in ${EXCLUDES[$i]}; do
      [[ -n "$excl" ]] && RSYNC_EXCLUDES+=(--exclude "$excl")
    done

    for excl in "${P_EXCLUDES[@]}"; do
      [[ -n "$excl" ]] && RSYNC_EXCLUDES+=(--exclude "$excl")
    done

    # wykonanie backupu i logowanie błędów
    if [[ -d "$SRC" ]]; then
      rsync "${OPTS[@]}" "${RSYNC_EXCLUDES[@]}" \
        "$SRC/" "$TARGET/" 2>>"$LOG_FILE"
    else
      rsync "${OPTS[@]}" "${RSYNC_EXCLUDES[@]}" \
        "$SRC" "$TARGET" 2>>"$LOG_FILE"
    fi

    echo "  ✔ Zakończono"
  done
}

# =========================
# BACKUP LOKALNY
# =========================
mkdir -p "$LOCAL_BACKUP"
: >"$LOG_FILE"

backup_to "$LOCAL_BACKUP" RSYNC_OPTS_LOCAL EXCLUDES

# =========================
# BACKUP NA PENDRIVE (jeśli podłączony)
# =========================
if [[ -d "$(dirname "$REMOTE_BACKUP")" ]]; then
  mkdir -p "$REMOTE_BACKUP"
  backup_to "$REMOTE_BACKUP" RSYNC_OPTS_REMOTE PENDRIVE_EXCLUDES
else
  echo ">>> Pendrive nie jest podłączony. Backup tylko lokalny."
fi

echo ">>> Backup zakończony"
echo ">>> Szczegóły błędów (jeśli wystąpiły) w $LOG_FILE"

bat "$LOG_FILE" 2>/dev/null || cat "$LOG_FILE"

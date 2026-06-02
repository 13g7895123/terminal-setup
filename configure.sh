#!/usr/bin/env bash
# configure.sh — 套用 oh-my-posh 設定
# - 複製 themes/jandedobbeleer-multiline.omp.json 到 ~/.poshthemes
# - 在 ~/.bashrc 寫入 oh-my-posh init（已存在則跳過）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_DIR="$HOME/.poshthemes"
THEME_NAME="jandedobbeleer-multiline.omp.json"
THEME_SRC="$SCRIPT_DIR/themes/$THEME_NAME"
THEME_DST="$THEMES_DIR/$THEME_NAME"
BASHRC="$HOME/.bashrc"
INIT_LINE='eval "$(oh-my-posh init bash --config ~/.poshthemes/'"$THEME_NAME"')"'
MARKER="# >>> oh-my-posh init (terminal-setup) >>>"
MARKER_END="# <<< oh-my-posh init (terminal-setup) <<<"

log()  { printf '\033[36m[configure]\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[configure]\033[0m %s\n' "$*"; }
err()  { printf '\033[31m[configure]\033[0m %s\n' "$*" >&2; }

check_prereq() {
  if ! command -v oh-my-posh >/dev/null 2>&1; then
    err "找不到 oh-my-posh，請先執行 ./install.sh"
    exit 1
  fi
}

copy_theme() {
  mkdir -p "$THEMES_DIR"
  if [ ! -f "$THEME_SRC" ]; then
    err "找不到主題檔: $THEME_SRC"
    exit 1
  fi
  if [ -f "$THEME_DST" ] && cmp -s "$THEME_SRC" "$THEME_DST"; then
    log "主題已是最新，略過複製"
  else
    cp "$THEME_SRC" "$THEME_DST"
    log "已複製主題 → $THEME_DST"
  fi
}

patch_bashrc() {
  if [ ! -f "$BASHRC" ]; then
    log "建立新的 $BASHRC"
    touch "$BASHRC"
  fi

  if grep -Fq "$INIT_LINE" "$BASHRC"; then
    log "~/.bashrc 已包含 oh-my-posh init，略過"
    return 0
  fi

  # 備份
  local backup="$BASHRC.bak.$(date +%Y%m%d%H%M%S)"
  cp "$BASHRC" "$backup"
  log "已備份 $BASHRC → $backup"

  {
    echo ""
    echo "$MARKER"
    echo "$INIT_LINE"
    echo "$MARKER_END"
  } >> "$BASHRC"
  log "已寫入 oh-my-posh init 到 $BASHRC"
}

main() {
  check_prereq
  copy_theme
  patch_bashrc
  log "完成。請開新的 bash 視窗，或執行: source ~/.bashrc"
}

main "$@"

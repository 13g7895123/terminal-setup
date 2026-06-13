#!/usr/bin/env bash
# configure.sh — 套用 oh-my-posh 設定
# - 複製 themes/jandedobbeleer-multiline.omp.json 到 ~/.poshthemes
# - 在 shell rc 檔（~/.zshrc 或 ~/.bashrc）寫入 oh-my-posh init（已存在則跳過）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_DIR="$HOME/.poshthemes"
THEME_NAME="jandedobbeleer-multiline.omp.json"
THEME_SRC="$SCRIPT_DIR/themes/$THEME_NAME"
THEME_DST="$THEMES_DIR/$THEME_NAME"
MARKER="# >>> oh-my-posh init (terminal-setup) >>>"
MARKER_END="# <<< oh-my-posh init (terminal-setup) <<<"

log()  { printf '\033[36m[configure]\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[configure]\033[0m %s\n' "$*"; }
err()  { printf '\033[31m[configure]\033[0m %s\n' "$*" >&2; }

# 偵測 shell
SHELL_NAME="$(basename "${SHELL:-bash}")"
case "$SHELL_NAME" in
  zsh)  RC_FILE="$HOME/.zshrc" ;;
  bash) RC_FILE="$HOME/.bashrc" ;;
  *)
    warn "未知 shell: $SHELL_NAME，退回使用 ~/.profile"
    RC_FILE="$HOME/.profile"
    ;;
esac

# 偵測 binary（macOS 裝到 ~/.local/bin，Linux 裝到 /usr/local/bin）
if   [ -x "$HOME/.local/bin/oh-my-posh" ]; then POSH_BIN="$HOME/.local/bin/oh-my-posh"
elif [ -x "/usr/local/bin/oh-my-posh" ];   then POSH_BIN="/usr/local/bin/oh-my-posh"
elif command -v oh-my-posh >/dev/null 2>&1; then POSH_BIN="$(command -v oh-my-posh)"
else POSH_BIN=""
fi

INIT_LINE="eval \"\$($POSH_BIN init $SHELL_NAME --config $THEME_DST)\""

check_prereq() {
  if [ -z "$POSH_BIN" ]; then
    err "找不到 oh-my-posh，請先執行 ./install.sh"
    exit 1
  fi
  log "偵測到 oh-my-posh: $POSH_BIN (版本 $("$POSH_BIN" --version 2>/dev/null || echo unknown))"
  log "目標 shell: $SHELL_NAME → $RC_FILE"
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

patch_rc() {
  if [ ! -f "$RC_FILE" ]; then
    log "建立新的 $RC_FILE"
    touch "$RC_FILE"
  fi

  # 用 marker 判斷是否已寫入（比對整行內容更穩健）
  if grep -Fq "$MARKER" "$RC_FILE"; then
    log "$RC_FILE 已包含 oh-my-posh init，略過"
    return 0
  fi

  local backup="$RC_FILE.bak.$(date +%Y%m%d%H%M%S)"
  cp "$RC_FILE" "$backup"
  log "已備份 $RC_FILE → $backup"

  {
    echo ""
    echo "$MARKER"
    echo "$INIT_LINE"
    echo "$MARKER_END"
  } >> "$RC_FILE"
  log "已寫入 oh-my-posh init 到 $RC_FILE"
}

main() {
  check_prereq
  copy_theme
  patch_rc
  log "完成。請執行: source $RC_FILE"
}

main "$@"

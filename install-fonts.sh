#!/usr/bin/env bash
# install-fonts.sh — 安裝 Meslo Nerd Font（與目前主機相同）
# 將字型安裝到 ~/.local/share/fonts，並更新 fontconfig 快取
# WSL 使用者：字型需在 Windows 端安裝才會被 Windows Terminal 顯示，
# 本腳本會把 ZIP 同步複製到 Windows 使用者目錄並提示如何安裝。

set -euo pipefail

FONT_DIR="$HOME/.local/share/fonts"
FONT_NAME="Meslo"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${FONT_NAME}.zip"

log()  { printf '\033[36m[fonts]\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[fonts]\033[0m %s\n' "$*"; }
err()  { printf '\033[31m[fonts]\033[0m %s\n' "$*" >&2; }

ensure_basics() {
  local missing=()
  for c in curl unzip fc-cache; do
    command -v "$c" >/dev/null 2>&1 || missing+=("$c")
  done
  if [ "${#missing[@]}" -gt 0 ]; then
    log "安裝必要套件: ${missing[*]} (含 fontconfig)"
    if command -v apt-get >/dev/null 2>&1; then
      sudo apt-get update -y
      # fc-cache 由 fontconfig 提供
      sudo apt-get install -y curl unzip fontconfig
    else
      err "請手動安裝: curl unzip fontconfig"
      exit 1
    fi
  fi
}

check_existing() {
  if fc-list 2>/dev/null | grep -qi "Meslo.*Nerd Font"; then
    local n
    n=$(fc-list 2>/dev/null | grep -ci "Meslo.*Nerd Font")
    log "Meslo Nerd Font 已安裝 ($n 個字型檔)，略過下載"
    return 0
  fi
  return 1
}

install_linux_fonts() {
  if check_existing; then
    return 0
  fi
  mkdir -p "$FONT_DIR"
  local tmp
  tmp=$(mktemp -d)
  log "下載 $FONT_NAME Nerd Font"
  curl -fsSL "$FONT_URL" -o "$tmp/${FONT_NAME}.zip"
  log "解壓到 $FONT_DIR"
  unzip -o "$tmp/${FONT_NAME}.zip" -d "$FONT_DIR" >/dev/null
  rm -rf "$tmp"
  log "更新 fontconfig 快取"
  fc-cache -f "$FONT_DIR" >/dev/null
  log "Linux 端已安裝 $(fc-list 2>/dev/null | grep -ci "Meslo.*Nerd Font") 個 Meslo Nerd Font 字型"
}

sync_to_windows() {
  # WSL 才需要：把 ZIP 放到 Windows 端讓使用者點兩下安裝
  if ! grep -qi "microsoft" /proc/version 2>/dev/null; then
    return 0
  fi
  local win_user win_home
  win_user=$(/mnt/c/Windows/System32/cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r\n ')
  if [ -z "$win_user" ]; then
    warn "無法解析 Windows 使用者名稱，略過 Windows 端字型複製"
    return 0
  fi
  win_home="/mnt/c/Users/$win_user"
  if [ ! -d "$win_home" ]; then
    warn "找不到 Windows 使用者目錄: $win_home"
    return 0
  fi
  local target="$win_home/Downloads/NerdFonts-${FONT_NAME}.zip"
  log "下載 ZIP 到 Windows: $target（供 Windows 端安裝）"
  curl -fsSL "$FONT_URL" -o "$target"
  cat <<EOF

  ── Windows 端安裝步驟 ─────────────────────────
  1. 開啟檔案總管，到 C:\\Users\\${win_user}\\Downloads
  2. 解壓 NerdFonts-${FONT_NAME}.zip
  3. 全選 *.ttf → 右鍵 → 為所有使用者安裝
  4. Windows Terminal → 設定 → 選定設定檔 → 外觀
     → 字體選 "MesloLGM Nerd Font" (或其他 Meslo 變體)
  ──────────────────────────────────────────────

EOF
}

main() {
  ensure_basics
  install_linux_fonts
  sync_to_windows
  log "完成"
}

main "$@"

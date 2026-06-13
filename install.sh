#!/usr/bin/env bash
# install.sh — 安裝 oh-my-posh + 全部官方主題（與目前主機相同）
# - 安裝 oh-my-posh 到 /usr/local/bin
# - 下載並解壓官方主題到 ~/.poshthemes
# - 不修改 ~/.bashrc，套用設定請執行 configure.sh

set -euo pipefail

THEMES_DIR="$HOME/.poshthemes"
TARGET_VERSION="${OMP_VERSION:-}"   # 可選：指定版本，空字串=最新

# macOS 官方安裝腳本預設裝到 ~/.local/bin，Linux 裝到 /usr/local/bin
_resolve_posh_bin() {
  if   [ -x "$HOME/.local/bin/oh-my-posh" ]; then echo "$HOME/.local/bin/oh-my-posh"
  elif [ -x "/usr/local/bin/oh-my-posh" ];   then echo "/usr/local/bin/oh-my-posh"
  elif command -v oh-my-posh >/dev/null 2>&1; then command -v oh-my-posh
  else echo "/usr/local/bin/oh-my-posh"   # 預設安裝目標
  fi
}
POSH_BIN="$(_resolve_posh_bin)"

log()  { printf '\033[36m[install]\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[install]\033[0m %s\n' "$*"; }
err()  { printf '\033[31m[install]\033[0m %s\n' "$*" >&2; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    err "缺少必要指令: $1"
    return 1
  }
}

ensure_basics() {
  local missing=()
  for c in curl unzip; do
    command -v "$c" >/dev/null 2>&1 || missing+=("$c")
  done
  if [ "${#missing[@]}" -gt 0 ]; then
    log "安裝必要套件: ${missing[*]}"
    if command -v apt-get >/dev/null 2>&1; then
      sudo apt-get update -y
      sudo apt-get install -y "${missing[@]}"
    else
      err "請手動安裝: ${missing[*]}"
      exit 1
    fi
  fi
}

install_oh_my_posh() {
  if [ -x "$POSH_BIN" ]; then
    local cur
    cur="$("$POSH_BIN" --version 2>/dev/null || echo unknown)"
    log "oh-my-posh 已安裝於 $POSH_BIN (版本 $cur)，略過。如需重裝請先刪除該 binary"
    return 0
  fi
  log "安裝 oh-my-posh 到 $POSH_BIN"
  # 官方安裝腳本：會把 binary 放到 /usr/local/bin，並下載主題到 ~/.poshthemes
  if [ -n "$TARGET_VERSION" ]; then
    curl -fsSL https://ohmyposh.dev/install.sh | sudo bash -s -- -v "$TARGET_VERSION"
  else
    curl -fsSL https://ohmyposh.dev/install.sh | sudo bash -s
  fi
}

install_themes() {
  mkdir -p "$THEMES_DIR"
  # 官方安裝腳本通常已下載主題；若沒有再補抓 themes.zip
  local count
  count=$(find "$THEMES_DIR" -maxdepth 1 -name "*.omp.json" -o -name "*.omp.yaml" -o -name "*.omp.toml" 2>/dev/null | wc -l)
  if [ "$count" -ge 50 ]; then
    log "主題庫已存在 ($count 個)，略過下載"
    return 0
  fi
  log "下載官方主題包 themes.zip"
  local tmp
  tmp=$(mktemp -d)
  curl -fsSL https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -o "$tmp/themes.zip"
  unzip -o "$tmp/themes.zip" -d "$THEMES_DIR" >/dev/null
  chmod -R u+rw "$THEMES_DIR"
  rm -rf "$tmp"
  log "主題已解壓到 $THEMES_DIR"
}

main() {
  ensure_basics
  install_oh_my_posh
  # 安裝後重新偵測（安裝腳本可能改變了路徑）
  POSH_BIN="$(_resolve_posh_bin)"
  install_themes
  log "完成。oh-my-posh 路徑: $POSH_BIN，版本: $("$POSH_BIN" --version 2>/dev/null || echo unknown)"
  log "下一步：執行 configure.sh 套用主題"
}

main "$@"

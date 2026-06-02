#!/usr/bin/env bash
# setup.sh — 一鍵安裝 + 設定（含字型）
# 依序執行：install-fonts.sh → install.sh → configure.sh
#
# 用法：
#   ./setup.sh              # 全部跑（含字型）
#   ./setup.sh --no-fonts   # 跳過字型安裝
#   OMP_VERSION=v25.0.0 ./setup.sh   # 指定 oh-my-posh 版本

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log()  { printf '\033[1;36m[setup]\033[0m %s\n' "$*"; }
step() { printf '\n\033[1;35m── %s ──\033[0m\n' "$*"; }

WITH_FONTS=1
for arg in "$@"; do
  case "$arg" in
    --no-fonts) WITH_FONTS=0 ;;
    -h|--help)
      sed -n '2,10p' "$0"
      exit 0
      ;;
    *) ;;
  esac
done

if [ "$WITH_FONTS" -eq 1 ]; then
  step "Step 1/3 安裝 Meslo Nerd Font"
  bash "$SCRIPT_DIR/install-fonts.sh"
else
  log "已指定 --no-fonts，略過字型安裝"
fi

step "Step 2/3 安裝 oh-my-posh + 主題庫"
bash "$SCRIPT_DIR/install.sh"

step "Step 3/3 套用主題與寫入 ~/.bashrc"
bash "$SCRIPT_DIR/configure.sh"

step "全部完成"
log "請開新的 bash 視窗，或執行: source ~/.bashrc"
log "若提示字元的圖示顯示為方塊，請確認終端機已切換至 Meslo Nerd Font"

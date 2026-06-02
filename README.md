# terminal-setup

複製本機（jarvis WSL）的 terminal 美化環境到別台 Linux/WSL：
**oh-my-posh** + **jandedobbeleer-multiline** 主題 + **Meslo Nerd Font**。

## 內容

| 檔案 | 用途 |
| --- | --- |
| `setup.sh` | 一鍵跑完全部（字型 + 安裝 + 設定） |
| `install-fonts.sh` | 下載並安裝 Meslo Nerd Font；WSL 環境會同步 ZIP 到 Windows Downloads |
| `install.sh` | 安裝 oh-my-posh 與全部官方主題庫 |
| `configure.sh` | 複製主題到 `~/.poshthemes` 並把 init 寫入 `~/.bashrc` |
| `themes/jandedobbeleer-multiline.omp.json` | 目前使用中的主題（與本機一致） |

## 快速使用

```bash
# 全部一次裝好（含字型）
bash setup.sh

# 不裝字型（已有 Nerd Font）
bash setup.sh --no-fonts

# 指定 oh-my-posh 版本
OMP_VERSION=v25.0.0 bash setup.sh
```

完成後開新的 bash 視窗即可看到效果。Windows Terminal 還要記得把字型切到 `MesloLGM Nerd Font`（或任一 Meslo 變體）。

## 個別執行

```bash
bash install-fonts.sh   # 只裝字型
bash install.sh         # 只裝 oh-my-posh
bash configure.sh       # 只套用主題設定
```

## 移除

```bash
sudo rm /usr/local/bin/oh-my-posh
rm -rf ~/.poshthemes ~/.cache/oh-my-posh
# 編輯 ~/.bashrc 移除 # >>> oh-my-posh init (terminal-setup) >>> 區塊
```

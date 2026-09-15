#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
DSH_VERSION="0.1.5-rc.1"

echo "======================================"
echo "  DeepSeek Harness 一鍵啟動"
echo "======================================"

if ! command -v node >/dev/null 2>&1; then
  echo "❌ 找不到 Node.js，請先安裝 Node.js 22.19 以上或 24 以上版本：https://nodejs.org/"
  exit 1
fi
node_major="$(node -p 'process.versions.node.split(".")[0]')"
if [ "$node_major" -lt 22 ]; then
  echo "⚠️  目前 Node 版本為 ${node_major}，建議使用 22 或更新版本。"
fi

if [ ! -f .env ]; then
  cp .env.example .env
  echo "📝 已建立 .env：請把 DEEPSEEK_API_KEY 替換成你的真實金鑰，儲存後再執行 bash install.sh"
  exit 0
fi

if grep -q "sk-xxxxxxxx" .env; then
  echo "📝 .env 裡仍是預留的金鑰，請填入真實金鑰後再執行 bash install.sh"
  exit 1
fi

if ! command -v dsh >/dev/null 2>&1; then
  echo "📦 正在安裝 @deepseek-ai/dsh@${DSH_VERSION} ..."
  if ! npm install -g "@deepseek-ai/dsh@${DSH_VERSION}"; then
    echo "❌ 安裝失敗。若是 EACCES 權限錯誤，建議改用 nvm 安裝 Node，或把 npm 全域目錄設到使用者目錄，不建議直接使用 sudo。"
    exit 1
  fi
fi

mkdir -p workspace

echo "🚀 正在啟動 dsh web（會自動開啟瀏覽器，網址也會顯示在下方；按 Ctrl+C 停止）"
exec dsh web

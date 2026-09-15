#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
DSH_VERSION="0.1.5-rc.1"

echo "======================================"
echo "  DeepSeek Harness 一键启动"
echo "======================================"

if ! command -v node >/dev/null 2>&1; then
  echo "❌ 未找到 Node.js，请先安装 Node.js 22 LTS 或更新版本：https://nodejs.org/"
  exit 1
fi
node_major="$(node -p 'process.versions.node.split(".")[0]')"
if [ "$node_major" -lt 22 ]; then
  echo "⚠️  当前 Node 版本为 ${node_major}，建议使用 22 或更新版本。"
fi

if [ ! -f .env ]; then
  cp .env.example .env
  echo "📝 已创建 .env：把 DEEPSEEK_API_KEY 换成你的真实 Key，保存后再运行 bash install.sh"
  exit 0
fi

if grep -q "sk-xxxxxxxx" .env; then
  echo "📝 .env 里还是占位 Key，请填入真实 Key 后再运行 bash install.sh"
  exit 1
fi

if ! command -v dsh >/dev/null 2>&1; then
  echo "📦 正在安装 @deepseek-ai/dsh@${DSH_VERSION} ..."
  if ! npm install -g "@deepseek-ai/dsh@${DSH_VERSION}"; then
    echo "❌ 安装失败。如果是 EACCES 权限错误，建议用 nvm 安装 Node，或把 npm 全局目录设到用户目录，不建议直接 sudo。"
    exit 1
  fi
fi

mkdir -p workspace

echo "🚀 正在启动 dsh web（会自动打开浏览器，地址也会打印在下面；Ctrl+C 停止）"
exec dsh web

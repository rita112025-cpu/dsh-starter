# Create-DSH-Starter.ps1 - 生成 dsh-starter 文件夹和 dsh-starter.zip
# 适配 @deepseek-ai/dsh 0.1.5-rc.1
#
# 用法（Windows PowerShell 5.1 / PowerShell 7 均可）：
#   powershell -ExecutionPolicy Bypass -File .\Create-DSH-Starter.ps1
#
# 注意：本脚本文件需保持「UTF-8 with BOM」编码，否则 Windows PowerShell 5.1 会把中文读成乱码。

$ErrorActionPreference = 'Stop'
$base      = (Get-Location).ProviderPath
$root      = 'dsh-starter'
$rootPath  = Join-Path $base $root
$zipPath   = Join-Path $base "$root.zip"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false

Write-Host '======================================' -ForegroundColor Cyan
Write-Host '  创建 DeepSeek Harness 入门模板' -ForegroundColor Cyan
Write-Host '======================================' -ForegroundColor Cyan
if (Test-Path -LiteralPath $rootPath) {
    Write-Host "[提示] $root 已存在，模板文件会被覆盖（你的 .env 不会被动）。" -ForegroundColor Yellow
}

# 统一写成 UTF-8 无 BOM，并按文件类型控制换行符：
#   .bat 用 CRLF；.sh 必须是 LF，否则 bash 报 $'\r': command not found
# 用绝对路径，因为 .NET 的当前目录不一定等于 PowerShell 的当前目录。
# 写出的文件记在 $written 里，打包时只打包这些。
$written = [ordered]@{}
function Write-StarterFile {
    param(
        [Parameter(Mandatory)] [string] $RelPath,
        [Parameter(Mandatory)] [string] $Content,
        [ValidateSet('LF', 'CRLF')] [string] $Eol = 'LF'
    )
    $full = [System.IO.Path]::Combine($rootPath, ($RelPath -replace '/', [System.IO.Path]::DirectorySeparatorChar))
    $dir = [System.IO.Path]::GetDirectoryName($full)
    [void][System.IO.Directory]::CreateDirectory($dir)
    $text = $Content -replace "`r`n", "`n"
    if (-not $text.EndsWith("`n")) { $text += "`n" }
    if ($Eol -eq 'CRLF') { $text = $text -replace "`n", "`r`n" }
    [System.IO.File]::WriteAllText($full, $text, $utf8NoBom)
    $written[$RelPath] = $full
    Write-Host "  + $RelPath"
}

Write-StarterFile -RelPath 'README.md' -Eol LF -Content @'
# DeepSeek Harness 入门模板包

基于 `@deepseek-ai/dsh` **0.1.5-rc.1**（2026-09 的 npm `latest`，仍是预发布版）。

## 前置条件

- Node.js 22.19 或更新的 22.x，或 Node.js 24 及以上（https://nodejs.org/）
- DeepSeek API Key
- 只从 npm 或官方仓库 https://github.com/deepseek-ai/deepseek-harness 获取 dsh

## 快速开始

1. 解压后进入 `dsh-starter` 文件夹（Windows「全部解压缩」会多套一层 `dsh-starter\dsh-starter`，进最里面那层）
2. 第一次运行启动脚本，它会从 `.env.example` 生成 `.env` 并提示你填 Key：
   - Windows：双击 `install.bat`
   - macOS / Linux：`bash install.sh`
3. 把 `.env` 里的 `sk-xxxxxxxx...` 换成你的真实 Key，保存
4. 再运行一次启动脚本：没装 dsh 时会先装，然后执行 `dsh web`
5. 浏览器会自动打开；没打开时，复制终端里 `dsh web:` 开头那一行的**完整地址**

> 默认地址是 `127.0.0.1:3080`。**3080 被占用时 dsh 会直接启动失败**，不会自动换端口：改用 `dsh web --port 8080`，或 `dsh web --port 0` 让系统挑一个空闲端口。
> 地址里带一次性认证参数，只输 `127.0.0.1:端口` 进不去。

## 试用示例技能

在 Web 界面里说：

```
用 doc-summary 技能总结 workspace/note.md
```

## 目录说明

```
dsh-starter/
├── README.md
├── .env.example                      → 复制为 .env，填 DEEPSEEK_API_KEY
├── .gitignore                        → 防止 .env 被提交
├── install.bat / install.sh          → 检查环境 + 安装 + 启动 dsh web
├── .dsh/skills/doc-summary/SKILL.md  → 示例技能（项目级技能目录）
└── workspace/note.md                 → 示例文档
```

## 常用命令（都要在本文件夹里执行）

```bash
dsh web                                   # 启动浏览器界面
dsh web --port 8080                       # 指定端口（--port 0 = 系统挑空闲端口）
dsh web --no-open                         # 不自动打开浏览器
dsh --profile headless "用 doc-summary 技能总结 workspace/note.md"   # 一次性任务：结果输出到终端后退出
dsh --help                                # 启动器帮助
dsh web --help                            # Web 应用自己的参数
npx @deepseek-ai/dsh@0.1.5-rc.1 web       # 不想全局安装时临时运行（同样要在本文件夹里执行）
```

## 需要知道的几件事

- dsh 只读取**启动目录**里的 `.env`（不往上级目录找），再加上 `~/.dsh/.env`。启动脚本会先切换到本文件夹，所以请用启动脚本或在本文件夹里运行。
- Key 的优先级：系统环境变量 > 在 dsh 里保存过的 Key（`~/.dsh/.credentials.yaml`）> 本文件夹 `.env` > `~/.dsh/.env`。改了 `.env` 却不生效，先检查前两处；环境变量即使设成空值也会挡住 `.env`。
- 启动目录是默认工作目录；在 Web 界面里，每个会话用的是你在界面里选的项目文件夹。
- 技能从「项目根目录」下的 `.dsh/skills/<名字>/SKILL.md` 读取。项目根目录是**最近一个含 `.git` 的上级目录**，找不到才用当前目录。所以如果你把本文件夹放进了某个 git 仓库的子目录，请把 `.dsh/skills` 挪到那个仓库根目录。
- 新增或修改技能不需要重启；`SKILL.md` 开头的 `name`（小写字母、数字、短横线）和 `description` 是必填项，`whenToUse` 可选。
- 个人全局技能可放在 `~/.dsh/skills/`；dsh 自己的配置在 `~/.dsh/profiles/web/cordis.patch.yml`，入门阶段不用改。
- `.env` 含密钥：不要提交、不要发给别人。生成器打包的 ZIP 只含模板文件，不含 `.env`；直接分享本文件夹前请自己检查。
- 升级 dsh：`npm install -g @deepseek-ai/dsh@<版本号>`，并同步修改两个启动脚本里的 `DSH_VERSION`。注意：版本号只锁住 dsh 本体，它依赖的 `@deepseek-ai/dsh-*` 子包写的是 `^` 范围，安装时会取当时最新的兼容预发布版（例如 rc.1 本体会装到 rc.2 的子包）。
'@

Write-StarterFile -RelPath '.env.example' -Eol LF -Content @'
# DeepSeek Harness environment file
# 复制为 .env 后，把下面的占位符换成你的 DeepSeek API Key。
# 注意：不要把 .env 提交到 git，也不要发给别人。
DEEPSEEK_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxx
'@

Write-StarterFile -RelPath '.gitignore' -Eol LF -Content @'
# 密钥
.env
.env.*
!.env.example

# dsh 运行时数据（只保留技能）
.dsh/*
!.dsh/skills/

# 依赖、日志、系统文件
node_modules/
*.log
.DS_Store
Thumbs.db
'@

Write-StarterFile -RelPath 'install.bat' -Eol CRLF -Content @'
@echo off
setlocal
rem Messages are ASCII on purpose: cmd.exe mis-parses non-ASCII text in some code pages.
cd /d "%~dp0"
set "DSH_VERSION=0.1.5-rc.1"

echo ======================================
echo   DeepSeek Harness Starter
echo ======================================

where node >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Node.js not found. Install Node.js 22.19+ or 24+ from https://nodejs.org/
    pause
    exit /b 1
)
for /f "tokens=1 delims=v." %%v in ('node -v') do set "NODE_MAJOR=%%v"
if %NODE_MAJOR% LSS 22 echo [WARN] Node %NODE_MAJOR% detected. Node 22 or newer is recommended.

if not exist ".env" (
    copy /y ".env.example" ".env" >nul
    echo [TODO] Created .env - paste your DeepSeek API key into it, save, then run install.bat again.
    start "" notepad ".env"
    pause
    exit /b 0
)

findstr /c:"sk-xxxxxxxx" ".env" >nul
if not errorlevel 1 (
    echo [TODO] .env still contains the placeholder key. Edit it, save, then run install.bat again.
    start "" notepad ".env"
    pause
    exit /b 1
)

where dsh >nul 2>nul
if errorlevel 1 (
    echo Installing @deepseek-ai/dsh@%DSH_VERSION% ...
    call npm install -g @deepseek-ai/dsh@%DSH_VERSION%
    if errorlevel 1 (
        echo [ERROR] npm install failed. See the messages above.
        pause
        exit /b 1
    )
)

if not exist "workspace" mkdir "workspace"

echo Starting dsh web. The browser opens automatically; the URL is also printed below.
echo Press Ctrl+C to stop.
call dsh web
if errorlevel 1 (
    echo [ERROR] dsh exited with an error. If "dsh" was not found, close this window and run install.bat again.
)
pause
'@

Write-StarterFile -RelPath 'install.sh' -Eol LF -Content @'
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
'@

Write-StarterFile -RelPath '.dsh/skills/doc-summary/SKILL.md' -Eol LF -Content @'
---
name: doc-summary
description: 读取一个文档，输出结构化要点摘要（标题、核心用途、关键要点、注意事项）。
whenToUse: 用户要求总结、概括或提炼某个文件、文档的要点时。
---

# 文档摘要

1. 确认要总结的文件路径。用户没给路径时先问；相对路径以当前工作区为准（示例文件：`workspace/note.md`）。
2. 读取完整文件内容，不要只看开头几行。
3. 按下面的格式输出：

## 📝 文档摘要

- **标题**：
- **核心用途**：（一句话）
- **关键要点**（3–5 条）：
  1.
  2.
  3.
- **注意事项 / 依赖**：

要求：

- 简洁、准确，不大段照抄原文
- 保留命令、路径、版本号、日期等可执行信息
- 原文没有的信息不要编；原文有歧义时直接指出
'@

Write-StarterFile -RelPath 'workspace/note.md' -Eol LF -Content @'
# 内部周报系统上线说明

本周将内部周报系统从旧表单迁移到新服务，目的是让各组周报自动汇总到同一个看板。

## 时间安排

- 9 月 18 日（周五）18:00 冻结旧表单，停止提交
- 9 月 21 日（周一）09:00 新系统开放

## 大家要做的事

1. 在 9 月 18 日前把本周周报提交到旧表单
2. 新系统用公司 SSO 登录，无需另外注册
3. 历史周报会迁移，但附件超过 20 MB 的不会迁移，请自行备份

## 已知问题

- Safari 16 以下版本导出 PDF 会乱码，请使用 Chrome 或 Edge
- 看板的「按组筛选」要到 9 月 28 日才上线

联系人：平台组 · 内部分机 1024
'@

# 打包 ZIP：不用 Compress-Archive
#   - Windows PowerShell 5.1 自带的 Compress-Archive 会写入反斜杠路径，Mac/Linux 解压后目录结构会乱
#   - PowerShell 7 在 Mac/Linux 上用通配符会漏掉 .env.example、.dsh 这类点开头文件
# 只打包本脚本写出的文件，不扫描文件夹：试用后留下的 .env.bak、.dsh 会话数据、workspace 里的私人文件都不会进 ZIP
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
if (Test-Path -LiteralPath $zipPath) { Remove-Item -LiteralPath $zipPath -Force }
$zip = [System.IO.Compression.ZipFile]::Open($zipPath, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    foreach ($rel in $written.Keys) {
        [void][System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
            $zip, $written[$rel], "$root/$rel", [System.IO.Compression.CompressionLevel]::Optimal)
    }
}
finally {
    $zip.Dispose()
}

Write-Host ''
Write-Host "✅ 已生成 $root\ 和 $root.zip" -ForegroundColor Green
Write-Host "下一步：进入 $root，Windows 双击 install.bat；macOS/Linux 运行 bash install.sh" -ForegroundColor Yellow

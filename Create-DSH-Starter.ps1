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
# DeepSeek Harness 入門模板

以 `@deepseek-ai/dsh` **0.1.5-rc.1** 為基礎（2026 年 9 月 npm 上的 `latest` 版本，仍是預發布版）。

完整圖文說明：https://rita112025-cpu.github.io/dsh-starter/

## 準備工作

- Node.js 22.19 以上的 22.x，或 Node.js 24 以上（https://nodejs.org/）
- DeepSeek API Key
- 只從 npm 或官方倉庫 https://github.com/deepseek-ai/deepseek-harness 取得 dsh

## 快速開始

1. 取得模板，二選一：
   - 下載 `dsh-starter.zip` 並解壓縮，進入 `dsh-starter` 資料夾（Windows「解壓縮全部」會多包一層 `dsh-starter\dsh-starter`，請進看得到 `install.bat` 的那層）
   - `git clone https://github.com/rita112025-cpu/dsh-starter.git`，再 `cd dsh-starter`
2. 第一次執行啟動腳本，它會從 `.env.example` 建立 `.env`，並請你填入 Key：
   - Windows：雙擊 `install.bat`
   - macOS / Linux：`bash install.sh`
3. 把 `.env` 裡的 `sk-xxxxxxxx...` 換成你的真實 Key，存檔
4. 再執行一次啟動腳本：還沒安裝 dsh 時會先安裝，接著執行 `dsh web`
5. 瀏覽器會自動打開；沒打開時，複製終端機裡 `dsh web:` 開頭那一行的**完整網址**

> 預設位址是 `127.0.0.1:3080`。**3080 被佔用時 dsh 會直接啟動失敗**，不會自動換埠號：改用 `dsh web --port 8080`，或 `dsh web --port 0` 讓系統挑一個空閒的埠號。
> 網址裡帶一次性認證參數，只輸入 `127.0.0.1:埠號` 是進不去的。

## 試用示例技能

在網頁介面的對話框輸入：

```
用 doc-summary 技能總結 workspace/note.md
```

## 目錄說明

```
dsh-starter/
├── README.md
├── .env.example                      → 複製成 .env，填入 DEEPSEEK_API_KEY
├── .gitignore                        → 避免 .env 被提交
├── install.bat / install.sh          → 檢查環境、安裝、啟動 dsh web
├── .dsh/skills/doc-summary/SKILL.md  → 示例技能（專案技能目錄）
└── workspace/note.md                 → 示例文件
```

## 常用指令（都要在本資料夾裡執行）

```bash
dsh web                                   # 啟動網頁介面
dsh web --port 8080                       # 指定埠號（--port 0 = 讓系統挑空閒埠號）
dsh web --no-open                         # 不自動打開瀏覽器
dsh --profile headless "用 doc-summary 技能總結 workspace/note.md"   # 一次性任務：結果印在終端機後結束
dsh --help                                # 啟動器說明
dsh web --help                            # 網頁介面自己的參數
npx @deepseek-ai/dsh@0.1.5-rc.1 web       # 不想全域安裝時臨時執行（一樣要在本資料夾裡執行）
```

## 需要知道的幾件事

- dsh 只讀取**啟動目錄**裡的 `.env`（不會往上層資料夾找），另外再讀 `~/.dsh/.env`。啟動腳本會先切換到本資料夾，所以請用啟動腳本，或在本資料夾裡執行 dsh。
- Key 的優先順序：系統環境變數 > 在 dsh 裡儲存過的 Key（`~/.dsh/.credentials.yaml`）> 本資料夾的 `.env` > `~/.dsh/.env`。改了 `.env` 卻沒生效，先檢查前兩項；環境變數就算設成空值，也會擋住 `.env`。
- 啟動目錄是預設工作目錄；在網頁介面裡，每個對話用的是你在介面中選擇的專案資料夾。
- 技能從「專案根目錄」下的 `.dsh/skills/<名稱>/SKILL.md` 讀取。專案根目錄是**最近一個含 `.git` 的上層資料夾**，找不到才用目前目錄。所以如果把本資料夾放進某個 git 倉庫的子資料夾，請把 `.dsh/skills` 移到那個倉庫的根目錄。
- 新增或修改技能不需要重新啟動；`SKILL.md` 開頭的 `name`（小寫英文、數字、短橫線）和 `description` 是必填欄位，`whenToUse` 可不填。
- 個人全域技能可以放在 `~/.dsh/skills/`；dsh 自己的設定檔在 `~/.dsh/profiles/web/cordis.patch.yml`，入門階段不用改。
- `.env` 裡是你的密鑰：不要提交、不要傳給別人。產生器打包的 ZIP 只含模板檔，不含 `.env`；直接分享本資料夾之前，請自己檢查一次。
- 升級 dsh：執行 `npm install -g @deepseek-ai/dsh@<版本號>`，並把兩個啟動腳本裡的 `DSH_VERSION` 改成同一個版本號。注意：版本號只鎖住 dsh 本體，它依賴的 `@deepseek-ai/dsh-*` 子套件寫的是 `^` 範圍，安裝時會拿到當時最新的相容預發布版（例如安裝 rc.1 本體，子套件可能是 rc.2）。
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

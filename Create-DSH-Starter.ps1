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
# DeepSeek Harness 入門範本套件
基於 `@deepseek-ai/dsh` **0.1.5-rc.1**（2026 年 9 月 npm 上的 `latest` 版本，仍為預發布版）。

完整圖文說明網站：https://rita112025-cpu.github.io/dsh-starter/

## 先決條件
- Node.js 22.19 以上的 22.x 版，或 Node.js 24 以上版本（https://nodejs.org/）
- DeepSeek API 金鑰
- 僅從 npm 或官方倉庫 https://github.com/deepseek-ai/deepseek-harness 取得 dsh

## 快速開始
1. 取得範本，以下兩種方式擇一：
   - 下載 `dsh-starter.zip`，解壓縮後進入 `dsh-starter` 資料夾（Windows「全部解壓縮」預設會多一層 `dsh-starter\dsh-starter`，請進到最裡面那一層）
   - 使用 Git 複製倉庫：`git clone https://github.com/rita112025-cpu/dsh-starter.git`，再執行 `cd dsh-starter` 進入資料夾
2. 第一次執行啟動指令檔，它會從 `.env.example` 建立 `.env` 並提示你填入金鑰：
   - Windows：滑鼠雙擊 `install.bat`
   - macOS / Linux：執行 `bash install.sh`
3. 把 `.env` 裡的 `sk-xxxxxxxx...` 替換成你的真實金鑰，然後儲存檔案
4. 再次執行啟動指令檔：若尚未安裝 dsh，會先進行安裝，接著執行 `dsh web`
5. 瀏覽器會自動開啟；若未自動開啟，請複製終端裡以 `dsh web:` 開頭那一行的**完整網址**

> 預設位址為 `127.0.0.1:3080`。**若 3080 已被佔用，dsh 會直接啟動失敗，不會自動更換通訊埠**。請改用 `dsh web --port 8080` 自行指定，或輸入 `dsh web --port 0` 讓系統自動挑選可用通訊埠。
> 網址內含有一次性認證參數，只輸入 `127.0.0.1:通訊埠` 將無法進入系統。

## 試用範例技能
在網頁介面輸入：
```
使用 doc-summary 技能整理 workspace/note.md 的內容
```

## 目錄說明
```
dsh-starter/
├── README.md
├── .env.example                      → 複製為 .env，填入 DEEPSEEK_API_KEY
├── .gitignore                        → 避免 .env 被提交至版本控制
├── install.bat / install.sh          → 環境檢查 + 安裝 + 啟動 dsh web
├── .dsh/skills/doc-summary/SKILL.md  → 範例技能（專案層級技能目錄）
└── workspace/note.md                 → 範例文件
```

## 常用指令（請務必在本資料夾內執行）
```bash
dsh web                                   # 啟動網頁介面
dsh web --port 8080                       # 指定通訊埠（--port 0 = 由系統自動選用可用通訊埠）
dsh web --no-open                         # 不自動開啟瀏覽器
dsh --profile headless "使用 doc-summary 技能整理 workspace/note.md"   # 一次性執行：輸出結果後即結束
dsh --help                                # 啟動程式說明
dsh web --help                            # 網頁介面參數說明
npx @deepseek-ai/dsh@0.1.5-rc.1 web       # 不安裝至全域，直接執行（同樣須在本資料夾內執行）
```

## 使用須知
- dsh 只會讀取**執行指令時所在目錄**的 `.env`（不會向上層尋找），另外也會讀取 `~/.dsh/.env`。啟動指令檔會自動切換到腳本所在的資料夾，建議透過啟動指令檔或先切換至本資料夾再執行指令。
- 金鑰優先順序：系統環境變數 → dsh 內已儲存的金鑰（`~/.dsh/.credentials.yaml`）→ 本機資料夾 `.env` → `~/.dsh/.env`。若修改 `.env` 後仍無效，請優先檢查前兩項；即使環境變數被設成空值，也會優先於 `.env` 生效。
- 執行指令所在的資料夾即為預設工作目錄；在網頁介面中，每個對話階段會使用你在介面中選取的專案資料夾。
- 技能檔案會從「專案根目錄」下的 `.dsh/skills/<技能名稱>/SKILL.md` 讀取。專案根目錄的認定方式：以**最近上層含有 `.git` 的資料夾**為準，若無則以目前所在目錄為準。因此，若你將本資料夾放置在某個 Git 倉庫的子目錄中，請將 `.dsh/skills` 移至該倉庫的最上層根目錄。
- 新增或修改技能後**無須重新啟動系統**；`SKILL.md` 開頭的 `name`（僅限小寫英文字母、數字及減號）及 `description` 為必填欄位，`whenToUse` 則為選填。
- 個人專屬技能可放置在 `~/.dsh/skills/`；dsh 本身的設定檔位於 `~/.dsh/profiles/web/cordis.patch.yml`，入門階段建議無需調整。
- `.env` 含有機密資訊：請不要提交至版本控制、不要傳送給他人。透過產生器建立的壓縮檔僅包含範本檔案，不含 `.env` 可安全分享；直接分享本資料夾前，請務必先自行檢查內容。
- 升級 dsh 版本：執行 `npm install -g @deepseek-ai/dsh@<版本號>`，並同步更新兩個啟動指令檔中的 `DSH_VERSION` 版本號。請注意：版本號僅鎖定 dsh 主程式本體，其相依的 `@deepseek-ai/dsh-*` 子套件採用 `^` 相容範圍，安裝時會自動取得當時最新的預發布版（例如安裝 rc.1 版主程式時，子套件可能會安裝到 rc.2 版）。
'@

Write-StarterFile -RelPath '.env.example' -Eol LF -Content @'
# DeepSeek Harness environment file
# 複製為 .env 後，把下面的預留字串替換成你的 DeepSeek API 金鑰。
# 注意：不要把 .env 提交至 git，也不要傳送給他人。
DEEPSEEK_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxx
'@

Write-StarterFile -RelPath '.gitignore' -Eol LF -Content @'
# 金鑰
.env
.env.*
!.env.example

# dsh 執行時產生的資料（只保留技能）
.dsh/*
!.dsh/skills/

# 相依套件、日誌、系統檔案
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
'@

Write-StarterFile -RelPath '.dsh/skills/doc-summary/SKILL.md' -Eol LF -Content @'
---
name: doc-summary
description: 讀取一份文件，輸出結構化的重點摘要（標題、核心用途、關鍵重點、注意事項）。
whenToUse: 使用者要求總結、整理或摘要某個檔案或文件的重點時。
---

# 文件摘要

1. 確認要摘要的檔案路徑。使用者沒有提供路徑時先詢問；相對路徑以目前的工作區為準（範例檔案：`workspace/note.md`）。
2. 讀取完整的檔案內容，不要只看開頭幾行。
3. 依照下面的格式輸出，並使用繁體中文：

## 📝 文件摘要

- **標題**：
- **核心用途**：（一句話）
- **關鍵重點**（3–5 點）：
  1.
  2.
  3.
- **注意事項 / 相依條件**：

要求：

- 簡潔、準確，不要大段照抄原文
- 保留指令、路徑、版本號、日期等可以直接照做的資訊
- 原文沒有的資訊不要自行編造；原文有歧義時直接指出
'@

Write-StarterFile -RelPath 'workspace/note.md' -Eol LF -Content @'
# 內部週報系統上線說明

本週將內部週報系統從舊表單轉移到新服務，目的是讓各組週報自動彙整到同一個看板。

## 時程安排

- 9 月 18 日（週五）18:00 凍結舊表單，停止提交
- 9 月 21 日（週一）09:00 新系統開放

## 大家要做的事

1. 在 9 月 18 日前把本週週報提交到舊表單
2. 新系統使用公司 SSO 登入，不需要另外註冊
3. 歷史週報會轉移，但超過 20 MB 的附件不會轉移，請自行備份

## 已知問題

- Safari 16 以下版本匯出 PDF 會出現亂碼，請改用 Chrome 或 Edge
- 看板的「依組別篩選」功能要到 9 月 28 日才會上線

聯絡人：平台組 · 內線分機 1024
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

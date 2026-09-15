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

---

# DeepSeek Harness 入門範本套件
基於 `@deepseek-ai/dsh` **0.1.5-rc.1**（2026 年 9 月 npm 上的 `latest` 版本，仍為預發布版）。

## 先決條件
- Node.js 22.19 以上的 22.x 版，或 Node.js 24 以上版本（https://nodejs.org/）
- DeepSeek API 金鑰
- 僅從 npm 或官方倉庫 https://github.com/deepseek-ai/deepseek-harness 取得 dsh

## 快速開始
1. 解壓縮後進入 `dsh-starter` 資料夾（Windows「全部解壓縮」預設會多一層 `dsh-starter\dsh-starter`，請進到最裡面那一層）
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

---

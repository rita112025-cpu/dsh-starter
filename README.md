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

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

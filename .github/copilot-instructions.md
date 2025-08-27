<!--
自动生成：为 AI 代码代理（Copilot / agents）提供本仓库的可执行上下文指引。
请保留此文件并在修改重要项目结构或脚本后同步更新。
-->

# Copilot / AI Agent 指南 — arts-main

目的：让 AI 代理在最短时间内有上下文、知道如何构建/运行/修改本仓库并遵循项目中的关键约定。

快速命令（在仓库根目录运行）：
- 安装依赖：
  npm install
- 启动开发服务器：
  npm run dev
- 本地预览构建产物：
  npm run preview
- 完整构建（包含类型检查）：
  npm run build
- 单独类型检查：
  npm run type-check
- 修复/检查代码风格：
  npm run lint
- 部署辅助脚本：
  npm run push   # 调用 PowerShell 脚本 server-push.ps1

部署/推送脚本说明（`server-push.ps1`）：
- 脚本执行流程（按顺序）：
  1) 本地执行 `npm run build`（构建并输出到 `dist/`）；
  2) 使用 SSH 连接远程主机别名 `ARTS-R2-JP`，清理目标目录 `/usr/web-server/sites/arts-home/index/*`；
  3) 使用 `scp` 将本地 `dist/` 内容递归复制到远程目录；
  4) 在远程主机上修改目标目录属主为 `1000:1000`。

- 注意事项：
  - 脚本依赖在本机可用的 SSH 配置（存在 `ARTS-R2-JP` 主机别名/配置）和可用的 `scp`/`ssh` 命令；在 Windows 上通常通过 Git for Windows 或 OpenSSH 提供。确保 `pwsh` 环境能找到这些工具。
  - 运行该脚本会覆盖远端目录，请在执行前确认目标路径与权限；建议先在安全环境（或使用 `--dry-run` 的自定义脚本）测试。
  - 警告：脚本中包含远程主机别名 `ARTS-R2-JP` 及目标路径 `/usr/web-server/sites/arts-home/index`，这是仓库示例配置。其他使用者在运行前必须把这些值替换为自己服务器的主机别名或地址与目标路径，切勿直接使用仓库中的配置以免误删或覆盖他人服务器上的文件。
  - 若团队中存在 CI/CD，考虑将相同步骤迁移到 CI 管道并在仓库中隐藏或参数化敏感主机别名/凭证。


重要文件与工程约定（必读，直接引用示例路径）：
- 框架与打包器：Vue 3 + Vite — 入口与插件在 `vite.config.ts`。
  - `vite.config.ts` 中设置了 alias `@ -> ./src`（示例导入：`@/components/HelloWorld.vue`）。
  - `vite.config.ts` 的 Vue 编译器选项把所有以 `mdui-` 开头的标签视为自定义元素：
    isCustomElement: (tag) => tag.startsWith('mdui-')
  说明：当你生成或修改模板时，不要把 `mdui-xxx` 标签当成需要注册的 Vue 组件。

- TypeScript / 类型：使用 `vue-tsc` 进行 `.vue` 类型检查，脚本在 `package.json` 中为 `type-check`。

- 代码结构（约定位置）：
  - 源码：`src/`
  - 视图：`src/views/`（例如 `HomeView.vue`, `AboutView.vue`）
  - 组件：`src/components/` 与 `src/components/icons/`
  - 路由：`src/router/index.ts`
  - 状态管理（Pinia）：`src/stores/`

- 编辑器与开发提示：
  - README 推荐使用 VS Code + Volar（禁用 Vetur）。
  - `.vscode/settings.json` 已注册 MDUI 的 HTML/CSS customData 文件（`node_modules/mdui/...`），说明项目依赖 `mdui` 并有自定义 HTML 数据用于编辑器提示。

构建与 CI 注意事项（对代理很重要）：
- `npm run build` 脚本会并行执行类型检查和真正的 vite 构建（使用 `npm-run-all2` 的 `run-p`）。修改构建相关配置后，务必：
  1) 运行 `npm run type-check` 验证类型无误；
  2) 运行 `npm run build` 确保生产构建成功并输出到 `dist/`。

风格与约定（可作为自动更改参考）：
- ESLint 配置基于 `@vue/eslint-config-typescript`。在编辑器自动修复前，运行 `npm run lint` 用 `--fix` 修复可自动解决的问题。
- 当添加新依赖或变更 `package.json`，同步提交 `package-lock.json`。

集成点与外部依赖：
- mdui：用于 UI，模板中大量以 `mdui-` 为前缀的自定义元素；相关数据在 `node_modules/mdui` 下（见 `.vscode/settings.json`）。
- Pinia、vue-router：应用状态与路由通过常规目录结构组织（见 `src/stores` 与 `src/router`）。
- clarity/analytics：`@microsoft/clarity` 已列入依赖，注意在修改跟踪或注入脚本时不要破坏初始化代码。

对 AI 代理的具体建议（可执行动作示例）：
- 新增页面组件：放在 `src/views/`，路由在 `src/router/index.ts` 注册，遵循现有命名与导出模式（用 `@/views/YourView.vue` 导入）。
- 引入第三方 UI 组件：若是 MDUI 组件，直接在模板使用 `mdui-xxx` 标签；不要在 `components/` 中重复包裹成 Vue 组件，除非需要额外逻辑。
- 修改构建/类型相关依赖：确保对 `package.json` 的改动伴随 `npm install` 并更新 `package-lock.json`，且通过 `npm run type-check` 与 `npm run build` 验证。

限制与未发现的内容（代理须注意）：
- 仓库中未包含测试配置（如 Jest / Vitest）；不要假设存在测试框架——如果需要添加测试，应同时提供配置与文档。
- CI 配置（例如 GitHub Actions）未在仓库根部找到；推送时不要假设自动化流程已存在。

小结：
- 优先任务：能运行 `npm install` → `npm run dev` 并在浏览器查看页面。
- 修改提交：保证类型校验与 lint 通过后再提交。CI/测试未配置时，手动运行本地验证命令。

如果这份指南中有你想要补充的项目约定或我遗漏的目录/脚本，请说明，我会迭代并合并到本文件中。

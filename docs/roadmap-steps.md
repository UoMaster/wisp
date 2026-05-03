# Wisp 开发进度总览

> 基于 `docs/product-design.md` 和当前代码库对齐后的完成状态。
> 更新日期：2026-05-04

---

## 一、已完成

### 1. 项目骨架
- [x] SwiftUI + AppKit 混合架构的 macOS 应用骨架
- [x] `Package.swift` / `Package.resolved` 依赖管理（libghostty-spm 已接入）
- [x] App 入口 (`demoApp.swift`)：无标题栏窗口、默认尺寸 1280×820

### 2. 设计系统（Design System）
- [x] **颜色 Token** (`Design/Theme.swift`)：完整亮暗双模 dynamic color 体系
  - bgWindow / bgSurface / bgRaised / bgHover / bgSelected / bgOverlay
  - textPrimary / textSecondary / textTertiary / textOnAccent
  - borderSubtle / borderDefault / borderStrong
  - accent / accentHover / accentSoft
  - statusRunning / statusSuccess / statusWarning / statusDanger
  - terminalBg（独立深色，不参与主题切换）
- [x] **字体 Token** (`Design/Typography.swift`)：WispFont 枚举 + sectionTitleStyle modifier
- [x] **间距/圆角/描边/动效** (`Design/Spacing.swift`)：Space / Radius / Stroke / Motion
- [x] **可复用 Modifier** (`Design/Modifiers.swift`)：wispCard / wispRowBackground / wispBordered / trackHover / WispDivider
- [x] **按钮样式** (`UI/Components/WispButton.swift`)：wispPrimary / wispGhost / wispIcon
- [x] **状态点** (`UI/Components/StatusDot.swift`)：替代 SF Symbol，running 态带光晕

### 3. 核心数据模型
- [x] **Project** (`Core/Models/Project.swift`)：id / path / name / defaultCLI / lastOpenedAt / displayPath
- [x] **Todo** (`Core/Models/Todo.swift`)：id / title / prompt / status / preferredCLI / createdAt / updatedAt
- [x] **CLIType** (`Core/Models/CLIType.swift`)：claude / opencode / codex + CLIAdapter 协议 + GenericCLIAdapter
- [x] **TerminalSession** (`Core/Models/TerminalSession.swift`)：id / projectID / todoID / cliType / promptFile / status / exitCode
- [x] **Panel 协议** (`Core/Protocols/Panel.swift`)：id + title（极简版，预留扩展接口）

### 4. 主界面布局
- [x] **MainWindow** (`UI/MainWindow.swift`)：NavigationSplitView 三栏结构
- [x] **ProjectSidebar** (`UI/Sidebar/ProjectSidebar.swift`)：项目列表、选中态、hover 态、空状态、添加项目按钮
- [x] **ProjectDetailView** (`UI/ProjectDetailView.swift`)：TodoPanel + TerminalPanel 水平并排
- [x] **EmptyProjectState** (`UI/MainWindow.swift`)：无项目时的欢迎页

### 5. TodoPanel
- [x] 任务列表展示（标题 + prompt 预览 + 状态点）
- [x] 空状态（图标 + 文案 + 新建按钮）
- [x] Header（标题 + 任务计数 badge + 添加按钮）
- [x] **AddTodoSheet** (`UI/Panels/TodoPanel.swift`)：标题输入框 + Prompt 编辑器 + 取消/创建按钮
- [x] TodoRow hover 态显示播放按钮
- [x] 点击 TodoRow 触发 `runTodo()`（当前为占位实现）

### 6. TerminalPanel
- [x] **libghostty 集成** (`UI/Panels/TerminalPanel.swift`)：import GhosttyTerminal + TerminalSurfaceView
- [x] Shell 生命周期管理（启动 / 销毁 / 标准输入输出管道绑定）
- [x] Header（状态圆点 + 会话标题 + shell 名 + 分割/关闭占位按钮）
- [x] InMemoryTerminalSession 接入（MVP 沙盒模式）

### 7. 添加项目流程
- [x] NSOpenPanel 选择本地目录
- [x] 自动生成项目名称（取目录名）
- [x] 显示缩短路径（~ 替换 home 目录）
- [x] 右键移除项目

---

## 二、MVP 待完成（目标：1 周内可用版本）

### 🔴 核心阻断项（没有这些 MVP 不完整）

- [x] **项目持久化**
  - 把 `projects` 数组保存到本地（`~/Library/Application Support/Wisp/projects.json`）
  - App 启动时自动加载
  - 添加/删除/修改后自动保存

- [x] **To-Do 持久化**
  - 每个项目的 To-Do 列表跟随项目一起保存
  - 方案：与 Project 列表存同一 JSON，通过 `PersistedData` / `TodoEntry` 结构序列化

- [x] **点击 To-Do 启动 CLI 完整流程**
  - 弹出 CLI 选择浮层（Claude Code / OpenCode / Codex）
  - 把 prompt 写入临时文件 `/tmp/wisp/<uuid>.prompt`
  - 通过 CLIAdapter 生成启动命令
  - 在 TerminalPanel 中执行（cwd = 项目目录）
  - 更新 Todo 状态为 running，完成后自动标记 completed

- [x] **终端与项目目录关联**
  - TerminalPanel 启动 shell 时使用项目路径作为 cwd
  - 当前 `startShell()` 写死为 `homeDirectoryForCurrentUser`

### 🟡 重要体验项（建议 MVP 包含）

- [ ] **窗口分割**
  - 水平分割（新 Panel 在右侧）
  - 垂直分割（新 Panel 在下方）
  - 快捷键：`⌘⇧D` / `⌘D`
  - TerminalPanel header 中的分割按钮需要实际功能

- [ ] **通知系统**
  - 进程退出 → UNUserNotificationCenter 推送通知
  - 点击通知激活 App + 聚焦对应 Panel

- [ ] **修饰键决定窗口位置**
  - 默认（无修饰键）：上次选择，首次默认"新窗口"
  - `⌘` + 点击：新窗口
  - `⌥` + 点击：水平分割当前 Panel
  - `⌃` + 点击：垂直分割当前 Panel
  - 右键：弹出选择菜单

- [ ] **关闭 Panel**
  - TerminalPanel header 的 `xmark` 按钮需要实际功能
  - `⌘W` 关闭当前 Panel

### 🟢 体验优化项（MVP 可延后，但很快跟上）

- [ ] **项目默认 CLI 设置**
  - 每个项目可设置默认 CLI（当前模型有字段，UI 无入口）

- [ ] **To-Do 编辑**
  - 双击 TodoRow 弹出编辑器修改 title/prompt

- [ ] **To-Do 删除与重排序**
  - 右键菜单删除 / Delete 键
  - 拖拽重排序

- [ ] **沉浸式可折叠侧栏**
  - 快捷键 `⌘⇧F` 切换
  - 鼠标移到左侧边缘临时浮出

- [ ] **终端标题与 Todo 关联**
  - 通过 Todo 启动的终端，title 显示为 Todo 标题
  - TerminalSession 绑定 todoID

---

## 三、V0.2 规划（吸引早期用户）

- [ ] To-Do 模板变量（`{{branch}}` / `{{file}}` 等）
- [ ] 任务历史记录
- [ ] 进程退出后弹"标记完成？"小提示（半自动打勾）
- [ ] Codex 等更多 CLI Adapter 细化
- [ ] 用户没装 CLI 时的友好提示引导

---

## 四、V0.5 规划（拉开差距）

- [ ] 自动 git worktree 隔离（可选开关）
- [ ] 批量启动多个 To-Do
- [ ] 通知聚合（多个完成不刷屏）
- [ ] Todo 模板库（用户可保存常用 prompt 模板）

---

## 五、V0.8 规划（Git 集成）

- [ ] GitDiffPanel（查看当前 working tree 的 git diff）
- [ ] Diff 与 To-Do 联动
- [ ] Stage / Unstage（可选）

---

## 六、V1.0 规划（核心理念落地）

- [ ] 会话独立于窗口（Session 一等公民）
- [ ] 会话后台运行 + 重连
- [ ] 会话状态持久化（重启 App 恢复）
- [ ] 同一会话多视图同步显示
- [ ] 数据持久化从 JSON 切 sqlite

---

## 七、架构已知限制

| 限制 | 原因 | 优化方向 |
|---|---|---|
| `InMemoryTerminalSession` 无真实 TTY | GhosttyTerminal 的 `.exec` backend 需要 `login` 权限 | 后续改用 `.exec` 或自建 PTY |
| `ls` 等命令输出格式可能不对 | 无 TTY 时命令认为自己不在终端上 | 同上 |
| 窗口分割暂不支持拖拽调整 | SwiftUI 原生不支持可拖拽分割器 | 后续用 AppKit 实现 |
| Panel 协议过于简单 | MVP 阶段仅作预留 | V0.8 引入 GitDiffPanel 时扩展 |

# 产品设计文档

> **Wisp** —— 一款完全开源、永久免费、快速迭代的 macOS 原生 AI 编码代理终端应用。

---

## 文档元信息

| 产品名称 | Wisp |
| 文档版本 | v0.1 |
| 创建日期 | 2026-05-03 |
| 文档状态 | 持续讨论中 |
| 文档用途 | 锁定产品定位、功能边界、技术栈选型，避免后续开发中的不必要争议 |

---

## 一、产品愿景

### 1.1 一句话描述

**Wisp** —— 一款基于 libghostty 构建的 macOS 原生应用，以"项目 + 任务"为中心组织 AI 编码代理（Claude Code / OpenCode 等）的多实例工作流。

### 1.2 核心定位

**Wisp** 不是对 cmux 的颠覆性重做，而是：

- **修复 cmux"开源精神缺失 + 迭代节奏滞后"的核心问题**
- **通过"任务驱动工作流（To-Do 启动器）"实现差异化**
- **保留 cmux 已经验证可行的交互模式**

> 一句话定位：**一个开源精神到位、高频迭代、任务驱动的 cmux 替代品。**

### 1.3 目标用户

1. 同时使用多个 AI 编码代理 CLI（Claude Code、OpenCode、Codex 等）的开发者
2. 对 cmux"闭源最新版 + 月更"模式不满，希望开源/免费/高频迭代替代品的用户
3. 在多个项目间频繁切换，且有重复 prompt 工作流的开发者
4. 信奉开源精神、愿意提交 PR 或 issue 共建产品的技术社区用户

---

## 二、产品理念（核心思想）

### 2.1 任务驱动而非命令驱动 ⭐ MVP 阶段最核心创新

**传统终端**：用户每次手动 `cd` → 启动 CLI → 手敲 prompt。  
**Wisp**：把 prompt 沉淀为项目内的"任务资产"，**一键启动**所需的 CLI 与上下文。

**意义**：把 prompt engineering 的成果**固化、可复用、可分享**，从"一次性输入"变为"项目长期资产"。

### 2.2 会话为中心而非窗口为中心 ⭐ V1.0 长期目标

**当前产品（包括 cmux）**：窗口 = 会话，关窗口即杀进程。  
**Wisp 长期目标**：会话独立于窗口存在，窗口只是会话的"视图"。

**类比**：tmux 的 session/window/pane 模型搬到原生 GUI。

**意义**：
- CLI 进程可在后台持续运行，不依赖窗口生命周期
- 同一会话可以在多个视图中并行展示
- 关闭再打开 App，会话状态可恢复

> ⚠️ V1.0 才落地，但**架构层从 MVP 第一天就要预留接口**，避免后期大改。

### 2.3 Panel 抽象架构 ⭐ MVP 阶段架构必须做对

窗口内不是只能放终端，而是可插拔的 Panel：

```
Panel 协议
  ├── TerminalPanel（libghostty 渲染的 PTY）
  ├── TodoPanel（任务列表）
  ├── GitDiffPanel（V0.8 引入）
  └── 未来扩展：日志 / 文件树 / 对话历史 / ...
```

**意义**：每加一种新 Panel 不需要改架构，只需新增一个文件。

### 2.4 核心承诺（不可妥协）

| 承诺 | 含义 |
|---|---|
| 完全开源 | 所有代码 MIT/Apache 2.0 协议公开（含最新版） |
| 永久免费 | 无付费墙、无订阅、无功能阉割 |
| 高频迭代 | 目标周更/双周更，**坚决拒绝月更** |
| 透明路线图 | GitHub Projects 公开 Roadmap，承诺与不承诺都写清楚 |
| 接受社区 PR | issue 模板、贡献指南、CI 一应俱全 |

---

## 三、与 cmux 的对比

### 3.1 保留 cmux 的优点（基线能力）

| 维度 | cmux 表现 | Wisp 要求 |
|---|---|---|
| 终端流畅度 | 好（基于 Ghostty） | 至少持平（同样基于 libghostty 天然达成） |
| 沉浸式 UI | 满意（侧栏可折叠 + 主区域最大化） | 保留并强化 |
| 项目分组工作流 | 够用 | 保留 |
| 通知机制 | 能用但不出彩 | 保留 + 后续增强 |

### 3.2 解决 cmux 的痛点

| cmux 问题 | Wisp 对策 |
|---|---|
| 闭源最新版（最新功能要付费） | 完全开源，最新版永远免费 |
| 月更频率（一个月才发一次） | 周更/双周更 |
| 常见 bug 修复滞后一个月以上 | 优先级最高，发现即修，下个版本必带 |
| 单人维护、社区 PR 处理慢 | 第一天就建好贡献机制 |

### 3.3 差异化创新点

| 功能 | cmux | Wisp |
|---|---|---|
| 任务驱动启动器（To-Do） | ❌ | ✅ MVP 必有 |
| 多 CLI 选择（Claude/OpenCode/Codex） | ❌ | ✅ MVP 必有 |
| Git Diff 集成视图 | ❌ | ✅ V0.8 引入 |
| 会话独立于窗口 | ❌ | ✅ V1.0 引入 |
| Panel 可插拔架构 | ❌ | ✅ 第一天就做 |

---

## 四、功能架构

### 4.1 三层概念模型

```
┌──────────────────────────────────────────────────┐
│  一级：项目（Project）                              │
│   绑定本地目录路径，显示在左侧主侧栏                  │
│   一个项目 = 一个工作上下文                         │
│   ─────────────────────────────────────────────  │
│  二级：Panel（视图单元）                            │
│   可插拔类型：终端 / To-Do / Git Diff / ...        │
│   支持水平/垂直分割                                 │
│   ─────────────────────────────────────────────  │
│  三级：Session（会话，V1.0 引入）                   │
│   独立于 Panel 存在                                │
│   一个 Session 可被多个 Panel 同时展示              │
└──────────────────────────────────────────────────┘
```

### 4.2 一级：项目（Project）

- **作用**：组织和隔离不同代码库的工作
- **绑定**：一个本地目录路径
- **位置**：左侧主侧栏（一级分类）
- **支持操作**：添加、删除、重命名、切换
- **可折叠**：保持沉浸式 UI 体验

### 4.3 二级：Panel（视图单元）

#### Panel 协议（伪代码）

```swift
protocol Panel: AnyObject, Identifiable {
    var id: UUID { get }
    var title: String { get set }
}
```

#### MVP 阶段的 Panel 类型

| Panel | 内容 | 引入版本 |
|---|---|---|
| `TerminalPanel` | libghostty 渲染的 PTY，跑 Claude Code / OpenCode 等 CLI | MVP |
| `TodoPanel` | 项目内的任务列表，点击启动 CLI | MVP |
| `GitDiffPanel` | 显示当前 git working tree 的更改 | V0.8 |

#### Panel 操作

- 水平分割（horizontal split）
- 垂直分割（vertical split）
- 关闭、最大化、拖拽重排（后期）

### 4.4 三级：Session（会话，V1.0 引入）

- **当前 MVP 简化**：Panel 关闭时杀掉对应进程（与 cmux 一致）
- **V1.0 目标**：Session 独立存在，Panel 关闭不影响 Session
- **关键架构准备**：MVP 阶段就引入 `TerminalSession` 数据结构（详见第八章），未来 Session 持久化只需扩展现有结构

---

## 五、核心交互流程

### 5.1 ⭐ 点击 To-Do 启动 CLI 全流程（MVP 必须实现）

```
点击 "修复 login bug" 这条 To-Do
  │
  ├─ ❶ 检查修饰键决定窗口位置
  │   ├ 默认（无修饰键）：上次选择，首次默认"新窗口"
  │   ├ ⌘ + 点击：新窗口
  │   ├ ⌥ + 点击：水平分割当前 Panel
  │   ├ ⌃ + 点击：垂直分割当前 Panel
  │   ├ ⌘⌥⌃ + 点击：弹出选择面板
  │   └ 右键：弹出选择菜单（兜底，新手友好）
  │
  ├─ ❷ 弹出 CLI 选择浮层（小弹窗）
  │   ┌──────────────┐
  │   │ ◉ Claude Code │  ← 默认上次选择
  │   │ ○ OpenCode   │
  │   │   [启动]      │
  │   └──────────────┘
  │
  ├─ ❸ 把 To-Do 的 prompt 写入临时文件
  │   路径：/tmp/your-app/<uuid>.prompt
  │
  ├─ ❹ 创建 TerminalPanel（按 ❶ 决定的位置）
  │   ├ cwd       = 项目根目录
  │   ├ command   = `claude "$(cat /tmp/your-app/<uuid>.prompt)"`
  │                 （由对应的 CLIAdapter 生成实际命令）
  │   ├ title     = To-Do 标题（如"修复 login bug"）
  │   └ 绑定关系   = todoID 写入 TerminalSession
  │
  ├─ ❺ 进程启动 + Panel 自动聚焦
  │
  └─ ❻ 监听进程退出事件
      └ 退出 → 触发系统通知（携带 todoID）
              └ 用户点击通知
                 └ 激活 App + 聚焦对应 Panel + 边框闪烁动画
```

### 5.2 通知 → 聚焦 → 视觉提示流程

```swift
// 关键 API 链路
UNUserNotificationCenter
    └ delegate.userNotificationCenter(_:didReceive:withCompletionHandler:)
        ├ NSApp.activate(ignoringOtherApps: true)         // 1. 激活 App
        ├ WindowManager.focus(panelID:)                   // 2. 聚焦 Panel
        └ WindowManager.flash(panelID:)                   // 3. 边框闪烁
```

**视觉提示设计**：
- 通过 `CALayer.borderColor` + `CABasicAnimation` 实现边框颜色脉冲
- 默认动画：systemGreen → clear，0.5s 一周期，反复 3 次
- 可在设置中关闭

### 5.3 窗口分割快捷键约定

| 操作 | 快捷键 | 说明 |
|---|---|---|
| 水平分割 | `⌘⇧D` | 新 Panel 在当前 Panel 右侧 |
| 垂直分割 | `⌘D` | 新 Panel 在当前 Panel 下方 |
| 关闭 Panel | `⌘W` | 不关项目，只关 Panel |
| 切换 Panel | `⌘[` / `⌘]` | 在当前项目的 Panel 间切换 |
| 切换项目 | `⌘1`–`⌘9` | 快速跳转到第 N 个项目 |

> 快捷键最终方案待 MVP 实装时微调。

### 5.4 To-Do 操作流程

| 操作 | 触发方式 |
|---|---|
| 新建 To-Do | TodoPanel 顶部 "+" 按钮 / 快捷键 `⌘N` |
| 编辑 prompt | 双击 To-Do 条目，弹出编辑器 |
| 启动任务 | 单击条目（按上述完整流程） |
| 标记完成 | 点击条目左侧勾选框（MVP 仅支持手动勾选） |
| 删除 To-Do | 右键菜单 / `Delete` 键 |
| 重排序 | 拖拽 |

---

## 六、技术栈

> ⚠️ 这一章是**未来争议时的仲裁依据**。所有技术选型已经讨论确认，原则上不再变动。如需变更需在文档中明确记录原因。

### 6.1 核心技术栈

| 类别 | 选型 | 备注 |
|---|---|---|
| 应用主语言 | **Swift** | macOS 原生开发首选 |
| UI 框架 | **SwiftUI + AppKit 混合** | SwiftUI 为主，AppKit 用于窗口/底层细节 |
| 终端引擎 | **libghostty**（成品路线） | 通过 Swift Package 引入 `libghostty-spm` 提供的预编译 `GhosttyKit.xcframework` |
| 不使用 Zig | ❌ | 不自行编译 libghostty，避免 Zig 工具链负担 |

### 6.2 依赖管理

| 类别 | 选型 |
|---|---|
| 包管理器 | **Swift Package Manager（SPM）** |
| 主依赖 | `libghostty-spm`（GhosttyKit.xcframework） |
| 第三方依赖 | 暂无，保持 minimal；如需加入需 PR + 文档说明理由 |

### 6.3 系统 API

| 用途 | API |
|---|---|
| 通知 | `UserNotifications.framework`（`UNUserNotificationCenter`） |
| 窗口管理 | `AppKit`（`NSWindow`、`NSView`、`NSWindowController`） |
| 进程管理 | `Foundation`（`Process`、`Pipe`） |
| 动画 | `Core Animation`（`CABasicAnimation`、`CALayer`） |
| 文件系统 | `Foundation`（`FileManager`、`URL`） |
| Git 操作 | 调用 `git` 命令行（V0.8 引入；不引入 libgit2，保持轻量） |

### 6.4 构建与发布

| 类别 | 选型 |
|---|---|
| IDE | Xcode |
| 构建系统 | Xcode + SPM |
| 代码签名 | Apple Developer 账户（$99/年，必须） |
| 公证 | Apple Notarization（必须） |
| 分发渠道 | **GitHub Releases（主要） + Homebrew Cask（辅助）** |
| 不上 App Store | ❌（保留独立分发自由度） |

### 6.5 CI/CD（早期搭建）

| 类别 | 选型 |
|---|---|
| CI | GitHub Actions |
| 自动化 | 构建检查、单元测试、Lint、Release 自动签名公证 |

### 6.6 测试

| 类别 | 选型 |
|---|---|
| 单元测试 | XCTest |
| UI 测试 | XCUITest（关键流程） |
| 测试基础设施 | **第一天就建立**，不允许后补 |

---

## 七、MVP 范围

| 模块 | MVP 包含 | 备注 |
|---|---|---|
| Panel 协议 + 抽象架构 | ✅ | 第一天做对 |
| 项目侧栏（一级分类） | ✅ | 可折叠 |
| TerminalPanel（libghostty） | ✅ | 基础渲染 + 进程启动 |
| TodoPanel（最简版） | ✅ | 标题 + prompt + 手动勾选 |
| 点击 To-Do 启动 CLI | ✅ | 修饰键 + CLI 弹窗 + 临时文件 |
| 沉浸式可折叠侧栏 | ✅ | 最大化主区域 |
| 窗口分割 | ⚠️ 基础 | 水平/垂直，修饰键触发 |
| 通知系统 | ⚠️ 基础 | 进程退出 → 通知 |
| 项目持久化 | ❌ | V0.2 |
| Git Diff Panel | ❌ | V0.8 |
| 会话独立 | ❌ | V1.0 |

---

## 八、数据模型

### 8.1 Project

```swift
struct Project: Identifiable, Codable, Equatable {
    let id: UUID
    var path: String              // 本地目录路径（String 方便 Codable）
    var name: String              // 显示名（默认取目录名）
    var defaultCLI: CLIType       // 项目级默认 CLI
    var lastOpenedAt: Date        // 最后打开时间，用于排序
}
```

### 8.2 Todo

```swift
struct Todo: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String             // 任务标题（用作终端窗口标题）
    var prompt: String            // 详细 prompt（写入临时文件传给 CLI）
    var status: TodoStatus        // pending / running / completed
    var preferredCLI: CLIType?    // 可选，覆盖项目默认
    var createdAt: Date
    var updatedAt: Date
}

enum TodoStatus: String, Codable, Equatable {
    case pending
    case running
    case completed
}
```

### 8.3 TerminalSession

```swift
struct TerminalSession: Identifiable {
    let id: UUID
    let projectID: UUID
    let todoID: UUID?              // 关联的 To-Do（可空）
    let cliType: CLIType
    let promptFile: URL            // /tmp/your-app/<uuid>.prompt
    let startedAt: Date
    var status: SessionStatus      // running / exited / failed
    var exitCode: Int32?
    var exitedAt: Date?
}

enum SessionStatus: Equatable {
    case running
    case exited(code: Int32)
    case failed(error: String)
}
```

### 8.4 CLI 适配器

```swift
enum CLIType: String, Codable, CaseIterable, Identifiable, Equatable {
    case claudeCode = "claude"
    case openCode = "opencode"
    case codex = "codex"

    var id: String { rawValue }
    var displayName: String { ... }
}

protocol CLIAdapter {
    var cliType: CLIType { get }
    func startCommand(promptFile: URL) -> [String]
}

struct ClaudeCodeAdapter: CLIAdapter { ... }
struct OpenCodeAdapter: CLIAdapter { ... }
struct CodexAdapter: CLIAdapter { ... }
```

### 8.5 数据存储

| 数据 | 存储位置 | 备注 |
|---|---|---|
| Project 列表 | App 私有数据目录（如 `~/Library/Application Support/Wisp/projects.json`） | 用户私有 |
| Todo（短期方案） | 与 Project 一起 | 简单 |
| Todo（长期方案，待讨论） | 项目根目录 `.wisp/todos.md` | 可进 git，团队共享 |
| TerminalSession | 内存（MVP）→ sqlite（V1.0 持久化） | V1.0 才需要持久化 |
| 临时 prompt 文件 | `/tmp/wisp/<uuid>.prompt` | 进程退出后清理 |

> ⚠️ Todo 存储位置（私有 vs 项目内）需后续讨论确定。

---

## 九、UI 布局

### 9.1 主窗口布局示意

```
┌─────────────────────────────────────────────────────────────────┐
│ ⬜ ⬜ ⬜      App 标题栏（Wisp）                                │
├──────────┬──────────────────────────────────────────────────────┤
│          │                                                       │
│  📁      │  ┌──────────────┬──────────────┐                    │
│ 项目侧栏  │  │              │              │                    │
│         │  │              │              │                    │
│ ▾ 项目A  │  │   终端 Panel  │  TodoPanel   │                    │
│   • TODO │  │  (claude)    │              │                    │
│   • 终端 │  │              │  ☐ 修 bug    │                    │
│         │  │              │  ☐ 加测试    │                    │
│ ▸ 项目B  │  │              │  ☑ 重构 ✓    │                    │
│         │  ├──────────────┴──────────────┤                    │
│ ▸ 项目C  │  │                                                    │
│         │  │     终端 Panel（opencode）                          │
│ [+ 项目] │  │                                                    │
│         │  └──────────────────────────────┘                    │
└──────────┴──────────────────────────────────────────────────────┘

操作要点：
  - 项目侧栏可折叠（沉浸模式）
  - 主区域支持任意水平/垂直分割
  - 每个 Panel 标题栏显示其类型与关联的 To-Do（如有）
```

### 9.2 沉浸式模式

- 快捷键：`⌘⇧F`
- 行为：隐藏侧栏 + 隐藏标题栏装饰，最大化主 Panel 区域
- 鼠标移到屏幕左侧边缘 → 侧栏临时浮出（不挤压内容）

---

## 十、商业模式与许可

### 10.1 商业模式

**完全开源 + 永久免费。**

无付费墙、无订阅、无功能阉割，**最新版永远免费可获得**。

### 10.2 许可证

候选：**MIT 或 Apache 2.0**（最终决定待定）。

理由：
- 最宽松，对用户和贡献者无心理负担
- 不限制商业衍生（避免 GPL 的传染性限制）
- 与 Swift / libghostty 生态主流许可兼容

### 10.3 必要支出

| 项目 | 费用 | 是否必须 |
|---|---|---|
| Apple Developer 账户 | $99/年 | ✅ 必须（代码签名 + 公证） |
| 域名（如要建官网） | ~$15/年 | 可选 |
| 服务器（如需要） | $0（MVP 不需要） | 可选 |

### 10.4 资金来源（可选）

- GitHub Sponsors（推荐，README 显眼链接）
- Open Collective（可选）
- **不接受影响产品决策的赞助**

---

## 十一、项目治理承诺

### 11.1 迭代节奏（核心承诺）

> **绝不接受 cmux 那样的月更频率。**

| 类型 | 目标节奏 |
|---|---|
| Bug 修复 | 发现即修，下个版本必带 |
| 小功能 | 每周或双周一次 minor 版本 |
| 重大功能 | 每月一次 major 版本（非阻塞 minor） |
| 紧急安全修复 | 24 小时内 patch |

### 11.2 反馈机制

| 渠道 | 用途 |
|---|---|
| GitHub Issues | bug、功能请求、讨论（主要渠道） |
| GitHub Discussions | 开放性话题、答疑 |
| Discord（可选） | 社区实时交流 |

### 11.3 路线图透明

- GitHub Projects 公开 Roadmap
- **明确写出"不做什么"**，避免承诺过度
- 每个版本发布时附上 Changelog

### 11.4 贡献机制（第一天就建好）

- `CONTRIBUTING.md` 贡献指南
- Issue 模板（bug / feature / question）
- PR 模板（含 checklist）
- Code of Conduct
- 自动化 CI 检查

---

## 十二、路线图

```
┌──────────────────────────────────────────────────────────────┐
│  MVP（目标 1 周内可用版本）                                     │
│  ─────────────────────────────────────────────────────────  │
│  ✓ Panel 协议 + 抽象架构                                       │
│  ✓ 项目侧栏（一级分类）                                        │
│  ✓ TerminalPanel（libghostty 渲染）+ 水平/垂直分割              │
│  ✓ TodoPanel（最简版：标题 + prompt + 手动勾选）                 │
│  ✓ 点击 To-Do 启动 CLI 完整流程                                 │
│    ├ 修饰键决定窗口位置                                        │
│    ├ CLI 选择小弹窗（Claude Code / OpenCode）                  │
│    ├ Prompt 通过临时文件传递                                   │
│    └ 进程退出 → 通知 → 聚焦 + 闪烁                              │
│  ✓ 沉浸式可折叠侧栏                                            │
├──────────────────────────────────────────────────────────────┤
│  V0.2（吸引早期用户）                                          │
│  ─────────────────────────────────────────────────────────  │
│  ─ To-Do 模板变量（{{branch}} / {{file}} 等）                  │
│  ─ 任务历史记录                                                │
│  ─ 进程退出 → 弹"标记完成？"小提示（半自动打勾）                  │
│  ─ Codex 等更多 CLI Adapter                                  │
├──────────────────────────────────────────────────────────────┤
│  V0.5（拉开和 cmux 的差距）                                     │
│  ─────────────────────────────────────────────────────────  │
│  ─ 自动 git worktree 隔离（可选开关）                          │
│  ─ 批量启动多个 To-Do                                          │
│  ─ 通知聚合（多个完成不刷屏）                                   │
│  ─ Todo 模板库（用户可保存常用 prompt 模板）                    │
├──────────────────────────────────────────────────────────────┤
│  V0.8（Git 集成）                                              │
│  ─────────────────────────────────────────────────────────  │
│  ─ GitDiffPanel（查看当前 working tree 的 git diff）           │
│  ─ Diff 与 To-Do 联动（看任务产生的更改）                       │
│  ─ Stage / Unstage（可选）                                     │
├──────────────────────────────────────────────────────────────┤
│  V1.0（核心理念落地）                                          │
│  ─────────────────────────────────────────────────────────  │
│  ─ 会话独立于窗口（Session 一等公民）                          │
│  ─ 会话后台运行 + 重连                                         │
│  ─ 会话状态持久化（重启 App 恢复）                              │
│  ─ 同一会话多视图同步显示                                       │
└──────────────────────────────────────────────────────────────┘
```

---

## 十三、待决策事项

> 这些是讨论中**已经识别但暂未拍板**的问题，开发推进前需逐项确认。

| ID | 决策点 | 当前倾向 | 阻塞版本 |
|---|---|---|---|
| D1 | License 选 MIT 还是 Apache 2.0 | Apache 2.0（更明确专利条款） | 首次发布前 |
| D2 | Todo 存私有目录 vs 项目内 `.wisp/todos.md` | 待讨论 | V0.2 之前 |
| D3 | App 名称 / 仓库名 / 域名 | Wisp | 首次推 GitHub 之前 |
| D4 | 是否提供 CLI 安装的内嵌引导（用户没装 claude 怎么办） | MVP 提示用户自行安装 | V0.2 |
| D5 | 是否做 Tab UI（除了分割之外） | 待讨论 | V0.2 |
| D6 | "完成"自动判定的具体方案（L2/L3/L4 选哪个）| L2（进程退出弹提示） | V0.2 |
| D7 | 多窗口布局是否支持自由拖拽（类 Figma） | 暂不做，等用户提需求 | 后期 |
| D8 | 数据持久化用 JSON vs sqlite | MVP 用 JSON，V1.0 切 sqlite | V1.0 之前 |

---

## 十四、明确不做的事

为避免范围蔓延，以下功能**当前明确不做**（如有需求请走 issue 提报）：

- ❌ Windows / Linux 版本（专注 macOS 原生体验）
- ❌ 云端同步 / 多设备同步（隐私优先 + 减少基础设施成本）
- ❌ 集成 IDE 功能（编辑器、语法高亮，与 VS Code/Xcode 重叠）
- ❌ 内置 AI 模型（只做 CLI 启动器，不做模型层）
- ❌ 团队多人协作 / 共享会话（个人工具优先）
- ❌ 移动端（iOS/iPad）
- ❌ 复杂的自动化判定"任务完成"（L4/L5 方案）

---

## 十五、术语表

| 术语 | 含义 |
|---|---|
| Wisp | 产品名称 |
| Project | 项目，绑定本地目录，组织 Panel 和 Todo |
| Panel | 视图单元，可插拔类型（终端/Todo/Diff/...） |
| Session | 会话，V1.0 引入；独立于 Panel 的进程实体 |
| Todo | 项目内的可启动任务，包含 prompt |
| CLI Adapter | CLI 启动方式的适配器（Claude Code / OpenCode 各一份实现） |
| libghostty | Ghostty 终端的核心 C 库，提供 PTY/VT/Metal 渲染 |
| GhosttyKit.xcframework | libghostty 的 Apple 平台预编译包 |
| libghostty-spm | 通过 Swift Package Manager 分发的 GhosttyKit |
| InMemoryTerminalSession | GhosttyTerminal 提供的沙盒终端会话（无真实 PTY，MVP 使用） |
| TTY / PTY | 伪终端（Pseudo Terminal），真正的交互式终端需要 PTY |

---

## 十六、已知限制与后续优化

| 限制 | 原因 | 优化方向 |
|---|---|---|
| `InMemoryTerminalSession` 无真实 TTY | GhosttyTerminal 的 `.exec` backend 需要 `login` 权限，MVP 暂用沙盒模式 | 后续改用 `.exec` 或自建 PTY |
| `ls` 等命令输出格式可能不对 | 无 TTY 时命令认为自己不在终端上 | 同上 |
| 终端尺寸感知可能不完美 | `GeometryReader` + `resize` 回调需精细调优 | 调优 `TerminalSurfaceView` 尺寸传递 |
| 窗口分割暂不支持拖拽调整 | SwiftUI 原生不支持可拖拽分割器 | 后续用 AppKit 实现 |

---

## 文档变更记录

| 日期 | 变更 | 备注 |
|---|---|---|
| 2026-05-03 | 初版 | 基于初次产品讨论锁定核心定位、功能边界、技术栈 |
| 2026-05-03 | v0.1.1 | 新增产品名 Wisp、已知限制章节、术语表更新 |

---

*本文档为产品讨论的阶段性快照，将随讨论持续演进。任何与本文档冲突的实现决定需先回到本文档讨论修订。*

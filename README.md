# Wisp

> 一个完全开源、永久免费、快速迭代的 macOS 原生 AI 编码代理终端应用。

## 一句话介绍

**Wisp** 以"项目 + 任务"为中心，让你通过 To-Do 列表一键启动 Claude Code、OpenCode 等 AI 编码代理，告别反复手敲 prompt 的低效工作流。

## 为什么做 Wisp

现有终端应用（如 cmux）存在三个核心痛点：

1. **开源精神不到位** — 最新功能藏在付费墙后面
2. **迭代节奏太慢** — 一个月才更新一次，bug 修得比 AI 发展还慢
3. **没有任务驱动的工作流** — 每次都要手动 cd、启动 CLI、写 prompt

Wisp 的目标是：**修复以上全部问题。**

## 核心特性

- **任务驱动** — 把 prompt 沉淀为项目内的 To-Do，点击即启动
- **多 CLI 支持** — Claude Code / OpenCode / Codex，一键切换
- **项目为中心** — 左侧项目侧栏，每个项目独立管理任务和终端
- **流畅终端** — 基于 Ghostty 的 Metal GPU 渲染，120fps
- **完全开源 + 永久免费** — 最新版永远免费，没有付费墙

## 快速开始

### 环境要求

- macOS 14+
- Xcode 16+
- Apple Silicon / Intel Mac

### 本地构建

```bash
git clone <仓库地址>
cd Wisp
# 用 Xcode 打开项目
open demo.xcodeproj
```

在 Xcode 中：

1. 等待 Swift Package Manager 下载依赖（libghostty-spm）
2. 选择目标设备（My Mac）
3. 按 `⌘+R` 运行

### 添加依赖

如果这是第一次克隆，需要在 Xcode 中手动添加 Swift Package：

```
File → Add Package Dependencies...
https://github.com/Lakr233/libghostty-spm.git
```

勾选 **GhosttyTerminal** 和 **GhosttyKit**。

## 技术栈

| 层级 | 技术 |
|---|---|
| 语言 | Swift |
| UI | SwiftUI + AppKit |
| 终端引擎 | libghostty（通过 GhosttyKit.xcframework） |
| 包管理 | Swift Package Manager |

## 路线图

| 版本 | 目标 |
|---|---|
| MVP | 项目侧栏、To-Do 面板、终端渲染、点击启动 CLI |
| V0.2 | To-Do 模板变量、任务历史、Codex 支持 |
| V0.5 | Git worktree 隔离、批量启动、通知聚合 |
| V0.8 | Git Diff Panel |
| V1.0 | 会话独立于窗口、后台运行、状态持久化 |

## 贡献

欢迎提交 Issue 和 PR。

- 发现 bug？直接开 Issue
- 想要新功能？先开 Issue 讨论
- 想写代码？Fork → 改 → PR

## License

[MIT](LICENSE) 或 [Apache 2.0](LICENSE) — 最终确定后更新

---

*Wisp 正在快速迭代中，文档和 API 可能随时变化。*

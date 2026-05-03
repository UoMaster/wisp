# Wisp 项目搭建指南

## 当前状态

Wisp 的源代码骨架已经创建完毕，包含以下模块：

```
demo/
├── Core/
│   ├── Protocols/
│   │   └── Panel.swift          # Panel 协议
│   └── Models/
│       ├── CLIType.swift        # CLI 类型 + 适配器
│       ├── Project.swift        # 项目模型
│       ├── Todo.swift           # To-Do 模型
│       └── TerminalSession.swift # 会话模型
├── UI/
│   ├── MainWindow.swift         # 主窗口（NavigationSplitView）
│   ├── ProjectDetailView.swift  # 项目详情（TodoPanel + TerminalPanel）
│   ├── Sidebar/
│   │   └── ProjectSidebar.swift # 项目侧栏
│   └── Panels/
│       ├── TodoPanel.swift      # To-Do 列表 + 新建任务
│       └── TerminalPanel.swift  # 终端占位符
├── demoApp.swift                # App 入口
├── ContentView.swift            # 根视图（包装 MainWindow）
└── Assets.xcassets/             # 资源
```

## 第一步：将新文件添加到 Xcode 项目

因为通过命令行创建的文件**不会自动出现在 Xcode 项目导航栏中**，你需要手动添加：

1. 打开 `demo.xcodeproj`
2. 在左侧项目导航栏中，右键点击 `demo` 文件夹
3. 选择 **Add Files to "demo"...**
4. 选中以下文件夹（按住 ⌘ 多选）：
   - `Core`
   - `UI`
5. 确保勾选 **"Create folder references"**（或 "Create groups"）
6. 点击 **Add**

> ⚠️ 不要重复添加 `demoApp.swift` 和 `ContentView.swift`，它们已经在项目里了。

## 第二步：添加 libghostty-spm 依赖

1. 在 Xcode 中，点击顶部菜单 **File → Add Package Dependencies...**
2. 在搜索框输入：
   ```
   https://github.com/Lakr233/libghostty-spm.git
   ```
3. 点击 **Add Package**
4. 在弹出的选择界面中，勾选需要的产品：
   - ✅ `GhosttyTerminal`（Swift wrapper，含 SwiftUI 集成）
   - ✅ `GhosttyKit`（C API，底层访问）
   - ⬜ `GhosttyTheme`（可选，终端配色主题）
   - ⬜ `ShellCraftKit`（可选，沙盒 shell）
5. 点击 **Add Package**

## 第三步：编译验证

1. 按 `⌘+B` 编译
2. 预期结果：**编译通过**（当前 TerminalPanel 是占位符，不依赖 libghostty）
3. 按 `⌘+R` 运行
4. 你应该看到：
   - 左侧项目侧栏（目前只有一个"添加项目"按钮）
   - 点击"添加项目"会添加一个 demo 项目
   - 选中项目后，右侧显示 TodoPanel + TerminalPanel 分割布局

## 第四步：集成 libghostty（后续步骤）

当前 `TerminalPanel.swift` 是占位符。集成 libghostty 时需要：

1. 在 `TerminalPanel.swift` 中 `import GhosttyTerminal`
2. 使用 `GhosttyTerminalView`（或对应的 SwiftUI View）替换占位符内容
3. 通过 `GhosttyKit` 的 C API 创建 surface、绑定 PTY

具体集成代码将在后续迭代中补充。

## 常见问题

### Q: 编译报错 "Cannot find 'ContentView' in scope"
**A**: 确保 `ContentView.swift` 已被 Xcode 项目引用（检查左侧导航栏是否有它）。如果没有，用 **Add Files to "demo"...** 手动添加。

### Q: 编译报错 "'main' attribute cannot be used in a module that contains top-level code"
**A**: 检查是否同时存在多个 `@main`（比如 `demoApp.swift` 和某个新文件都有）。确保只有 `demoApp.swift` 里有 `@main`。

### Q: 新文件夹在 Xcode 里显示为蓝色（folder reference）而不是黄色（group）
**A**: 添加文件时选择 **"Create groups"** 而非 "Create folder references"，或者后续右键蓝色文件夹 → **Show in Finder** 确认文件存在即可，不影响编译。

## 下一步开发任务

按优先级排序：

1. **项目持久化**：把项目列表存到本地（JSON / UserDefaults）
2. **文件选择器**：点击"添加项目"时弹出 `NSOpenPanel` 让用户选目录
3. **To-Do 持久化**：每个项目的 To-Do 列表跟随项目保存
4. **TerminalPanel 集成 libghostty**：替换占位符，真正渲染终端
5. **点击 To-Do 启动 CLI**：完整流程（CLI 选择弹窗 → 临时文件 → 启动进程）
6. **窗口分割**：水平/垂直分割当前 Panel
7. **通知系统**：进程退出 → UNUserNotificationCenter

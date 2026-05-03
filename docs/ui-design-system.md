# UI 设计系统

> Wisp 视觉规范 v0.1 —— 锁定品牌、token、组件外观,作为后续迭代的仲裁依据。

---

## 一、设计哲学

### 1.1 风格定位

**开发者工具系**(Developer Tool Aesthetic)—— 参考但不抄袭以下产品:

| 产品 | 借鉴点 |
|---|---|
| Linear | 极致克制的 indigo accent、发丝边框、字体节奏 |
| Warp | 终端工具该有的"专业感",非花哨 |
| Zed | Flat 表面、几乎无阴影、大量留白 |
| Raycast | 轻量级状态点、紧凑而不拥挤 |
| Ghostty | 与 libghostty 视觉一致的暗色基调 |

### 1.2 三条原则

1. **克制 > 装饰**:不用渐变、不用大面积阴影、不用 emoji 当图标。
2. **层次靠空间和颜色,不靠分隔线**:分隔线最多发丝级,层次靠 bg 颜色阶梯拉开。
3. **暗色为基准,亮色为镜像**:先把暗色做对,亮色按对应关系平移。

### 1.3 不做什么

- ❌ 圆胶囊系统按钮(`.borderedProminent`)
- ❌ 大块阴影 / box-shadow 堆叠
- ❌ Emoji icon(用 SF Symbols)
- ❌ 渐变背景(终端 App 不需要)
- ❌ 默认窗口标题栏装饰(用 `.hiddenTitleBar`)

---

## 二、颜色 Token

> 所有颜色定义在 `demo/Design/Theme.swift`,通过 `NSColor` 的 `dynamicProvider` 实现亮暗自动切换。

### 2.1 Background 层级(从下到上)

| Token | 暗色 | 亮色 | 用途 |
|---|---|---|---|
| `bgWindow` | `#0E0F12` | `#FAFAFB` | 主窗口最底层 |
| `bgSurface` | `#15171B` | `#F4F5F7` | 侧栏、面板背景 |
| `bgRaised` | `#191C21` | `#FFFFFF` | 卡片、空闲列表项 |
| `bgHover` | `#1F2329` | `#EEF0F3` | hover、键盘聚焦 |
| `bgSelected` | `accent @ 14%` | `accent @ 10%` | 列表选中 |
| `bgOverlay` | `#1F2227` | `#FFFFFF` | Sheet、Popover |

设计原则:相邻两层的明度差 ≤ 15%,避免产生"卡片飘起来"的视觉突兀。

### 2.2 Text

| Token | 暗色 | 亮色 | 用途 |
|---|---|---|---|
| `textPrimary` | `#ECECEE` | `#18181B` | 标题、正文重点 |
| `textSecondary` | `#9DA0A6` | `#5C5F66` | 描述、说明 |
| `textTertiary` | `#6A6D74` | `#8E9097` | placeholder、metadata |
| `textOnAccent` | `#FFFFFF` | `#FFFFFF` | 在 accent 实色上的文字 |

对比度:`textPrimary` vs `bgWindow` 双模都 ≥ 12:1,远超 WCAG AAA 7:1。

### 2.3 Border(发丝级)

| Token | 暗色 | 亮色 | 用途 |
|---|---|---|---|
| `borderSubtle` | `white @ 6%` | `black @ 6%` | 列表项之间 |
| `borderDefault` | `white @ 10%` | `black @ 10%` | 卡片、输入框 |
| `borderStrong` | `white @ 18%` | `black @ 16%` | focus 态 |

边框宽度统一 `0.5pt`(retina 上 1 物理像素),Wisp 全局**几乎不用 1pt 实线**。

### 2.4 Accent

| Token | 暗色 | 亮色 |
|---|---|---|
| `accent` | `#7C7AED` | `#6E6CE0` |
| `accentHover` | `#8E8CF1` | `#5C5AD0` |
| `accentSoft` | `accent @ 14%` | `accent @ 10%` |

Wisp 紫的来历:在 Linear `#5E6AD2` 的基础上提亮、降饱和,让它在终端深色背景上更"有空气感"。

### 2.5 Status

| Token | 暗色 | 亮色 | 含义 |
|---|---|---|---|
| `statusRunning` | `#60A5FA` | `#3B82F6` | 任务运行中 |
| `statusSuccess` | `#4ADE80` | `#16A34A` | 任务完成 / 终端 alive |
| `statusWarning` | `#FBBF24` | `#D97706` | 警告 |
| `statusDanger` | `#F87171` | `#DC2626` | 失败 / 危险 |

**只在有语义时使用**——避免把它们当装饰色刷在卡片上。

### 2.6 Terminal

| Token | 颜色 | 备注 |
|---|---|---|
| `terminalBg` | `#0B0C0E` | 不随系统主题,永远深色 |

终端区域不参与亮暗切换。开发者期望终端永远是深色背景。

---

## 三、字体

### 3.1 字体族

零外部字体依赖,只用 macOS 系统字体:

| 用途 | Font | design 参数 |
|---|---|---|
| UI | SF Pro Text | `.default` |
| Mono(代码、shell 名、ID) | SF Mono | `.monospaced` |
| 终端正文 | SF Mono(由 GhosttyTerminal 控制) | — |

### 3.2 Type Scale

定义在 `demo/Design/Typography.swift` 的 `WispFont` 枚举:

| Token | 大小 | 字重 | 用途 |
|---|---|---|---|
| `title` | 20pt | semibold | About 页主标题(暂未使用) |
| `panelTitle` | 13pt | semibold | 面板顶部标题 |
| `sectionTitle` | 11pt | semibold | 区块标题(配 `.uppercase + tracking 0.6`) |
| `body` | 13pt | regular | 列表项、正文 |
| `bodyMedium` | 13pt | medium | 强调正文、按钮 |
| `bodySmall` | 12pt | regular | 描述、metadata |
| `caption` | 11pt | medium | 标签、徽章 |
| `mono` | 13pt | regular | 等宽正文 |
| `monoSmall` | 11pt | regular | 路径、ID、shell 名 |

字号选择遵循 4pt 小步长(11→12→13→16→20),不出现 14pt / 15pt 等"中间值",保证视觉节奏。

### 3.3 Section Title 修饰器

用 `.sectionTitleStyle()` 一键应用:

```swift
Text("项目")
    .sectionTitleStyle()
// = font(11/semibold) + uppercase + tracking 0.6 + textTertiary
```

效果 `项目` → `项 目`(大写 + 字距撑开 + 暗灰),开发者工具常用的"区块标签"风格。

---

## 四、间距 / 圆角 / 描边

### 4.1 4pt 网格

定义在 `demo/Design/Spacing.swift` 的 `Space` 枚举:

| Token | 值 | 用途 |
|---|---|---|
| `xxs` | 2 | 紧贴的图标与文字 |
| `xs` | 4 | inline 元素之间 |
| `sm` | 8 | 列表项内部 |
| `md` | 12 | 卡片内边距 |
| `lg` | 16 | 面板边距 |
| `xl` | 20 | 大区块边距 |
| `xxl` | 28 | 一级区块上下 |
| `huge` | 40 | 留白 |

### 4.2 圆角

`Radius` 枚举:

| Token | 值 | 用途 |
|---|---|---|
| `xs` | 3 | 内联标记、徽章 |
| `sm` | 5 | 按钮、输入框 |
| `md` | 7 | 卡片、列表项 |
| `lg` | 10 | 面板、Sheet |
| `xl` | 14 | 大型容器 |

奇数圆角(5/7)是故意的——比 4/8 偶数更"软",同时不至于像 Material Design 那样圆。

### 4.3 描边宽度

`Stroke` 枚举:

| Token | 值 | 用途 |
|---|---|---|
| `hairline` | 0.5 | 默认 |
| `normal` | 1 | 状态点描边 |
| `strong` | 1.5 | focus ring |

---

## 五、动效

定义在 `Motion` 枚举:

| Token | 值 | 用途 |
|---|---|---|
| `fast` | 0.15s | hover 颜色切换 |
| `base` | 0.20s | 选中态 |
| `slow` | 0.30s | sheet / 模态切换 |

**易动曲线**:统一用 SwiftUI 的 `.easeOut(duration:)`。如果未来需要更"弹"的感觉,可以引入 `Bezier(0.16, 1, 0.3, 1)`(Linear 同款)。

---

## 六、组件库

### 6.1 ButtonStyle

定义在 `demo/UI/Components/WispButton.swift`:

| 用法 | 适用场景 |
|---|---|
| `.buttonStyle(.wispPrimary)` | 主 CTA(创建任务、确认) |
| `.buttonStyle(.wispGhost)` | 次要操作(取消、添加项目) |
| `.buttonStyle(.wispIcon)` | toolbar 图标按钮(关闭、分割) |

### 6.2 状态点

```swift
StatusDot(status: .running, size: 8)
```

替代默认的 SF Symbol icon —— 紧凑、可控,running 态自带光晕。

### 6.3 分隔线

```swift
WispDivider()                      // 水平,默认
WispDivider(axis: .vertical)       // 垂直
```

比 SwiftUI 默认的 `Divider` 更克制,只在颜色 token `borderSubtle` 上画 0.5pt。

### 6.4 修饰器(View extension)

| 修饰器 | 用途 |
|---|---|
| `.wispCard(padding:)` | 标准卡片 |
| `.wispRowBackground(isSelected:isHovered:)` | 列表项底色 |
| `.wispBordered(radius:color:lineWidth:)` | 加发丝边框 |
| `.trackHover($state)` | 跟踪 hover 状态 |
| `.sectionTitleStyle()` | 区块标题样式 |

---

## 七、布局约定

### 7.1 主窗口三栏结构

```
┌─────────────────────────────────────────────────────────┐
│ (无标题栏 - hiddenTitleBar)                             │
│                                                          │
│   ┌──────────┬──────────┬──────────────────────────┐    │
│   │          │          │                          │    │
│   │ Sidebar  │ TodoPanel│      TerminalPanel       │    │
│   │  220-340 │ 280-380  │       min 480            │    │
│   │  bgSurfa │ bgSurface│       bgWindow + 终端    │    │
│   │          │          │                          │    │
│   └──────────┴──────────┴──────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

- **三栏分隔线**:用 `WispDivider(axis: .vertical)`(发丝级 0.5pt)
- **背景层级**:Sidebar/TodoPanel 用 `bgSurface`,Terminal 区用 `bgWindow`,形成"边栏沉下、终端浮起"的感觉
- **窗口最小尺寸**:900 × 600,默认 1280 × 820

### 7.2 面板 header 模式

每个 Panel 顶部统一是:

```
[icon/dot] [Title] [count badge] ··· [icon button] [icon button]
└─ horizontal lg, vertical md
└─ 底部 WispDivider
```

实现样板见 `TodoPanel.swift` / `TerminalPanel.swift` 的 `header` 计算属性。

### 7.3 Sheet 模式

Sheet 三段结构:`header → divider → body → divider → footer (按钮组)`,所有 sheet 都遵守这个布局。样板见 `AddTodoSheet`。

---

## 八、Pre-Delivery Checklist(每次提交 UI 改动前自检)

### 视觉

- [ ] 所有图标用 SF Symbols,**没有任何 emoji**
- [ ] 颜色全部走 `Theme.*`,没有写死的 `Color(hex: ...)` 或 `Color.gray`
- [ ] 圆角用 `Radius.*`,不出现 `cornerRadius: 4` 这种魔数
- [ ] 间距用 `Space.*`,不出现 `padding(10)` 这种魔数

### 交互

- [ ] hover/选中/按下三态都有视觉反馈,且都通过 `Theme.bg*` 切换
- [ ] 动画统一 150-300ms,易动曲线 `.easeOut`
- [ ] 按钮用三种 `wisp*` ButtonStyle 之一
- [ ] 可点击区域 ≥ 22×22pt(macOS 紧凑 toolbar)

### 双模

- [ ] 切到亮色模式核对:边框、文字、accent 都还看得清
- [ ] 终端区域无论亮暗都保持深色 `terminalBg`
- [ ] Selected/Hover 在亮色模式下不会"糊成一团"

### 代码

- [ ] 没有把样式写在 View 里,而是用 modifier / token / ButtonStyle 复用
- [ ] 新增的颜色 / 字号 / 间距先看现有 token 能不能满足,确实不够再扩

---

## 九、变更记录

| 日期 | 变更 | 备注 |
|---|---|---|
| 2026-05-03 | v0.1 初版 | 锁定 token 体系、组件库、布局规范 |

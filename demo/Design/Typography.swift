//
//  Typography.swift
//  Wisp
//
//  设计 token —— 字体。
//  规则:零外部字体依赖,只用 macOS 系统字体。
//  - SF Pro Text:UI 文字(系统默认)
//  - SF Mono:终端、代码、tabular 数字
//

import SwiftUI

enum WispFont {

    // MARK: - 标题

    /// 窗口主标题级别(目前未在主界面使用,留给设置 / About 等场景)
    static let title = Font.system(size: 20, weight: .semibold, design: .default)

    /// 区块标题 —— 例如 "TODO" "TERMINAL"
    static let sectionTitle = Font.system(size: 11, weight: .semibold, design: .default)

    /// 面板顶部标题
    static let panelTitle = Font.system(size: 13, weight: .semibold, design: .default)

    // MARK: - 正文

    /// 主正文 —— 列表项、卡片标题
    static let body = Font.system(size: 13, weight: .regular, design: .default)

    /// 强调正文
    static let bodyMedium = Font.system(size: 13, weight: .medium, design: .default)

    /// 次级正文 —— 描述、metadata
    static let bodySmall = Font.system(size: 12, weight: .regular, design: .default)

    /// 标签 / 微小文字
    static let caption = Font.system(size: 11, weight: .medium, design: .default)

    // MARK: - 等宽

    /// 终端字体 —— 由 GhosttyTerminal 自己控制,这里只是 fallback
    static let mono = Font.system(size: 13, weight: .regular, design: .monospaced)

    /// 数字、键盘快捷键、ID
    static let monoSmall = Font.system(size: 11, weight: .regular, design: .monospaced)
}

// MARK: - Section Title Modifier

extension View {
    /// 区块标题样式 —— 大写、字距、暗色文字
    func sectionTitleStyle() -> some View {
        self
            .font(WispFont.sectionTitle)
            .tracking(0.6)
            .textCase(.uppercase)
            .foregroundStyle(Theme.textTertiary)
    }
}

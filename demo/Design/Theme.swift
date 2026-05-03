//
//  Theme.swift
//  Wisp
//
//  设计 token —— 颜色。
//  规则:所有颜色都是 dynamic color,自动随系统外观切换。
//  深色为基准设计,浅色作为镜像适配。
//

import SwiftUI
import AppKit

enum Theme {

    // MARK: - Background (从下到上的层级)

    /// 主窗口背景 —— 整个 App 最底层
    static let bgWindow = dyn(dark: 0x0E0F12, light: 0xFAFAFB)

    /// 一级容器 —— 侧栏、面板背景
    static let bgSurface = dyn(dark: 0x15171B, light: 0xF4F5F7)

    /// 二级容器 —— 卡片、列表项空闲态
    static let bgRaised = dyn(dark: 0x191C21, light: 0xFFFFFF)

    /// 悬浮态 —— hover、键盘聚焦
    static let bgHover = dyn(dark: 0x1F2329, light: 0xEEF0F3)

    /// 选中态 —— 列表选中、当前项目
    static let bgSelected = dyn(
        darkR: 124, darkG: 122, darkB: 237, darkA: 0.14,
        lightR: 110, lightG: 108, lightB: 224, lightA: 0.10
    )

    /// 弹层背景 —— Sheet、Popover
    static let bgOverlay = dyn(dark: 0x1F2227, light: 0xFFFFFF)

    // MARK: - Text

    /// 主文字 —— 标题、正文重点
    static let textPrimary = dyn(dark: 0xECECEE, light: 0x18181B)

    /// 次级文字 —— 描述、说明
    static let textSecondary = dyn(dark: 0x9DA0A6, light: 0x5C5F66)

    /// 三级文字 —— placeholder、辅助
    static let textTertiary = dyn(dark: 0x6A6D74, light: 0x8E9097)

    /// 在 accent 背景上的文字
    static let textOnAccent = Color.white

    // MARK: - Border (发丝级)

    /// 极淡的分隔 —— 列表项之间
    static let borderSubtle = dyn(
        darkR: 255, darkG: 255, darkB: 255, darkA: 0.06,
        lightR: 0,   lightG: 0,   lightB: 0,   lightA: 0.06
    )

    /// 默认边框 —— 卡片、输入框
    static let borderDefault = dyn(
        darkR: 255, darkG: 255, darkB: 255, darkA: 0.10,
        lightR: 0,   lightG: 0,   lightB: 0,   lightA: 0.10
    )

    /// 强调边框 —— focus 态
    static let borderStrong = dyn(
        darkR: 255, darkG: 255, darkB: 255, darkA: 0.18,
        lightR: 0,   lightG: 0,   lightB: 0,   lightA: 0.16
    )

    // MARK: - Accent (品牌色 / CTA)

    /// 主 accent —— Wisp 紫,克制版的 Linear indigo
    static let accent = dyn(dark: 0x7C7AED, light: 0x6E6CE0)

    /// accent hover
    static let accentHover = dyn(dark: 0x8E8CF1, light: 0x5C5AD0)

    /// accent 半透明背景 —— 高亮卡片底色
    static let accentSoft = dyn(
        darkR: 124, darkG: 122, darkB: 237, darkA: 0.14,
        lightR: 110, lightG: 108, lightB: 224, lightA: 0.10
    )

    // MARK: - Status (语义色,只在有意义时使用)

    /// 进行中
    static let statusRunning = dyn(dark: 0x60A5FA, light: 0x3B82F6)

    /// 完成
    static let statusSuccess = dyn(dark: 0x4ADE80, light: 0x16A34A)

    /// 警告
    static let statusWarning = dyn(dark: 0xFBBF24, light: 0xD97706)

    /// 失败 / 危险
    static let statusDanger = dyn(dark: 0xF87171, light: 0xDC2626)

    // MARK: - Terminal (终端独立配色,与亮暗共用)

    /// 终端背景 —— 永远深色,不随系统主题
    static let terminalBg = Color(red: 0x0B/255, green: 0x0C/255, blue: 0x0E/255)
}

// MARK: - Dynamic Color Helpers

private extension Theme {

    /// 16 进制 → 双模 dynamic color
    static func dyn(dark: UInt32, light: UInt32) -> Color {
        Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            isDark(appearance)
                ? NSColor(hex: dark)
                : NSColor(hex: light)
        }))
    }

    /// 带 alpha 的双模 dynamic color
    static func dyn(
        darkR: Int, darkG: Int, darkB: Int, darkA: CGFloat,
        lightR: Int, lightG: Int, lightB: Int, lightA: CGFloat
    ) -> Color {
        Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            if isDark(appearance) {
                return NSColor(srgbRed: CGFloat(darkR)/255,
                               green: CGFloat(darkG)/255,
                               blue: CGFloat(darkB)/255,
                               alpha: darkA)
            } else {
                return NSColor(srgbRed: CGFloat(lightR)/255,
                               green: CGFloat(lightG)/255,
                               blue: CGFloat(lightB)/255,
                               alpha: lightA)
            }
        }))
    }

    static func isDark(_ appearance: NSAppearance) -> Bool {
        appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
    }
}

private extension NSColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(
            srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
            green:   CGFloat((hex >> 8)  & 0xFF) / 255,
            blue:    CGFloat( hex        & 0xFF) / 255,
            alpha:   alpha
        )
    }
}

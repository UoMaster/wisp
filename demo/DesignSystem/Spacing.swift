//
//  Spacing.swift
//  Wisp
//
//  设计 token —— 间距 / 圆角。基于 4pt 网格。
//

import CoreGraphics

enum Space {
    /// 2pt —— 紧贴的图标与文字
    static let xxs: CGFloat = 2
    /// 4pt —— inline 元素之间
    static let xs:  CGFloat = 4
    /// 8pt —— 列表项内部
    static let sm:  CGFloat = 8
    /// 12pt —— 卡片内边距
    static let md:  CGFloat = 12
    /// 16pt —— 面板边距
    static let lg:  CGFloat = 16
    /// 20pt —— 大区块边距
    static let xl:  CGFloat = 20
    /// 28pt —— 一级区块上下
    static let xxl: CGFloat = 28
    /// 40pt —— 留白
    static let huge: CGFloat = 40
}

enum Radius {
    /// 内联标记
    static let xs: CGFloat = 3
    /// 按钮、输入框、状态标签
    static let sm: CGFloat = 5
    /// 卡片、列表项
    static let md: CGFloat = 7
    /// 面板、Sheet
    static let lg: CGFloat = 10
    /// 大型容器
    static let xl: CGFloat = 14
}

enum Stroke {
    /// 发丝级 —— 0.5pt(retina 上 1px)
    static let hairline: CGFloat = 0.5
    /// 普通边框
    static let normal: CGFloat = 1
    /// 强调边框 —— focus 态
    static let strong: CGFloat = 1.5
}

/// 标准过渡曲线 —— Linear 同款 ease-out
/// (注:SwiftUI 的 .easeOut 已经够用,这里仅当需要更细控时使用)
enum Motion {
    static let fast: Double = 0.15
    static let base: Double = 0.20
    static let slow: Double = 0.30
}

//
//  Modifiers.swift
//  Wisp
//
//  可复用的 ViewModifier —— 让组件落到统一的视觉语言上。
//

import SwiftUI

// MARK: - Card

extension View {
    /// 标准卡片容器:bgRaised + 默认边框 + md 圆角
    func wispCard(padding: CGFloat = Space.md) -> some View {
        self
            .padding(padding)
            .background(Theme.bgRaised)
            .clipShape(RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .stroke(Theme.borderDefault, lineWidth: Stroke.hairline)
            )
    }

    /// 列表项 hover/选中态背景
    func wispRowBackground(isSelected: Bool, isHovered: Bool) -> some View {
        let fill: Color = {
            if isSelected { return Theme.bgSelected }
            if isHovered  { return Theme.bgHover }
            return Color.clear
        }()
        return self.background(
            RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                .fill(fill)
        )
    }

    /// 给容器加发丝边框 + 圆角
    func wispBordered(radius: CGFloat = Radius.sm,
                      color: Color = Theme.borderDefault,
                      lineWidth: CGFloat = Stroke.hairline) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(color, lineWidth: lineWidth)
        )
    }
}

// MARK: - Hover Tracking

/// 跟踪鼠标 hover 状态的便捷 modifier
struct HoverTrackingModifier: ViewModifier {
    @Binding var isHovered: Bool

    func body(content: Content) -> some View {
        content.onHover { hovering in
            isHovered = hovering
        }
    }
}

extension View {
    func trackHover(_ isHovered: Binding<Bool>) -> some View {
        modifier(HoverTrackingModifier(isHovered: isHovered))
    }
}

// MARK: - Divider 替代品

/// 比 SwiftUI 默认 Divider 更克制的发丝分隔
struct WispDivider: View {
    enum Axis { case horizontal, vertical }
    var axis: Axis = .horizontal

    var body: some View {
        Rectangle()
            .fill(Theme.borderSubtle)
            .frame(
                width:  axis == .vertical   ? Stroke.hairline : nil,
                height: axis == .horizontal ? Stroke.hairline : nil
            )
    }
}

//
//  WispButton.swift
//  Wisp
//
//  自定义 ButtonStyle —— 取代 .borderedProminent 的"系统蓝胶囊"风格,
//  让 CTA 落到 Wisp 的视觉语言上。
//

import SwiftUI

struct WispButtonStyle: ButtonStyle {
    enum Kind { case primary, ghost, icon }
    let kind: Kind

    @State private var isHovered = false

    func makeBody(configuration: Configuration) -> some View {
        switch kind {
        case .primary:  primaryBody(configuration)
        case .ghost:    ghostBody(configuration)
        case .icon:     iconBody(configuration)
        }
    }

    // MARK: - Primary

    private func primaryBody(_ configuration: Configuration) -> some View {
        configuration.label
            .font(WispFont.bodyMedium)
            .foregroundStyle(Theme.textOnAccent)
            .padding(.horizontal, Space.md)
            .padding(.vertical, Space.sm)
            .background(
                RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                    .fill(isHovered ? Theme.accentHover : Theme.accent)
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: Motion.fast), value: configuration.isPressed)
            .animation(.easeOut(duration: Motion.fast), value: isHovered)
            .onHover { isHovered = $0 }
    }

    // MARK: - Ghost

    private func ghostBody(_ configuration: Configuration) -> some View {
        configuration.label
            .font(WispFont.bodyMedium)
            .foregroundStyle(Theme.textPrimary)
            .padding(.horizontal, Space.md)
            .padding(.vertical, Space.sm)
            .background(
                RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                    .fill(isHovered ? Theme.bgHover : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                    .stroke(Theme.borderDefault, lineWidth: Stroke.hairline)
            )
            .opacity(configuration.isPressed ? 0.7 : 1)
            .animation(.easeOut(duration: Motion.fast), value: isHovered)
            .onHover { isHovered = $0 }
    }

    // MARK: - Icon

    private func iconBody(_ configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(isHovered ? Theme.textPrimary : Theme.textSecondary)
            .frame(width: 22, height: 22)
            .background(
                RoundedRectangle(cornerRadius: Radius.xs, style: .continuous)
                    .fill(isHovered ? Theme.bgHover : Color.clear)
            )
            .opacity(configuration.isPressed ? 0.7 : 1)
            .animation(.easeOut(duration: Motion.fast), value: isHovered)
            .onHover { isHovered = $0 }
    }
}

// MARK: - 便捷 API

extension ButtonStyle where Self == WispButtonStyle {
    static var wispPrimary: WispButtonStyle { .init(kind: .primary) }
    static var wispGhost:   WispButtonStyle { .init(kind: .ghost) }
    static var wispIcon:    WispButtonStyle { .init(kind: .icon) }
}

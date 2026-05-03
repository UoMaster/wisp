//
//  SelectablePill.swift
//  Wisp
//
//  通用的可选中胶囊 —— 标签/优先级/CLI 选项等场景共用。
//

import SwiftUI

struct SelectablePill<Content: View>: View {
    let isSelected: Bool
    let action: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        Button(action: action) {
            content
                .padding(.horizontal, Space.md)
                .padding(.vertical, Space.sm)
                .background(
                    RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                        .fill(isSelected ? Theme.accentSoft : Theme.bgRaised)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                        .stroke(isSelected ? Theme.accent : Theme.borderDefault, lineWidth: Stroke.hairline)
                )
                .foregroundStyle(isSelected ? Theme.accent : Theme.textSecondary)
        }
        .buttonStyle(.plain)
    }
}

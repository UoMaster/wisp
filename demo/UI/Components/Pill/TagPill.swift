//
//  TagPill.swift
//  Wisp
//
//  小型标签芯片 —— 带删除按钮。
//

import SwiftUI

struct TagPill: View {
    let text: String
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 2) {
            Text(text)
                .font(WispFont.monoSmall)
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 8, weight: .bold))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(
            RoundedRectangle(cornerRadius: Radius.xs, style: .continuous)
                .fill(Theme.accentSoft)
        )
        .foregroundStyle(Theme.accent)
    }
}

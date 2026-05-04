//
//  TerminalPanelHeader.swift
//  Wisp
//

import SwiftUI

struct TerminalPanelHeader: View {
    let title: String
    let shellName: String
    let isRunning: Bool
    let onRename: ((String) -> Void)?
    let onClose: (() -> Void)?

    @State private var isEditing = false

    var body: some View {
        HStack(spacing: Space.xs) {
            StatusDot(status: isRunning ? .running : .completed, size: 4)

            if isEditing {
                InlineRenameField(
                    initialText: title,
                    isEditing: $isEditing,
                    font: WispFont.caption,
                    onCommit: { onRename?($0) }
                )
            } else {
                Text(title)
                    .font(WispFont.caption)
                    .foregroundStyle(Theme.textPrimary)
            }

            Text("·")
                .font(WispFont.caption)
                .foregroundStyle(Theme.textTertiary)

            Text(shellName)
                .font(WispFont.monoSmall)
                .foregroundStyle(Theme.textTertiary)

            Spacer()

            if let onClose {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundStyle(Theme.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Space.sm)
        .padding(.vertical, 4)
        .overlay(alignment: .bottom) { WispDivider() }
        .contextMenu {
            if onRename != nil {
                Button("重命名") {
                    isEditing = true
                }
            }
        }
    }
}

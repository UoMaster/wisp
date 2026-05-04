//
//  TerminalPanelHeader.swift
//  Wisp
//

import SwiftUI

struct TerminalPanelHeader: View {
    let title: String
    let shellName: String
    let isRunning: Bool
    let todoVisible: Bool
    let onToggleTodo: () -> Void

    @State private var isHoveringTodoButton = false

    var body: some View {
        HStack(spacing: Space.sm) {
            StatusDot(status: isRunning ? .running : .completed, size: 6)

            Text(title)
                .font(WispFont.panelTitle)
                .foregroundStyle(Theme.textPrimary)

            Text("·")
                .font(WispFont.bodySmall)
                .foregroundStyle(Theme.textTertiary)

            Text(shellName)
                .font(WispFont.monoSmall)
                .foregroundStyle(Theme.textTertiary)

            Spacer()

            Button(action: onToggleTodo) {
                Image(systemName: "checklist")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(todoVisible ? Theme.accent : (isHoveringTodoButton ? Theme.textPrimary : Theme.textSecondary))
                    .frame(width: 28, height: 28)
                    .background(todoVisible ? Theme.accentSoft : (isHoveringTodoButton ? Theme.bgHover : Color.clear))
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(todoVisible ? "隐藏任务列表" : "显示任务列表")
            .accessibilityLabel(todoVisible ? "隐藏任务列表" : "显示任务列表")
            .trackHover($isHoveringTodoButton)
        }
        .padding(.horizontal, Space.lg)
        .padding(.vertical, Space.md)
        .overlay(alignment: .bottom) { WispDivider() }
    }
}

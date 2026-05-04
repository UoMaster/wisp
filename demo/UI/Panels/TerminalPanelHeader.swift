//
//  TerminalPanelHeader.swift
//  Wisp
//

import SwiftUI

struct TerminalPanelHeader: View {
    let title: String
    let shellName: String
    let isRunning: Bool

    var body: some View {
        HStack(spacing: Space.xs) {
            StatusDot(status: isRunning ? .running : .completed, size: 4)

            Text(title)
                .font(WispFont.caption)
                .foregroundStyle(Theme.textPrimary)

            Text("·")
                .font(WispFont.caption)
                .foregroundStyle(Theme.textTertiary)

            Text(shellName)
                .font(WispFont.monoSmall)
                .foregroundStyle(Theme.textTertiary)

            Spacer()
        }
        .padding(.horizontal, Space.sm)
        .padding(.vertical, 4)
        .overlay(alignment: .bottom) { WispDivider() }
    }
}

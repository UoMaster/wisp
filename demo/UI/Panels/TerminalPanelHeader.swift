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

            Button(action: {}) { Image(systemName: "rectangle.split.2x1") }
                .buttonStyle(.wispIcon)
            Button(action: {}) { Image(systemName: "rectangle.split.1x2") }
                .buttonStyle(.wispIcon)
            Button(action: {}) { Image(systemName: "xmark") }
                .buttonStyle(.wispIcon)
        }
        .padding(.horizontal, Space.lg)
        .padding(.vertical, Space.md)
        .overlay(alignment: .bottom) { WispDivider() }
    }
}

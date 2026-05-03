//
//  RunHistoryRow.swift
//  Wisp
//

import SwiftUI

struct RunHistoryRow: View {
    let record: RunRecord
    let index: Int

    var body: some View {
        HStack(spacing: Space.sm) {
            Text("#\(index)")
                .font(WispFont.monoSmall)
                .foregroundStyle(Theme.textTertiary)
                .frame(width: 28, alignment: .leading)

            Image(systemName: record.isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 10))
                .foregroundStyle(record.isSuccess ? Theme.statusSuccess : Theme.statusDanger)

            Text(record.cliType.displayName)
                .font(WispFont.bodySmall)
                .foregroundStyle(Theme.textSecondary)

            Spacer()

            Text(formatDuration(record.duration))
                .font(WispFont.monoSmall)
                .foregroundStyle(Theme.textTertiary)

            Text(record.endedAt, style: .date)
                .font(WispFont.monoSmall)
                .foregroundStyle(Theme.textTertiary)
        }
        .padding(.horizontal, Space.md)
        .padding(.vertical, Space.sm)
    }

    private func formatDuration(_ interval: TimeInterval) -> String {
        let mins = Int(interval) / 60
        let secs = Int(interval) % 60
        if mins > 0 {
            return "\(mins)m \(secs)s"
        }
        return "\(secs)s"
    }
}

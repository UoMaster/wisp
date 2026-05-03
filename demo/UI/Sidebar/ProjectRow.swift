//
//  ProjectRow.swift
//  Wisp
//

import SwiftUI

struct ProjectRow: View {
    let project: Project
    let isSelected: Bool
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: Space.sm) {
            Image(systemName: "folder.fill")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(isSelected ? Theme.accent : Theme.textTertiary)
                .frame(width: 16)

            VStack(alignment: .leading, spacing: 1) {
                Text(project.name)
                    .font(WispFont.bodyMedium)
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)

                Text(project.displayPath)
                    .font(WispFont.monoSmall)
                    .foregroundStyle(Theme.textTertiary)
                    .lineLimit(1)
                    .truncationMode(.head)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, Space.sm)
        .padding(.vertical, Space.xs)
        .frame(maxWidth: .infinity, alignment: .leading)
        .wispRowBackground(isSelected: isSelected, isHovered: isHovered)
        .contentShape(Rectangle())
        .trackHover($isHovered)
    }
}

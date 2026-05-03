//
//  TodoRow.swift
//  Wisp
//

import SwiftUI

struct TodoRow: View {
    let todo: Todo
    let isHovered: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            priorityIndicator

            HStack(alignment: .top, spacing: Space.sm) {
                StatusDot(status: todo.status)
                    .padding(.top, 4)

                VStack(alignment: .leading, spacing: 4) {
                    Text(todo.title)
                        .font(WispFont.bodyMedium)
                        .foregroundStyle(textColor)
                        .lineLimit(1)

                    if !todo.prompt.isEmpty {
                        Text(todo.prompt)
                            .font(WispFont.bodySmall)
                            .foregroundStyle(Theme.textTertiary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }

                    if !todo.tags.isEmpty {
                        HStack(spacing: Space.xs) {
                            ForEach(todo.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(WispFont.monoSmall)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(
                                        RoundedRectangle(cornerRadius: Radius.xs, style: .continuous)
                                            .fill(Theme.accentSoft)
                                    )
                                    .foregroundStyle(Theme.accent)
                            }
                        }
                        .padding(.top, 2)
                    }
                }

                Spacer(minLength: 0)

                if isHovered {
                    HStack(spacing: 4) {
                        if todo.status != .pending {
                            Button(action: {}) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 9, weight: .semibold))
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Theme.textTertiary)
                            .padding(4)
                            .background(Circle().fill(Theme.bgHover))
                        }

                        Image(systemName: "play.fill")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(Theme.accent)
                            .padding(4)
                            .background(Circle().fill(Theme.accentSoft))
                    }
                    .transition(.opacity)
                }
            }
            .padding(.leading, Space.sm)
            .padding(.trailing, Space.sm)
            .padding(.vertical, Space.sm)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .wispRowBackground(isSelected: false, isHovered: isHovered)
        .contentShape(Rectangle())
    }

    private var priorityIndicator: some View {
        Rectangle()
            .fill(PriorityStyle.color(for: todo.priority))
            .frame(width: 3)
            .opacity(todo.priority == .none ? 0 : 1)
    }

    private var textColor: Color {
        switch todo.status {
        case .completed: return Theme.textSecondary
        case .failed:    return Theme.statusDanger.opacity(0.8)
        default:         return Theme.textPrimary
        }
    }
}

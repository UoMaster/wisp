//
//  EmptyProjectState.swift
//  Wisp
//

import SwiftUI

struct EmptyProjectState: View {
    var body: some View {
        VStack(spacing: Space.md) {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    .fill(Theme.bgRaised)
                    .frame(width: 56, height: 56)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                            .stroke(Theme.borderDefault, lineWidth: Stroke.hairline)
                    )

                Image(systemName: "sparkles")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(Theme.accent)
            }

            VStack(spacing: Space.xs) {
                Text("Wisp")
                    .font(WispFont.title)
                    .foregroundStyle(Theme.textPrimary)

                Text("从左侧添加一个项目开始")
                    .font(WispFont.bodySmall)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

//
//  MainWindow.swift
//  Wisp
//

import SwiftUI

struct MainWindow: View {
    @State private var projects: [Project] = []
    @State private var selectedProjectID: UUID?

    var body: some View {
        NavigationSplitView {
            ProjectSidebar(
                projects: $projects,
                selectedProjectID: $selectedProjectID
            )
            .navigationSplitViewColumnWidth(min: 220, ideal: 250, max: 340)
        } detail: {
            detailContent
                .background(Theme.bgWindow)
        }
        .navigationTitle("")
        .toolbar(removing: .title)
        .toolbarBackground(.hidden, for: .windowToolbar)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Color.clear.frame(width: 1, height: 1)
            }
        }
    }

    @ViewBuilder
    private var detailContent: some View {
        if let project = projects.first(where: { $0.id == selectedProjectID }) {
            ProjectDetailView(project: project)
        } else {
            EmptyProjectState()
        }
    }
}

// MARK: - Empty State

private struct EmptyProjectState: View {
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

//
//  MainWindow.swift
//  Wisp
//

import SwiftUI

struct MainWindow: View {
    @StateObject private var store = DataStore()
    @State private var selectedProjectID: UUID?

    @State private var editorPresented = false
    @State private var editorMode: TodoEditorDrawer.Mode = .create
    @State private var editorProjectID: UUID?

    var body: some View {
        ZStack {
            NavigationSplitView {
                ProjectSidebar(
                    store: store,
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

            if editorPresented, let projectID = editorProjectID {
                editorOverlay(projectID: projectID)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .presentTodoEditor)) { notification in
            handlePresentEditor(notification: notification)
        }
    }

    @ViewBuilder
    private var detailContent: some View {
        if let project = store.projects.first(where: { $0.id == selectedProjectID }) {
            ProjectDetailView(store: store, project: project)
        } else {
            EmptyProjectState()
        }
    }

    private func editorOverlay(projectID: UUID) -> some View {
        HStack(spacing: 0) {
            Color.black.opacity(0.15)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeOut(duration: Motion.slow)) {
                        editorPresented = false
                    }
                }
                .transition(.opacity)

            TodoEditorDrawer(
                store: store,
                projectID: projectID,
                mode: editorMode,
                isPresented: Binding(
                    get: { editorPresented },
                    set: { editorPresented = $0 }
                )
            )
            .frame(width: 520)
            .frame(maxHeight: .infinity)
            .background(Theme.bgOverlay)
            .overlay(
                Rectangle()
                    .fill(Theme.borderSubtle)
                    .frame(width: Stroke.hairline)
                    .frame(maxHeight: .infinity),
                alignment: .leading
            )
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .trailing).combined(with: .opacity)
            ))
        }
        .ignoresSafeArea()
        .zIndex(1000)
    }

    private func handlePresentEditor(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let projectID = userInfo[NotificationKey.projectID] as? UUID else { return }

        if let mode = userInfo[NotificationKey.editorMode] as? TodoEditorDrawer.Mode {
            self.editorMode = mode
        } else {
            self.editorMode = .create
        }
        self.editorProjectID = projectID
        withAnimation(.easeOut(duration: Motion.base)) {
            self.editorPresented = true
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

//
//  MainWindow.swift
//  Wisp
//

import SwiftUI

struct MainWindow: View {
    @ObservedObject var projectStore: ProjectStore
    @ObservedObject var todoStore: TodoStore
    let cliRunner: CLIRunner
    let bus: PanelEventBus

    @State private var selectedProjectID: UUID?

    @State private var editorPresented = false
    @State private var editorProjectID: UUID?
    @State private var editorTodoID: UUID?

    var body: some View {
        ZStack {
            NavigationSplitView {
                ProjectSidebar(
                    projectStore: projectStore,
                    todoStore: todoStore,
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
        .onReceive(bus.events) { event in
            guard case let .presentTodoEditor(projectID, todoID) = event else { return }
            editorProjectID = projectID
            editorTodoID = todoID
            withAnimation(.easeOut(duration: Motion.base)) {
                editorPresented = true
            }
        }
    }

    @ViewBuilder
    private var detailContent: some View {
        if let project = projectStore.projects.first(where: { $0.id == selectedProjectID }) {
            ProjectDetailView(
                todoStore: todoStore,
                cliRunner: cliRunner,
                bus: bus,
                project: project
            )
        } else {
            EmptyProjectState()
        }
    }

    private func editorOverlay(projectID: UUID) -> some View {
        let editingTodo: Todo? = {
            guard let id = editorTodoID else { return nil }
            return todoStore.todo(id: id, in: projectID)
        }()

        return HStack(spacing: 0) {
            Color.black.opacity(0.15)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeOut(duration: Motion.slow)) {
                        editorPresented = false
                    }
                }
                .transition(.opacity)

            TodoEditorDrawer(
                todoStore: todoStore,
                projectID: projectID,
                editingTodo: editingTodo,
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
}

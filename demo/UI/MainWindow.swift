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
    @State private var sidebarVisible = true
    @State private var todoVisible = true

    @State private var editorPresented = false
    @State private var editorProjectID: UUID?
    @State private var editorTodoID: UUID?

    @State private var isHoveringExpandButton = false

    var body: some View {
        ZStack {
            // MARK: - 主布局
            HStack(spacing: 0) {
                ProjectSidebar(
                    projectStore: projectStore,
                    todoStore: todoStore,
                    selectedProjectID: $selectedProjectID,
                    onToggle: toggleSidebar
                )
                .frame(width: sidebarVisible ? 250 : 0, alignment: .leading)
                .clipped()
                .opacity(sidebarVisible ? 1 : 0)

                detailContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Theme.bgWindow)
            }

            // MARK: - 展开按钮（始终存在，opacity 控制）
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()

                    Button(action: toggleSidebar) {
                        Image(systemName: "sidebar.right")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(isHoveringExpandButton ? Theme.textPrimary : Theme.textTertiary)
                            .frame(width: 28, height: 28)
                            .background(isHoveringExpandButton ? Theme.bgHover : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.sm, style: .continuous))
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, Space.md)
                    .padding(.bottom, Space.lg)
                    .opacity(sidebarVisible ? 0 : 1)
                    .allowsHitTesting(!sidebarVisible)
                    .help("展开侧边栏")
                    .accessibilityLabel("展开侧边栏")
                    .trackHover($isHoveringExpandButton)
                }
                Spacer()
            }

            // MARK: - 左侧边缘悬停检测
            if !sidebarVisible {
                HStack {
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .frame(width: Space.sm)
                        .onHover { hovering in
                            guard hovering else { return }
                            withAnimation(.easeOut(duration: Motion.base)) {
                                sidebarVisible = true
                            }
                        }
                    Spacer()
                }
            }

            // MARK: - 快捷键
            Button(action: toggleSidebar) {
                EmptyView()
            }
            .keyboardShortcut("f", modifiers: [.command, .shift])
            .opacity(0)
            .frame(width: 0, height: 0)

            // MARK: - Editor 浮层
            if editorPresented, let projectID = editorProjectID {
                editorOverlay(projectID: projectID)
            }
        }
        .animation(.easeInOut(duration: Motion.base), value: sidebarVisible)
        .background(Theme.bgWindow)
        .onReceive(bus.events) { event in
            switch event {
            case let .presentTodoEditor(projectID, todoID):
                editorProjectID = projectID
                editorTodoID = todoID
                withAnimation(.easeOut(duration: Motion.base)) {
                    editorPresented = true
                }
            case .toggleTodoPanel:
                withAnimation(.easeInOut(duration: Motion.base)) {
                    todoVisible.toggle()
                }
            case .runCLI, .cliFinished:
                break
            }
        }
    }

    private func toggleSidebar() {
        sidebarVisible.toggle()
    }

    @ViewBuilder
    private var detailContent: some View {
        if let project = projectStore.projects.first(where: { $0.id == selectedProjectID }) {
            ProjectDetailView(
                todoStore: todoStore,
                cliRunner: cliRunner,
                bus: bus,
                project: project,
                todoVisible: $todoVisible
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

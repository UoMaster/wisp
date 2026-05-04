//
//  TodoPanel.swift
//  Wisp
//

import SwiftUI

struct TodoPanel: PanelKind {
    @ObservedObject var todoStore: TodoStore
    let cliRunner: CLIRunner
    let bus: PanelEventBus
    let project: Project

    var panelID: UUID { project.id }
    var panelTitle: String { "任务" }

    @State private var selectedTodoForRun: Todo?
    @State private var showingCLIChooser = false
    @State private var selectedTag: String? = nil
    @State private var pendingPlacement: RunPlacement = .focusedPanel

    private enum RunPlacement {
        case focusedPanel
        case newTab
        case splitHorizontal
        case splitVertical
    }

    private var todoList: [Todo] {
        let base = todoStore.todos(for: project.id)
        let sorted = base.sorted {
            if $0.priority.sortOrder != $1.priority.sortOrder {
                return $0.priority.sortOrder < $1.priority.sortOrder
            }
            return $0.createdAt < $1.createdAt
        }
        guard let tag = selectedTag else { return sorted }
        return sorted.filter { $0.tags.contains(tag) }
    }

    private var allTags: [String] {
        let tags = todoStore.todos(for: project.id).flatMap { $0.tags }
        return Array(Set(tags)).sorted()
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            if !allTags.isEmpty {
                TodoTagFilter(tags: allTags, selectedTag: $selectedTag)
            }
            content
        }
        .background(Theme.bgWindow)
        .confirmationDialog(
            "选择 CLI 工具",
            isPresented: $showingCLIChooser,
            titleVisibility: .visible
        ) {
            ForEach(CLIType.allCases) { cliType in
                Button(cliType.displayName) {
                    if let todo = selectedTodoForRun {
                        executeRun(todo: todo, cliType: cliType)
                    }
                    selectedTodoForRun = nil
                }
            }
            Button("取消", role: .cancel) { selectedTodoForRun = nil }
        } message: {
            if let todo = selectedTodoForRun {
                Text("「\(todo.title)」")
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: Space.sm) {
            Text("任务")
                .font(WispFont.panelTitle)
                .foregroundStyle(Theme.textPrimary)

            let count = todoStore.todos(for: project.id).count
            if count > 0 {
                Text("\(count)")
                    .font(WispFont.monoSmall)
                    .foregroundStyle(Theme.textTertiary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 1)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.xs, style: .continuous)
                            .fill(Theme.bgRaised)
                    )
            }

            Spacer()

            Button(action: { presentEditor(todoID: nil) }) {
                Image(systemName: "plus")
            }
            .buttonStyle(.wispIcon)
            .help("新建任务 (⌘N)")
            .keyboardShortcut("n", modifiers: .command)
        }
        .padding(.horizontal, Space.lg)
        .padding(.vertical, Space.md)
        .overlay(alignment: .bottom) { WispDivider() }
    }

    @ViewBuilder
    private var content: some View {
        if todoList.isEmpty {
            emptyState
        } else {
            TodoListView(
                todos: todoList,
                onTap: runTodo,
                onMove: moveTodos,
                onDelete: deleteTodos,
                contextMenu: { todo in AnyView(contextMenu(for: todo)) }
            )
        }
    }

    private var emptyState: some View {
        VStack(spacing: Space.sm) {
            Image(systemName: "checklist")
                .font(.system(size: 24, weight: .regular))
                .foregroundStyle(Theme.textTertiary)
            Text("还没有任务")
                .font(WispFont.bodyMedium)
                .foregroundStyle(Theme.textSecondary)
            Text("把常用 prompt 沉淀为可复用的任务")
                .font(WispFont.bodySmall)
                .foregroundStyle(Theme.textTertiary)
                .multilineTextAlignment(.center)
            Button("新建任务") { presentEditor(todoID: nil) }
                .buttonStyle(.wispGhost)
                .padding(.top, Space.xs)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Space.xl)
    }

    @ViewBuilder
    private func contextMenu(for todo: Todo) -> some View {
        Button("运行") { runTodo(todo) }
        Divider()
        Button("编辑") { presentEditor(todoID: todo.id) }
        if todo.status != .pending {
            Button("重置为待办") {
                todoStore.resetToPending(todoID: todo.id, in: project.id)
            }
        }
        Divider()
        Button("复制") { duplicateTodo(todo) }
        Divider()
        Button("删除", role: .destructive) {
            todoStore.remove(id: todo.id, from: project.id)
        }
    }

    // MARK: - Actions

    private func presentEditor(todoID: UUID?) {
        bus.send(.presentTodoEditor(projectID: project.id, todoID: todoID))
    }

    private func runTodo(_ todo: Todo) {
        guard todo.status != .running else { return }

        let flags = NSEvent.modifierFlags
        if flags.contains(.command) {
            pendingPlacement = .newTab
        } else if flags.contains(.option) {
            pendingPlacement = .splitHorizontal
        } else if flags.contains(.control) {
            pendingPlacement = .splitVertical
        } else {
            pendingPlacement = .focusedPanel
        }

        if let preferred = todo.preferredCLI {
            executeRun(todo: todo, cliType: preferred)
            return
        }
        selectedTodoForRun = todo
        showingCLIChooser = true
    }

    private func executeRun(todo: Todo, cliType: CLIType) {
        let preEvent: PanelEventBus.Event? = switch pendingPlacement {
        case .focusedPanel: nil
        case .newTab: .newTab(projectID: project.id)
        case .splitHorizontal: .splitCurrentTab(projectID: project.id, direction: .horizontal)
        case .splitVertical: .splitCurrentTab(projectID: project.id, direction: .vertical)
        }
        if let event = preEvent {
            bus.send(event)
        }
        cliRunner.run(todo: todo, cliType: cliType, in: project.id, targetPanelID: nil)
    }

    private func duplicateTodo(_ todo: Todo) {
        let copy = Todo(
            title: todo.title + " 副本",
            prompt: todo.prompt,
            preferredCLI: todo.preferredCLI,
            priority: todo.priority,
            tags: todo.tags,
            notes: todo.notes
        )
        todoStore.add(copy, to: project.id)
    }

    private func moveTodos(from source: IndexSet, to destination: Int) {
        guard selectedTag == nil else { return }
        var list = todoStore.todos(for: project.id)
        list.move(fromOffsets: source, toOffset: destination)
        todoStore.replace(list, for: project.id)
    }

    private func deleteTodos(at offsets: IndexSet) {
        let ids = offsets.compactMap { todoList.indices.contains($0) ? todoList[$0].id : nil }
        for id in ids {
            todoStore.remove(id: id, from: project.id)
        }
    }
}

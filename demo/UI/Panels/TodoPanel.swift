//
//  TodoPanel.swift
//  Wisp
//

import SwiftUI

struct TodoPanel: View {
    @ObservedObject var store: DataStore
    let project: Project

    @State private var selectedTodoForRun: Todo?
    @State private var showingCLIChooser = false

    @State private var selectedTag: String? = nil
    @State private var hoveredTodoID: UUID? = nil

    private var todoList: [Todo] {
        let base = store.todos(for: project.id)
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
        let tags = store.todos(for: project.id).flatMap { $0.tags }
        return Array(Set(tags)).sorted()
    }

    // MARK: - Body

    var body: some View {
        mainContent
        .confirmationDialog(
            "选择 CLI 工具",
            isPresented: $showingCLIChooser,
            titleVisibility: .visible
        ) {
            ForEach(CLIType.allCases) { cliType in
                Button(cliType.displayName) {
                    executeRun(cliType: cliType)
                }
            }
            Button("取消", role: .cancel) {}
        } message: {
            if let todo = selectedTodoForRun {
                Text("「\(todo.title)」")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .cliCommandFinished)) { notification in
            handleCommandFinished(notification: notification)
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        VStack(spacing: 0) {
            header
            tagFilterBar
            content
        }
        .background(Theme.bgSurface)
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: Space.sm) {
            Text("任务")
                .font(WispFont.panelTitle)
                .foregroundStyle(Theme.textPrimary)

            let count = store.todos(for: project.id).count
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

            Button(action: { presentEditor(mode: .create) }) {
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

    // MARK: - Tag Filter Bar

    @ViewBuilder
    private var tagFilterBar: some View {
        if !allTags.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Space.xs) {
                    SelectablePill(
                        isSelected: selectedTag == nil,
                        action: { selectedTag = nil }
                    ) {
                        Text("全部")
                            .font(WispFont.bodySmall)
                    }

                    ForEach(allTags, id: \.self) { tag in
                        SelectablePill(
                            isSelected: selectedTag == tag,
                            action: { selectedTag = (selectedTag == tag) ? nil : tag }
                        ) {
                            Text(tag)
                                .font(WispFont.bodySmall)
                        }
                    }
                }
                .padding(.horizontal, Space.lg)
                .padding(.vertical, Space.sm)
            }
            .overlay(alignment: .bottom) { WispDivider() }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if todoList.isEmpty {
            emptyState
        } else {
            todoListView
        }
    }

    private var todoListView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: Space.xs) {
                ForEach(todoList) { todo in
                    TodoRowEnhanced(
                        todo: todo,
                        isHovered: hoveredTodoID == todo.id
                    )
                    .onTapGesture { runTodo(todo) }
                    .onHover { isHovered in
                        hoveredTodoID = isHovered ? todo.id : nil
                    }
                    .contextMenu {
                        todoContextMenu(todo: todo)
                    }
                }
                .onMove(perform: moveTodos)
                .onDelete(perform: deleteTodos)
            }
            .padding(.horizontal, Space.sm)
            .padding(.vertical, Space.sm)
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
            Button("新建任务") { presentEditor(mode: .create) }
                .buttonStyle(.wispGhost)
                .padding(.top, Space.xs)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Space.xl)
    }

    // MARK: - Context Menu

    private func todoContextMenu(todo: Todo) -> some View {
        Group {
            Button("运行") { runTodo(todo) }

            Divider()

            Button("编辑") { presentEditor(mode: .edit(todo)) }

            if todo.status != .pending {
                Button("重置为待办") { resetTodo(todo) }
            }

            Divider()

            Button("复制") { duplicateTodo(todo) }

            Divider()

            Button("删除", role: .destructive) {
                store.removeTodo(id: todo.id, from: project.id)
            }
        }
    }

    // MARK: - Actions

    private func presentEditor(mode: TodoEditorDrawer.Mode) {
        NotificationCenter.default.post(
            name: .presentTodoEditor,
            object: nil,
            userInfo: [
                NotificationKey.projectID: project.id,
                NotificationKey.editorMode: mode
            ]
        )
    }

    private func runTodo(_ todo: Todo) {
        guard todo.status != .running else { return }

        // 如果设置了首选 CLI，直接运行
        if let preferred = todo.preferredCLI {
            executeRun(todo: todo, cliType: preferred)
            return
        }

        selectedTodoForRun = todo
        showingCLIChooser = true
    }

    private func executeRun(cliType: CLIType) {
        guard let todo = selectedTodoForRun else { return }
        selectedTodoForRun = nil
        executeRun(todo: todo, cliType: cliType)
    }

    private func executeRun(todo: Todo, cliType: CLIType) {
        // 生成 CLI 命令
        let command: String
        let promptInput: String?
        switch cliType {
        case .openCode:
            command = cliType.rawValue
            promptInput = todo.prompt.isEmpty ? nil : todo.prompt
        default:
            let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent("wisp")
            let promptFile = tmpDir.appendingPathComponent("\(todo.id.uuidString).prompt")
            do {
                try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
                try todo.prompt.write(to: promptFile, atomically: true, encoding: .utf8)
            } catch {
                print("Failed to write prompt file: \(error)")
                return
            }
            let adapter = cliType.adapter()
            command = adapter.shellCommand(promptFile: promptFile)
            promptInput = nil
        }

        guard !command.isEmpty else { return }

        // 更新 Todo 状态为 running
        var runningTodo = todo
        runningTodo.markRunning()
        store.updateTodo(runningTodo, in: project.id)

        // 发送通知让 TerminalPanel 执行
        var userInfo: [String: Any] = [
            NotificationKey.projectID: project.id,
            NotificationKey.command: command,
            NotificationKey.title: todo.title,
            NotificationKey.todoID: todo.id,
            NotificationKey.cliType: cliType.rawValue
        ]
        if let promptInput {
            userInfo[NotificationKey.promptInput] = promptInput
        }
        NotificationCenter.default.post(
            name: .runCLICommand,
            object: nil,
            userInfo: userInfo
        )
    }

    private func handleCommandFinished(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let projectID = userInfo[NotificationKey.projectID] as? UUID,
              projectID == project.id,
              let todoID = userInfo[NotificationKey.todoID] as? UUID else { return }

        guard var todo = store.todos(for: project.id).first(where: { $0.id == todoID }) else { return }

        let exitCode = userInfo[NotificationKey.exitCode] as? Int32 ?? -1
        let cliTypeRaw = userInfo[NotificationKey.cliType] as? String ?? "claude"
        let cliType = CLIType(rawValue: cliTypeRaw) ?? .claudeCode

        if exitCode == 0 {
            todo.markCompleted(exitCode: exitCode, cliType: cliType)
        } else {
            todo.markFailed(exitCode: exitCode, cliType: cliType)
        }
        store.updateTodo(todo, in: project.id)

        // 清理临时文件
        let promptFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("wisp")
            .appendingPathComponent("\(todoID.uuidString).prompt")
        try? FileManager.default.removeItem(at: promptFile)
    }

    private func resetTodo(_ todo: Todo) {
        var updated = todo
        updated.resetToPending()
        store.updateTodo(updated, in: project.id)
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
        store.addTodo(copy, to: project.id)
    }

    private func moveTodos(from source: IndexSet, to destination: Int) {
        // 注意：在过滤视图下不支持重排序
        guard selectedTag == nil else { return }
        var list = store.todos(for: project.id)
        list.move(fromOffsets: source, toOffset: destination)
        store.replaceTodos(list, for: project.id)
    }

    private func deleteTodos(at offsets: IndexSet) {
        let ids = offsets.compactMap { todoList.indices.contains($0) ? todoList[$0].id : nil }
        for id in ids {
            store.removeTodo(id: id, from: project.id)
        }
    }
}

// MARK: - Todo Row (Enhanced)

private struct TodoRowEnhanced: View {
    let todo: Todo
    let isHovered: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // 优先级指示条
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

                // Hover 时显示操作按钮
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
            .fill(todo.priority.color)
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


//
//  TodoPanel.swift
//  Wisp
//

import SwiftUI

struct TodoPanel: View {
    @ObservedObject var store: DataStore
    let project: Project

    @State private var showingAddSheet = false
    @State private var selectedTodoForRun: Todo?
    @State private var showingCLIChooser = false

    private var todoList: [Todo] {
        store.todos(for: project.id)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            content
        }
        .background(Theme.bgSurface)
        .sheet(isPresented: $showingAddSheet) {
            AddTodoSheet(store: store, projectID: project.id)
        }
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

    // MARK: - Header

    private var header: some View {
        HStack(spacing: Space.sm) {
            Text("任务")
                .font(WispFont.panelTitle)
                .foregroundStyle(Theme.textPrimary)

            if !todoList.isEmpty {
                Text("\(todoList.count)")
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

            Button(action: { showingAddSheet = true }) {
                Image(systemName: "plus")
            }
            .buttonStyle(.wispIcon)
            .help("新建任务")
        }
        .padding(.horizontal, Space.lg)
        .padding(.vertical, Space.md)
        .overlay(alignment: .bottom) { WispDivider() }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if todoList.isEmpty {
            emptyState
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: Space.xs) {
                    ForEach(todoList) { todo in
                        TodoRow(todo: todo) { runTodo(todo) }
                    }
                }
                .padding(.horizontal, Space.sm)
                .padding(.vertical, Space.sm)
            }
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
            Button("新建任务") { showingAddSheet = true }
                .buttonStyle(.wispGhost)
                .padding(.top, Space.xs)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Space.xl)
    }

    // MARK: - Actions

    private func runTodo(_ todo: Todo) {
        guard todo.status != .running else { return }
        selectedTodoForRun = todo
        showingCLIChooser = true
    }

    private func executeRun(cliType: CLIType) {
        guard let todo = selectedTodoForRun else { return }
        selectedTodoForRun = nil

        // 写入临时文件
        let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent("wisp")
        do {
            try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
            let promptFile = tmpDir.appendingPathComponent("\(todo.id.uuidString).prompt")
            try todo.prompt.write(to: promptFile, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to write prompt file: \(error)")
            return
        }

        // 生成 CLI 命令
        let command: String
        let promptInput: String?
        switch cliType {
        case .openCode:
            command = cliType.rawValue
            promptInput = todo.prompt.isEmpty ? nil : todo.prompt
        default:
            let promptFile = tmpDir.appendingPathComponent("\(todo.id.uuidString).prompt")
            let adapter = cliType.adapter()
            command = adapter.shellCommand(promptFile: promptFile)
            promptInput = nil
        }

        guard !command.isEmpty else { return }

        // 3. 更新 Todo 状态为 running
        var runningTodo = todo
        runningTodo.status = .running
        store.updateTodo(runningTodo, in: project.id)

        // 4. 发送通知让 TerminalPanel 执行
        var userInfo: [String: Any] = [
            NotificationKey.projectID: project.id,
            NotificationKey.command: command,
            NotificationKey.title: todo.title,
            NotificationKey.todoID: todo.id
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
        guard todo.status != .completed else { return }
        todo.status = .completed
        store.updateTodo(todo, in: project.id)

        // 清理临时文件
        let promptFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("wisp")
            .appendingPathComponent("\(todoID.uuidString).prompt")
        try? FileManager.default.removeItem(at: promptFile)
    }
}

// MARK: - Todo Row

private struct TodoRow: View {
    let todo: Todo
    let onRun: () -> Void

    @State private var isHovered = false

    var body: some View {
        HStack(alignment: .top, spacing: Space.sm) {
            StatusDot(status: todo.status)
                .padding(.top, 4)

            VStack(alignment: .leading, spacing: 2) {
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
            }

            Spacer(minLength: 0)

            if isHovered {
                Image(systemName: "play.fill")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(Theme.accent)
                    .padding(4)
                    .background(
                        Circle().fill(Theme.accentSoft)
                    )
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, Space.sm)
        .padding(.vertical, Space.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .wispRowBackground(isSelected: false, isHovered: isHovered)
        .contentShape(Rectangle())
        .onTapGesture { onRun() }
        .trackHover($isHovered)
    }

    private var textColor: Color {
        todo.status == .completed ? Theme.textSecondary : Theme.textPrimary
    }
}

// MARK: - Add Sheet

private struct AddTodoSheet: View {
    @ObservedObject var store: DataStore
    let projectID: UUID
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var prompt: String = ""
    @FocusState private var titleFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("新建任务")
                    .font(WispFont.panelTitle)
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
            }
            .padding(.horizontal, Space.lg)
            .padding(.top, Space.lg)
            .padding(.bottom, Space.md)

            WispDivider()

            // Body
            VStack(alignment: .leading, spacing: Space.md) {
                FieldLabel("标题")
                TextField("修复 login bug", text: $title)
                    .textFieldStyle(.plain)
                    .font(WispFont.body)
                    .padding(.horizontal, Space.md)
                    .padding(.vertical, Space.sm)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                            .fill(Theme.bgRaised)
                    )
                    .wispBordered(radius: Radius.sm)
                    .focused($titleFocused)

                FieldLabel("Prompt")
                TextEditor(text: $prompt)
                    .font(WispFont.mono)
                    .scrollContentBackground(.hidden)
                    .padding(Space.sm)
                    .frame(minHeight: 120)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                            .fill(Theme.bgRaised)
                    )
                    .wispBordered(radius: Radius.sm)
            }
            .padding(.horizontal, Space.lg)
            .padding(.vertical, Space.lg)

            WispDivider()

            // Footer
            HStack(spacing: Space.sm) {
                Spacer()
                Button("取消") { dismiss() }
                    .buttonStyle(.wispGhost)
                    .keyboardShortcut(.cancelAction)
                Button("创建") {
                    let todo = Todo(title: title, prompt: prompt)
                    store.addTodo(todo, to: projectID)
                    dismiss()
                }
                .buttonStyle(.wispPrimary)
                .keyboardShortcut(.defaultAction)
                .disabled(title.isEmpty)
            }
            .padding(.horizontal, Space.lg)
            .padding(.vertical, Space.md)
        }
        .frame(minWidth: 480, minHeight: 360)
        .background(Theme.bgOverlay)
        .onAppear { titleFocused = true }
    }
}

private struct FieldLabel: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .sectionTitleStyle()
    }
}

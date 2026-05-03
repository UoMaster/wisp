//
//  TodoPanel.swift
//  Wisp
//

import SwiftUI

struct TodoPanel: View {
    let project: Project

    @State private var todos: [Todo] = []
    @State private var showingAddSheet = false

    var body: some View {
        VStack(spacing: 0) {
            header
            content
        }
        .background(Theme.bgSurface)
        .sheet(isPresented: $showingAddSheet) {
            AddTodoSheet(todos: $todos)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: Space.sm) {
            Text("任务")
                .font(WispFont.panelTitle)
                .foregroundStyle(Theme.textPrimary)

            if !todos.isEmpty {
                Text("\(todos.count)")
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
        if todos.isEmpty {
            emptyState
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: Space.xs) {
                    ForEach(todos) { todo in
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
        // TODO: 弹 CLI 选择浮层 + 在终端面板里启动
        print("Run todo in \(project.name): \(todo.title)")
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
    @Binding var todos: [Todo]
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
                    todos.append(todo)
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

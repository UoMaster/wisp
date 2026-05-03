//
//  TodoEditorDrawer.swift
//  Wisp
//
//  底部抽屉式 Todo 编辑器 —— 新建/编辑任务。
//

import SwiftUI

struct TodoEditorDrawer: View {
    @ObservedObject var store: DataStore
    let projectID: UUID
    let mode: Mode

    @Binding var isPresented: Bool

    @State private var title: String = ""
    @State private var prompt: String = ""
    @State private var priority: TodoPriority = .none
    @State private var tags: [String] = []
    @State private var newTagText: String = ""
    @State private var preferredCLI: CLIType?
    @State private var notes: String = ""
    @State private var contentAppeared = false

    @FocusState private var titleFocused: Bool
    @FocusState private var tagFieldFocused: Bool

    enum Mode: Equatable {
        case create
        case edit(Todo)

        var navigationTitle: String {
            switch self {
            case .create: return "新建任务"
            case .edit:   return "编辑任务"
            }
        }

        var submitTitle: String {
            switch self {
            case .create: return "创建"
            case .edit:   return "保存"
            }
        }
    }

    private var editingTodo: Todo? {
        if case .edit(let todo) = mode { return todo }
        return nil
    }

    var body: some View {
        VStack(spacing: 0) {
            dragHandle
            ScrollView {
                VStack(alignment: .leading, spacing: Space.lg) {
                    headerSection
                        .staggerAppear(index: 0, appeared: contentAppeared)
                    titleSection
                        .staggerAppear(index: 1, appeared: contentAppeared)
                    promptSection
                        .staggerAppear(index: 2, appeared: contentAppeared)
                    prioritySection
                        .staggerAppear(index: 3, appeared: contentAppeared)
                    tagsSection
                        .staggerAppear(index: 4, appeared: contentAppeared)
                    cliSection
                        .staggerAppear(index: 5, appeared: contentAppeared)
                    notesSection
                        .staggerAppear(index: 6, appeared: contentAppeared)

                    if let todo = editingTodo, !todo.runHistory.isEmpty {
                        historySection(todo: todo)
                            .staggerAppear(index: 7, appeared: contentAppeared)
                    }

                    Spacer(minLength: Space.xl)
                }
                .padding(.horizontal, Space.xl)
                .padding(.vertical, Space.lg)
            }

            footer
                .staggerAppear(index: 8, appeared: contentAppeared)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.bgOverlay)
        .onAppear {
            loadExistingData()
            withAnimation(.easeOut(duration: Motion.slow).delay(0.05)) {
                contentAppeared = true
            }
        }
        .onDisappear {
            contentAppeared = false
        }
    }

    // MARK: - Sections

    private var dragHandle: some View {
        HStack {
            Spacer()
            RoundedRectangle(cornerRadius: 2)
                .fill(Theme.borderDefault)
                .frame(width: 36, height: 4)
            Spacer()
        }
        .padding(.top, Space.sm)
        .padding(.bottom, Space.xs)
    }

    private var headerSection: some View {
        HStack {
            Text(mode.navigationTitle)
                .font(WispFont.sectionTitle)
                .foregroundStyle(Theme.textPrimary)
            Spacer()
            Button(action: { isPresented = false }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .medium))
            }
            .buttonStyle(.wispIcon)
        }
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: Space.xs) {
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
        }
    }

    private var promptSection: some View {
        FormTextEditor(label: "Prompt", text: $prompt, font: WispFont.mono, minHeight: 200)
    }

    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: Space.xs) {
            FieldLabel("优先级")
            HStack(spacing: Space.xs) {
                ForEach(TodoPriority.allCases, id: \.self) { p in
                    PriorityPill(
                        priority: p,
                        isSelected: priority == p
                    ) {
                        withAnimation(.easeOut(duration: Motion.fast)) {
                            priority = p
                        }
                    }
                }
            }
        }
    }

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: Space.xs) {
            FieldLabel("标签")

            FlowLayout(spacing: Space.xs) {
                ForEach(tags, id: \.self) { tag in
                    TagPill(text: tag) {
                        withAnimation {
                            tags.removeAll { $0 == tag }
                        }
                    }
                }
            }

            HStack(spacing: Space.sm) {
                TextField("添加标签…", text: $newTagText)
                    .textFieldStyle(.plain)
                    .font(WispFont.bodySmall)
                    .padding(.horizontal, Space.md)
                    .padding(.vertical, Space.sm)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                            .fill(Theme.bgRaised)
                    )
                    .wispBordered(radius: Radius.sm)
                    .focused($tagFieldFocused)
                    .onSubmit(addTag)

                Button(action: addTag) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .semibold))
                }
                .buttonStyle(.wispIcon)
                .disabled(newTagText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    private var cliSection: some View {
        VStack(alignment: .leading, spacing: Space.xs) {
            FieldLabel("首选 CLI")
            HStack(spacing: Space.xs) {
                CLIOptionButton(
                    title: "自动",
                    isSelected: preferredCLI == nil
                ) {
                    preferredCLI = nil
                }

                ForEach(CLIType.allCases) { cli in
                    CLIOptionButton(
                        title: cli.displayName,
                        isSelected: preferredCLI == cli
                    ) {
                        preferredCLI = cli
                    }
                }
            }
        }
    }

    private var notesSection: some View {
        FormTextEditor(label: "备注", text: $notes, font: WispFont.bodySmall, minHeight: 80)
    }

    private func historySection(todo: Todo) -> some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            FieldLabel("运行历史 (\(todo.runCount) 次)")
            VStack(spacing: 0) {
                ForEach(Array(todo.runHistory.enumerated().reversed()), id: \.element.id) { index, record in
                    RunHistoryRow(record: record, index: todo.runHistory.count - index)
                    if index < todo.runHistory.count - 1 {
                        WispDivider().padding(.leading, Space.lg)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                    .fill(Theme.bgRaised)
            )
            .wispBordered(radius: Radius.sm)
        }
    }

    private var footer: some View {
        HStack(spacing: Space.sm) {
            Spacer()
            Button("取消") { isPresented = false }
                .buttonStyle(.wispGhost)
            Button(mode.submitTitle) { submit() }
                .buttonStyle(.wispPrimary)
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                .keyboardShortcut(.defaultAction)
        }
        .padding(.horizontal, Space.xl)
        .padding(.vertical, Space.md)
        .overlay(alignment: .top) { WispDivider() }
    }

    // MARK: - Actions

    private func loadExistingData() {
        if let todo = editingTodo {
            title = todo.title
            prompt = todo.prompt
            priority = todo.priority
            tags = todo.tags
            preferredCLI = todo.preferredCLI
            notes = todo.notes
        }
        titleFocused = true
    }

    private func addTag() {
        let trimmed = newTagText.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
        guard !trimmed.isEmpty, !tags.contains(trimmed) else { return }
        withAnimation {
            tags.append(trimmed)
        }
        newTagText = ""
        tagFieldFocused = true
    }

    private func submit() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        switch mode {
        case .create:
            let todo = Todo(
                title: trimmedTitle,
                prompt: prompt,
                preferredCLI: preferredCLI,
                priority: priority,
                tags: tags,
                notes: notes
            )
            store.addTodo(todo, to: projectID)

        case .edit(var todo):
            todo.title = trimmedTitle
            todo.prompt = prompt
            todo.priority = priority
            todo.tags = tags
            todo.preferredCLI = preferredCLI
            todo.notes = notes
            todo.updatedAt = Date()
            store.updateTodo(todo, in: projectID)
        }

        isPresented = false
    }
}

// MARK: - Subviews

struct SelectablePill<Content: View>: View {
    let isSelected: Bool
    let action: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        Button(action: action) {
            content
                .padding(.horizontal, Space.md)
                .padding(.vertical, Space.sm)
                .background(
                    RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                        .fill(isSelected ? Theme.accentSoft : Theme.bgRaised)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                        .stroke(isSelected ? Theme.accent : Theme.borderDefault, lineWidth: Stroke.hairline)
                )
                .foregroundStyle(isSelected ? Theme.accent : Theme.textSecondary)
        }
        .buttonStyle(.plain)
    }
}

private struct PriorityPill: View {
    let priority: TodoPriority
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        SelectablePill(isSelected: isSelected, action: action) {
            HStack(spacing: 4) {
                Circle()
                    .fill(priority.color)
                    .frame(width: 6, height: 6)
                Text(priority.displayName)
                    .font(WispFont.bodySmall)
            }
        }
    }
}

private struct CLIOptionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        SelectablePill(isSelected: isSelected, action: action) {
            Text(title)
                .font(WispFont.bodySmall)
        }
    }
}

private struct FormTextEditor: View {
    let label: String
    @Binding var text: String
    let font: Font
    let minHeight: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: Space.xs) {
            FieldLabel(label)
            TextEditor(text: $text)
                .font(font)
                .scrollContentBackground(.hidden)
                .padding(Space.sm)
                .frame(minHeight: minHeight)
                .background(
                    RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                        .fill(Theme.bgRaised)
                )
                .wispBordered(radius: Radius.sm)
        }
    }
}

private struct TagPill: View {
    let text: String
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 2) {
            Text(text)
                .font(WispFont.monoSmall)
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 8, weight: .bold))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(
            RoundedRectangle(cornerRadius: Radius.xs, style: .continuous)
                .fill(Theme.accentSoft)
        )
        .foregroundStyle(Theme.accent)
    }
}

private struct RunHistoryRow: View {
    let record: RunRecord
    let index: Int

    var body: some View {
        HStack(spacing: Space.sm) {
            Text("#\(index)")
                .font(WispFont.monoSmall)
                .foregroundStyle(Theme.textTertiary)
                .frame(width: 28, alignment: .leading)

            Image(systemName: record.isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 10))
                .foregroundStyle(record.isSuccess ? Theme.statusSuccess : Theme.statusDanger)

            Text(record.cliType.displayName)
                .font(WispFont.bodySmall)
                .foregroundStyle(Theme.textSecondary)

            Spacer()

            Text(formatDuration(record.duration))
                .font(WispFont.monoSmall)
                .foregroundStyle(Theme.textTertiary)

            Text(record.endedAt, style: .date)
                .font(WispFont.monoSmall)
                .foregroundStyle(Theme.textTertiary)
        }
        .padding(.horizontal, Space.md)
        .padding(.vertical, Space.sm)
    }

    private func formatDuration(_ interval: TimeInterval) -> String {
        let mins = Int(interval) / 60
        let secs = Int(interval) % 60
        if mins > 0 {
            return "\(mins)m \(secs)s"
        }
        return "\(secs)s"
    }
}

// MARK: - Flow Layout

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func makeCache(subviews: Subviews) -> FlowResult {
        FlowResult(in: 0, subviews: subviews, spacing: spacing)
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout FlowResult) -> CGSize {
        cache = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return cache.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout FlowResult) {
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + cache.positions[index].x,
                                       y: bounds.minY + cache.positions[index].y),
                          proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > maxWidth, x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
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

// MARK: - Stagger Animation

private extension View {
    func staggerAppear(index: Int, appeared: Bool) -> some View {
        self
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
            .animation(
                .easeOut(duration: Motion.slow)
                .delay(Double(index) * 0.04),
                value: appeared
            )
    }
}

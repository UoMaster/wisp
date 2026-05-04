//
//  TerminalWorkspace.swift
//  Wisp
//
//  右侧 Terminal 大容器：TabBar + Toolbar + 可分割的 ContentArea。
//

import SwiftUI

struct TerminalWorkspace: View {
    let project: Project
    let bus: PanelEventBus
    let todoVisible: Bool
    let onToggleTodo: () -> Void

    @State private var tabs: [TerminalTab] = []
    @State private var selectedTabID: UUID? = nil
    @State private var editingTabID: UUID? = nil

    private var selectedTabIndex: Int? {
        tabs.firstIndex(where: { $0.id == selectedTabID })
    }

    var body: some View {
        VStack(spacing: 0) {
            workspaceHeader
            WispDivider()
            contentArea
        }
        .background(Theme.bgWindow)
        .onAppear {
            ensureInitialTab()
        }
        .onReceive(bus.events) { event in
            handle(event: event)
        }
    }

    // MARK: - Header

    private var workspaceHeader: some View {
        HStack(spacing: 0) {
            // TabBar
            HStack(spacing: Space.xs) {
                ForEach(tabs) { tab in
                    tabButton(for: tab)
                }

                Button(action: newTab) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                        .frame(width: 22, height: 22)
                        .background(Theme.bgHover)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.xs, style: .continuous))
                }
                .buttonStyle(.plain)
                .help("新建标签页 (⌘T)")
            }

            Spacer()

            // Toolbar
            HStack(spacing: Space.xs) {
                Button(action: splitHorizontal) {
                    Image(systemName: "square.split.2x1")
                        .font(.system(size: 11, weight: .medium))
                }
                .buttonStyle(.wispIcon)
                .help("水平分割")

                Button(action: splitVertical) {
                    Image(systemName: "square.split.1x2")
                        .font(.system(size: 11, weight: .medium))
                }
                .buttonStyle(.wispIcon)
                .help("垂直分割")

                Divider()
                    .frame(height: 14)

                Button(action: onToggleTodo) {
                    Image(systemName: todoVisible ? "checklist" : "checklist")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(todoVisible ? Theme.accent : Theme.textSecondary)
                }
                .buttonStyle(.wispIcon)
                .help(todoVisible ? "隐藏任务列表" : "显示任务列表")

                Button(action: closeFocusedPanel) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .medium))
                }
                .buttonStyle(.wispIcon)
                .help("关闭当前终端 (⌘W)")
            }
        }
        .padding(.horizontal, Space.sm)
        .padding(.vertical, 4)
        .frame(height: 28)
    }

    private func tabButton(for tab: TerminalTab) -> some View {
        let isSelected = tab.id == selectedTabID
        let isEditing = editingTabID == tab.id
        let editingBinding = Binding<Bool>(
            get: { editingTabID == tab.id },
            set: { if !$0 { editingTabID = nil } }
        )
        return Button(action: {
            if !isEditing {
                selectedTabID = tab.id
            }
        }) {
            HStack(spacing: Space.xs) {
                if isEditing {
                    InlineRenameField(
                        initialText: tab.title,
                        isEditing: editingBinding,
                        font: WispFont.caption,
                        width: 80,
                        onCommit: { newTitle in
                            renameTab(id: tab.id, title: newTitle)
                        }
                    )
                } else {
                    Text(tab.title)
                        .font(WispFont.caption)
                        .foregroundStyle(isSelected ? Theme.textPrimary : Theme.textSecondary)
                        .lineLimit(1)
                }

                if tabs.count > 1, !isEditing {
                    Button(action: {
                        closeTab(id: tab.id)
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundStyle(isSelected ? Theme.textSecondary : Theme.textTertiary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Space.sm)
            .padding(.vertical, 4)
            .background(isSelected ? Theme.bgRaised : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: Radius.xs, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.xs, style: .continuous)
                    .stroke(isSelected ? Theme.borderDefault : Color.clear, lineWidth: Stroke.hairline)
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("重命名") {
                editingTabID = tab.id
            }
            if tabs.count > 1 {
                Button("关闭") {
                    closeTab(id: tab.id)
                }
            }
        }
    }

    private func renameTab(id: UUID, title: String) {
        guard let index = tabs.firstIndex(where: { $0.id == id }) else { return }
        guard tabs[index].title != title else { return }
        tabs[index].title = title
    }

    // MARK: - Content Area

    @ViewBuilder
    private var contentArea: some View {
        ZStack {
            ForEach(tabs) { tab in
                TerminalArea(
                    project: project,
                    bus: bus,
                    root: tab.root,
                    focusedPanelID: tab.focusedPanelID,
                    zoomedPanelID: tab.zoomedPanelID
                )
                .opacity(tab.id == selectedTabID ? 1 : 0)
                .allowsHitTesting(tab.id == selectedTabID)
            }
        }
    }

    // MARK: - Tab Lifecycle

    private func ensureInitialTab() {
        guard tabs.isEmpty else { return }
        let panel = PanelInstance(id: UUID(), title: project.name, associatedTodoID: nil)
        let tab = TerminalTab(
            id: UUID(),
            title: project.name,
            root: .panel(panel),
            focusedPanelID: panel.id
        )
        tabs = [tab]
        selectedTabID = tab.id
    }

    private func newTab() {
        let panel = PanelInstance(id: UUID(), title: project.name, associatedTodoID: nil)
        let tab = TerminalTab(
            id: UUID(),
            title: project.name,
            root: .panel(panel),
            focusedPanelID: panel.id
        )
        tabs.append(tab)
        selectedTabID = tab.id
    }

    private func closeTab(id: UUID) {
        guard let idx = tabs.firstIndex(where: { $0.id == id }) else { return }

        for panelID in tabs[idx].root.allPanelIDs {
            bus.send(.panelWillClose(projectID: project.id, panelID: panelID))
        }

        guard tabs.count > 1 else {
            let panel = PanelInstance(id: UUID(), title: project.name, associatedTodoID: nil)
            tabs[idx] = TerminalTab(
                id: UUID(),
                title: project.name,
                root: .panel(panel),
                focusedPanelID: panel.id
            )
            selectedTabID = tabs[idx].id
            return
        }

        tabs.removeAll { $0.id == id }
        if selectedTabID == id {
            selectedTabID = tabs.last?.id
        }
    }

    private func cycleTab(step: Int) {
        guard tabs.count > 1, let currentIndex = selectedTabIndex else { return }
        let nextIndex = (currentIndex + step + tabs.count) % tabs.count
        let newID = tabs[nextIndex].id
        guard selectedTabID != newID else { return }
        selectedTabID = newID
    }

    // MARK: - Panel Lifecycle (nested split)

    private func splitHorizontal() {
        splitCurrentTab(direction: .horizontal)
    }

    private func splitVertical() {
        splitCurrentTab(direction: .vertical)
    }

    private func splitCurrentTab(direction: SplitDirection) {
        guard let index = selectedTabIndex else { return }
        guard let focusedID = tabs[index].focusedPanelID else { return }
        guard let path = tabs[index].root.path(to: focusedID) else { return }

        guard case .panel(let oldPanel) = tabs[index].root.node(at: path) else { return }

        let newPanel = PanelInstance(id: UUID(), title: project.name, associatedTodoID: nil)
        let splitNode = LayoutNode.split(
            id: UUID(),
            direction: direction,
            children: [.panel(oldPanel), .panel(newPanel)]
        )

        tabs[index].root = tabs[index].root.replacing(at: path, with: splitNode)
        tabs[index].focusedPanelID = newPanel.id
    }

    private func closeFocusedPanel() {
        guard let index = selectedTabIndex,
              let focusedID = tabs[index].focusedPanelID else { return }
        closePanel(at: index, panelID: focusedID)
    }

    private func closePanel(panelID: UUID) {
        guard let tabIndex = tabs.firstIndex(where: { $0.root.contains(panelID: panelID) }) else { return }
        closePanel(at: tabIndex, panelID: panelID)
    }

    private func closePanel(at tabIndex: Int, panelID: UUID) {
        if case .panel = tabs[tabIndex].root {
            if tabs.count == 1 {
                if let oldID = tabs[tabIndex].root.firstPanelID {
                    bus.send(.panelWillClose(projectID: project.id, panelID: oldID))
                }
                let panel = PanelInstance(id: UUID(), title: project.name, associatedTodoID: nil)
                tabs[tabIndex].root = .panel(panel)
                tabs[tabIndex].focusedPanelID = panel.id
            } else {
                closeTab(id: tabs[tabIndex].id)
            }
            return
        }

        guard let path = tabs[tabIndex].root.path(to: panelID) else { return }

        bus.send(.panelWillClose(projectID: project.id, panelID: panelID))
        tabs[tabIndex].root = tabs[tabIndex].root.removingPanel(at: path)

        if tabs[tabIndex].focusedPanelID == panelID {
            tabs[tabIndex].focusedPanelID = tabs[tabIndex].root.firstPanelID
        }
    }

    // MARK: - Event Handling

    private func handle(event: PanelEventBus.Event) {
        switch event {
        case let .newTab(pid):
            guard pid == project.id else { return }
            newTab()

        case let .splitCurrentTab(pid, direction):
            guard pid == project.id else { return }
            splitCurrentTab(direction: direction)

        case let .closeCurrentTab(pid):
            guard pid == project.id else { return }
            closeTab(id: selectedTabID ?? UUID())

        case let .closeFocusedPanel(pid):
            guard pid == project.id else { return }
            closeFocusedPanel()

        case let .closePanel(pid, panelID):
            guard pid == project.id else { return }
            closePanel(panelID: panelID)

        case let .selectTab(pid, tabID):
            guard pid == project.id else { return }
            guard selectedTabID != tabID else { return }
            selectedTabID = tabID

        case let .focusPanel(pid, panelID):
            guard pid == project.id else { return }
            if let index = selectedTabIndex,
               tabs[index].root.contains(panelID: panelID),
               tabs[index].focusedPanelID != panelID {
                tabs[index].focusedPanelID = panelID
            }

        case let .runCLI(pid, _, _, _, _, _, targetPanelID):
            guard pid == project.id else { return }
            if targetPanelID != nil {
                break
            }
            if let index = selectedTabIndex {
                if tabs[index].root.firstPanelID == nil {
                    let panel = PanelInstance(id: UUID(), title: project.name, associatedTodoID: nil)
                    tabs[index].root = .panel(panel)
                    tabs[index].focusedPanelID = panel.id
                }
                if tabs[index].focusedPanelID == nil {
                    tabs[index].focusedPanelID = tabs[index].root.firstPanelID
                }
            }

        case let .focusNeighbor(pid, direction):
            guard pid == project.id else { return }
            guard let index = selectedTabIndex,
                  let focusedID = tabs[index].focusedPanelID else { return }
            if let neighborID = tabs[index].root.neighborPanelID(from: focusedID, direction: direction) {
                bus.send(.focusPanel(projectID: project.id, panelID: neighborID))
            }

        case let .nextTab(pid):
            guard pid == project.id else { return }
            cycleTab(step: 1)

        case let .previousTab(pid):
            guard pid == project.id else { return }
            cycleTab(step: -1)

        case let .selectTabByIndex(pid, index):
            guard pid == project.id else { return }
            let zeroBased = index - 1
            guard tabs.indices.contains(zeroBased) else { return }
            let newID = tabs[zeroBased].id
            guard selectedTabID != newID else { return }
            selectedTabID = newID

        case let .toggleZoom(pid):
            guard pid == project.id else { return }
            guard let index = selectedTabIndex,
                  let focusedID = tabs[index].focusedPanelID else { return }
            tabs[index].zoomedPanelID = (tabs[index].zoomedPanelID == focusedID) ? nil : focusedID

        default:
            break
        }
    }
}

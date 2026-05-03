//
//  ProjectSidebar.swift
//  Wisp
//

import SwiftUI

struct ProjectSidebar: View {
    @ObservedObject var store: DataStore
    @Binding var selectedProjectID: UUID?

    var body: some View {
        VStack(spacing: 0) {
            header
            list
            footer
        }
        .background(Theme.bgSurface)
        .toolbar(removing: .sidebarToggle)
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: Space.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Theme.accentSoft)
                    .frame(width: 24, height: 24)
                Image(systemName: "sparkles")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Theme.accent)
            }

            Text("Wisp")
                .font(WispFont.panelTitle)
                .foregroundStyle(Theme.textPrimary)

            Spacer()
        }
        .padding(.horizontal, Space.md)
        .padding(.top, Space.lg)
        .padding(.bottom, Space.md)
    }

    // MARK: - List

    private var list: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.xs) {
                Text("项目")
                    .sectionTitleStyle()
                    .padding(.horizontal, Space.md)
                    .padding(.top, Space.xs)
                    .padding(.bottom, Space.xs)

                if store.projects.isEmpty {
                    emptyHint
                } else {
                    ForEach(store.projects) { project in
                        ProjectRow(
                            project: project,
                            isSelected: selectedProjectID == project.id
                        )
                        .onTapGesture { selectedProjectID = project.id }
                        .contextMenu {
                            Button("从列表移除", role: .destructive) {
                                store.removeProject(id: project.id)
                                if selectedProjectID == project.id {
                                    selectedProjectID = store.projects.first?.id
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, Space.sm)
            .padding(.bottom, Space.md)
        }
    }

    private var emptyHint: some View {
        Text("还没有项目")
            .font(WispFont.bodySmall)
            .foregroundStyle(Theme.textTertiary)
            .padding(.horizontal, Space.md)
            .padding(.vertical, Space.sm)
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 0) {
            WispDivider()
            HStack {
                Button(action: addProject) {
                    HStack(spacing: Space.xs) {
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .semibold))
                        Text("添加项目")
                    }
                }
                .buttonStyle(.wispGhost)
                Spacer()
            }
            .padding(Space.md)
        }
    }

    // MARK: - Actions

    private func addProject() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "选择"
        panel.message = "选择一个文件夹作为项目"

        if panel.runModal() == .OK, let url = panel.url {
            let newProject = Project(path: url.path)
            store.addProject(newProject)
            selectedProjectID = newProject.id
        }
    }
}

// MARK: - Project Row

private struct ProjectRow: View {
    let project: Project
    let isSelected: Bool
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: Space.sm) {
            Image(systemName: "folder.fill")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(isSelected ? Theme.accent : Theme.textTertiary)
                .frame(width: 16)

            VStack(alignment: .leading, spacing: 1) {
                Text(project.name)
                    .font(WispFont.bodyMedium)
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)

                Text(project.displayPath)
                    .font(WispFont.monoSmall)
                    .foregroundStyle(Theme.textTertiary)
                    .lineLimit(1)
                    .truncationMode(.head)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, Space.sm)
        .padding(.vertical, Space.xs)
        .frame(maxWidth: .infinity, alignment: .leading)
        .wispRowBackground(isSelected: isSelected, isHovered: isHovered)
        .contentShape(Rectangle())
        .trackHover($isHovered)
    }
}

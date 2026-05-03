//
//  ProjectSidebar.swift
//  Wisp
//

import SwiftUI

struct ProjectSidebar: View {
    @Binding var projects: [Project]
    @Binding var selectedProjectID: UUID?

    var body: some View {
        List(selection: $selectedProjectID) {
            ForEach(projects) { project in
                Label(project.name, systemImage: "folder")
                    .tag(project.id)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: addProject) {
                Label("添加项目", systemImage: "plus")
            }
            .padding()
            .buttonStyle(.borderedProminent)
        }
    }

    private func addProject() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "选择"
        panel.message = "选择一个文件夹作为项目"

        if panel.runModal() == .OK, let url = panel.url {
            let newProject = Project(path: url.path)
            projects.append(newProject)
            selectedProjectID = newProject.id
        }
    }
}

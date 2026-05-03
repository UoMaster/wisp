//
//  MainWindow.swift
//  Wisp
//

import SwiftUI

struct MainWindow: View {
    @State private var projects: [Project] = []
    @State private var selectedProjectID: UUID?

    var body: some View {
        NavigationSplitView {
            ProjectSidebar(projects: $projects, selectedProjectID: $selectedProjectID)
                .frame(minWidth: 200, idealWidth: 250)
        } detail: {
            if let projectID = selectedProjectID {
                ProjectDetailView(projectID: projectID)
            } else {
                ContentUnavailableView("选择一个项目", systemImage: "folder")
            }
        }
        .navigationTitle("Wisp")
    }
}

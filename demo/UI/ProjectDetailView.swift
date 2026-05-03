//
//  ProjectDetailView.swift
//  Wisp
//

import SwiftUI

struct ProjectDetailView: View {
    @ObservedObject var todoStore: TodoStore
    let cliRunner: CLIRunner
    let bus: PanelEventBus
    let project: Project

    var body: some View {
        HStack(spacing: 0) {
            TodoPanel(
                todoStore: todoStore,
                cliRunner: cliRunner,
                bus: bus,
                project: project
            )
            .frame(minWidth: 280, idealWidth: 320, maxWidth: 380)

            WispDivider(axis: .vertical)

            TerminalPanel(project: project, bus: bus)
                .frame(minWidth: 480)
        }
        .background(Theme.bgWindow)
    }
}

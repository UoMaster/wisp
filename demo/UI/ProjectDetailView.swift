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
    @Binding var todoVisible: Bool

    var body: some View {
        HStack(spacing: 0) {
            TodoPanel(
                todoStore: todoStore,
                cliRunner: cliRunner,
                bus: bus,
                project: project
            )
            .frame(minWidth: 280, idealWidth: 320, maxWidth: 380)
            .opacity(todoVisible ? 1 : 0)
            .frame(width: todoVisible ? nil : 0, alignment: .leading)
            .clipped()

            WispDivider(axis: .vertical)
                .opacity(todoVisible ? 1 : 0)
                .frame(width: todoVisible ? Stroke.hairline : 0)

            TerminalWorkspace(
                project: project,
                bus: bus,
                todoVisible: todoVisible,
                onToggleTodo: { bus.send(.toggleTodoPanel) }
            )
            .frame(minWidth: 480)
        }
        .background(Theme.bgWindow)
    }
}

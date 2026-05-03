//
//  ProjectDetailView.swift
//  Wisp
//

import SwiftUI

struct ProjectDetailView: View {
    @ObservedObject var store: DataStore
    let project: Project

    var body: some View {
        HStack(spacing: 0) {
            TodoPanel(store: store, project: project)
                .frame(minWidth: 280, idealWidth: 320, maxWidth: 380)

            WispDivider(axis: .vertical)

            TerminalPanel()
                .frame(minWidth: 480)
        }
        .background(Theme.bgWindow)
    }
}

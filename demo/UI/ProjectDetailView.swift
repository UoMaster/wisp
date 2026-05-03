//
//  ProjectDetailView.swift
//  Wisp
//

import SwiftUI

struct ProjectDetailView: View {
    let projectID: UUID

    var body: some View {
        HStack(spacing: 0) {
            TodoPanel()
                .frame(minWidth: 250, idealWidth: 300)

            Divider()

            TerminalPanel()
                .frame(minWidth: 400)
        }
    }
}

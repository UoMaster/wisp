//
//  TerminalSession.swift
//  Wisp
//

import Foundation

struct TerminalSession: Identifiable {
    let id: UUID
    let projectID: UUID
    let todoID: UUID?
    let cliType: CLIType
    let promptFile: URL
    let startedAt: Date
    var status: SessionStatus
    var exitCode: Int32?
    var exitedAt: Date?

    init(projectID: UUID, todoID: UUID? = nil, cliType: CLIType, promptFile: URL) {
        self.id = UUID()
        self.projectID = projectID
        self.todoID = todoID
        self.cliType = cliType
        self.promptFile = promptFile
        self.startedAt = Date()
        self.status = .running
    }
}

enum SessionStatus: Equatable {
    case running
    case exited(code: Int32)
    case failed(error: String)
}

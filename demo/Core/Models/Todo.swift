//
//  Todo.swift
//  Wisp
//

import Foundation

struct Todo: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var prompt: String
    var status: TodoStatus
    var preferredCLI: CLIType?
    var createdAt: Date
    var updatedAt: Date

    init(title: String, prompt: String, preferredCLI: CLIType? = nil) {
        self.id = UUID()
        self.title = title
        self.prompt = prompt
        self.status = .pending
        self.preferredCLI = preferredCLI
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum TodoStatus: String, Codable, Equatable {
    case pending
    case running
    case completed
}

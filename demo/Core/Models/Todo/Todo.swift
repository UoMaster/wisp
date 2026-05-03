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
    var priority: TodoPriority
    var tags: [String]
    var notes: String
    var runHistory: [RunRecord]
    var createdAt: Date
    var updatedAt: Date

    init(
        title: String,
        prompt: String,
        preferredCLI: CLIType? = nil,
        priority: TodoPriority = .none,
        tags: [String] = [],
        notes: String = ""
    ) {
        self.id = UUID()
        self.title = title
        self.prompt = prompt
        self.status = .pending
        self.preferredCLI = preferredCLI
        self.priority = priority
        self.tags = tags
        self.notes = notes
        self.runHistory = []
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed

    var runCount: Int { runHistory.count }

    var lastRunAt: Date? { runHistory.last?.startedAt }

    var completedAt: Date? {
        guard status == .completed else { return nil }
        return runHistory.last(where: { $0.exitCode == 0 })?.endedAt
    }

    var isFailed: Bool { status == .failed }

    // MARK: - Mutations

    mutating func markRunning() {
        status = .running
        updatedAt = Date()
    }

    mutating func markCompleted(exitCode: Int32, cliType: CLIType) {
        status = .completed
        appendRunRecord(exitCode: exitCode, cliType: cliType)
        updatedAt = Date()
    }

    mutating func markFailed(exitCode: Int32, cliType: CLIType) {
        status = .failed
        appendRunRecord(exitCode: exitCode, cliType: cliType)
        updatedAt = Date()
    }

    mutating func resetToPending() {
        status = .pending
        updatedAt = Date()
    }

    private mutating func appendRunRecord(exitCode: Int32, cliType: CLIType) {
        let record = RunRecord(
            cliType: cliType,
            startedAt: updatedAt,
            endedAt: Date(),
            exitCode: exitCode
        )
        runHistory.append(record)
    }
}

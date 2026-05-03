//
//  Todo.swift
//  Wisp
//

import Foundation
import SwiftUI

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

// MARK: - Status

enum TodoStatus: String, Codable, Equatable {
    case pending
    case running
    case completed
    case failed
}

// MARK: - Priority

enum TodoPriority: String, Codable, CaseIterable, Equatable {
    case none = "none"
    case low = "low"
    case medium = "medium"
    case high = "high"

    var displayName: String {
        switch self {
        case .none:   return "无"
        case .low:    return "低"
        case .medium: return "中"
        case .high:   return "高"
        }
    }

    var color: Color {
        switch self {
        case .none:   return Theme.textTertiary
        case .low:    return Color(red: 0.35, green: 0.55, blue: 0.95)
        case .medium: return Color(red: 0.95, green: 0.60, blue: 0.25)
        case .high:   return Color(red: 0.95, green: 0.35, blue: 0.35)
        }
    }

    var sortOrder: Int {
        switch self {
        case .high:   return 0
        case .medium: return 1
        case .low:    return 2
        case .none:   return 3
        }
    }
}

// MARK: - Run Record

struct RunRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let cliType: CLIType
    let startedAt: Date
    let endedAt: Date
    let exitCode: Int32

    init(cliType: CLIType, startedAt: Date, endedAt: Date, exitCode: Int32) {
        self.id = UUID()
        self.cliType = cliType
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.exitCode = exitCode
    }

    var duration: TimeInterval {
        endedAt.timeIntervalSince(startedAt)
    }

    var isSuccess: Bool {
        exitCode == 0
    }
}

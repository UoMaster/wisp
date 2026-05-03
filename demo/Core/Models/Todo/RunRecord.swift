//
//  RunRecord.swift
//  Wisp
//

import Foundation

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

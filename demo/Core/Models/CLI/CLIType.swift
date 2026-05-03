//
//  CLIType.swift
//  Wisp
//

import Foundation

enum CLIType: String, Codable, CaseIterable, Identifiable, Equatable {
    case claudeCode = "claude"
    case openCode = "opencode"
    case codex = "codex"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .claudeCode: return "Claude Code"
        case .openCode: return "OpenCode"
        case .codex: return "Codex"
        }
    }
}

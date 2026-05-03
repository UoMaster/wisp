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

protocol CLIAdapter {
    var cliType: CLIType { get }
    /// 返回可直接写入运行中 shell 的命令字符串
    func shellCommand(promptFile: URL) -> String
}

struct GenericCLIAdapter: CLIAdapter {
    let cliType: CLIType

    func shellCommand(promptFile: URL) -> String {
        "\(cliType.rawValue) \"$(cat \(promptFile.path))\""
    }
}

extension CLIType {
    func adapter() -> CLIAdapter {
        GenericCLIAdapter(cliType: self)
    }
}

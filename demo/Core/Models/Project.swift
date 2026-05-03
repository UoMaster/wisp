//
//  Project.swift
//  Wisp
//

import Foundation

struct Project: Identifiable, Codable, Equatable {
    let id: UUID
    var path: String
    var name: String
    var defaultCLI: CLIType
    var lastOpenedAt: Date

    init(id: UUID = UUID(), path: String, name: String? = nil, defaultCLI: CLIType = .claudeCode) {
        self.id = id
        self.path = path
        self.name = name ?? URL(fileURLWithPath: path).lastPathComponent
        self.defaultCLI = defaultCLI
        self.lastOpenedAt = Date()
    }

    var url: URL {
        URL(fileURLWithPath: path)
    }

    /// 用于 UI 显示的缩短路径,把 home 目录替换为 ~
    var displayPath: String {
        let home = NSHomeDirectory()
        if path.hasPrefix(home) {
            return "~" + path.dropFirst(home.count)
        }
        return path
    }
}

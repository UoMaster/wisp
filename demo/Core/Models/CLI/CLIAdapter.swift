//
//  CLIAdapter.swift
//  Wisp
//

import Foundation

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

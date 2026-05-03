//
//  PromptFileManager.swift
//  Wisp
//
//  集中管理 prompt 临时文件的创建与清理。
//

import Foundation

final class PromptFileManager {
    private let baseURL: URL

    init(baseURL: URL = FileManager.default.temporaryDirectory.appendingPathComponent("wisp")) {
        self.baseURL = baseURL
    }

    /// 写入 prompt 内容,返回临时文件 URL
    @discardableResult
    func write(prompt: String, for todoID: UUID) throws -> URL {
        try FileManager.default.createDirectory(at: baseURL, withIntermediateDirectories: true)
        let fileURL = url(for: todoID)
        try prompt.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }

    /// 拼出临时文件 URL,不写入
    func url(for todoID: UUID) -> URL {
        baseURL.appendingPathComponent("\(todoID.uuidString).prompt")
    }

    /// 删除指定 Todo 的 prompt 文件
    func cleanup(for todoID: UUID) {
        try? FileManager.default.removeItem(at: url(for: todoID))
    }

    /// 清空所有遗留文件 —— 适合 App 启动时调用
    func cleanupAll() {
        try? FileManager.default.removeItem(at: baseURL)
    }
}

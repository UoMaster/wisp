//
//  PersistenceCoordinator.swift
//  Wisp
//
//  把两个 Store 的内存状态序列化到磁盘。
//  Store 不知道磁盘的存在 —— 这里通过订阅 publisher 接管 IO。
//

import Combine
import Foundation

final class PersistenceCoordinator {
    private let projectStore: ProjectStore
    private let todoStore: TodoStore
    private let fileURL: URL
    private var cancellables: Set<AnyCancellable> = []
    private var initialLoadDone = false

    init(projectStore: ProjectStore, todoStore: TodoStore, fileURL: URL? = nil) {
        self.projectStore = projectStore
        self.todoStore = todoStore
        self.fileURL = fileURL ?? Self.defaultFileURL()
    }

    /// App 启动时调用一次 —— 加载磁盘 + 订阅后续变化
    func start() {
        load()
        initialLoadDone = true

        Publishers
            .CombineLatest(projectStore.$projects, todoStore.$todos)
            .dropFirst()
            .debounce(for: .milliseconds(120), scheduler: DispatchQueue.main)
            .sink { [weak self] _, _ in
                self?.save()
            }
            .store(in: &cancellables)
    }

    // MARK: - IO

    private func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            let persisted = try JSONDecoder().decode(PersistedData.self, from: data)
            projectStore.projects = persisted.projects
            todoStore.todos = Dictionary(
                uniqueKeysWithValues: persisted.todoEntries.map { ($0.projectID, $0.todos) }
            )
        } catch CocoaError.fileReadNoSuchFile {
            // 首次启动,无数据文件 —— 预期行为
        } catch {
            print("PersistenceCoordinator: failed to load — \(error)")
        }
    }

    private func save() {
        let entries = todoStore.todos
            .sorted { $0.key.uuidString < $1.key.uuidString }
            .map { TodoEntry(projectID: $0.key, todos: $0.value) }
        let persisted = PersistedData(projects: projectStore.projects, todoEntries: entries)
        do {
            let data = try JSONEncoder().encode(persisted)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("PersistenceCoordinator: failed to save — \(error)")
        }
    }

    // MARK: - Default Location

    private static func defaultFileURL() -> URL {
        let appSupport = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("Wisp", isDirectory: true)
        try? FileManager.default.createDirectory(at: appSupport, withIntermediateDirectories: true)
        return appSupport.appendingPathComponent("projects.json")
    }
}

// MARK: - Wire format

private struct PersistedData: Codable {
    var projects: [Project]
    var todoEntries: [TodoEntry]
}

private struct TodoEntry: Codable {
    let projectID: UUID
    let todos: [Todo]
}

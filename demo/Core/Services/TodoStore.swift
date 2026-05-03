//
//  TodoStore.swift
//  Wisp
//
//  Todo 的内存仓库 —— 不直接负责持久化(由 PersistenceCoordinator 监听)。
//

import Combine
import Foundation

final class TodoStore: ObservableObject {
    @Published var todos: [UUID: [Todo]] = [:]

    // MARK: - Read

    func todos(for projectID: UUID) -> [Todo] {
        todos[projectID] ?? []
    }

    func todo(id: UUID, in projectID: UUID) -> Todo? {
        todos[projectID]?.first { $0.id == id }
    }

    // MARK: - Write

    func add(_ todo: Todo, to projectID: UUID) {
        todos[projectID, default: []].append(todo)
    }

    func update(_ todo: Todo, in projectID: UUID) {
        modify(projectID) { list in
            guard let index = list.firstIndex(where: { $0.id == todo.id }) else { return }
            list[index] = todo
        }
    }

    func remove(id: UUID, from projectID: UUID) {
        modify(projectID) { $0.removeAll { $0.id == id } }
    }

    func replace(_ list: [Todo], for projectID: UUID) {
        todos[projectID] = list
    }

    func removeAll(for projectID: UUID) {
        todos.removeValue(forKey: projectID)
    }

    // MARK: - Status transitions

    func markRunning(todoID: UUID, in projectID: UUID) {
        modifyTodo(todoID, in: projectID) { $0.markRunning() }
    }

    func markCompleted(todoID: UUID, in projectID: UUID, exitCode: Int32, cliType: CLIType) {
        modifyTodo(todoID, in: projectID) { $0.markCompleted(exitCode: exitCode, cliType: cliType) }
    }

    func markFailed(todoID: UUID, in projectID: UUID, exitCode: Int32, cliType: CLIType) {
        modifyTodo(todoID, in: projectID) { $0.markFailed(exitCode: exitCode, cliType: cliType) }
    }

    func resetToPending(todoID: UUID, in projectID: UUID) {
        modifyTodo(todoID, in: projectID) { $0.resetToPending() }
    }

    // MARK: - Helpers

    private func modify(_ projectID: UUID, _ action: (inout [Todo]) -> Void) {
        guard var list = todos[projectID] else { return }
        action(&list)
        todos[projectID] = list
    }

    private func modifyTodo(_ todoID: UUID, in projectID: UUID, _ action: (inout Todo) -> Void) {
        modify(projectID) { list in
            guard let index = list.firstIndex(where: { $0.id == todoID }) else { return }
            action(&list[index])
        }
    }
}

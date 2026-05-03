//
//  DataStore.swift
//  Wisp
//

import Foundation
import Combine
import SwiftUI

final class DataStore: ObservableObject {
    @Published var projects: [Project] = []
    @Published var todos: [UUID: [Todo]] = [:]

    private let fileURL: URL

    init() {
        let appSupport = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("Wisp", isDirectory: true)

        try? FileManager.default.createDirectory(
            at: appSupport,
            withIntermediateDirectories: true
        )

        self.fileURL = appSupport.appendingPathComponent("projects.json")
        load()
    }

    // MARK: - CRUD: Project

    func addProject(_ project: Project) {
        projects.append(project)
        save()
    }

    func removeProject(id: UUID) {
        projects.removeAll { $0.id == id }
        todos.removeValue(forKey: id)
        save()
    }

    func updateProject(_ project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
            save()
        }
    }

    // MARK: - CRUD: Todo

    func todos(for projectID: UUID) -> [Todo] {
        todos[projectID] ?? []
    }

    func addTodo(_ todo: Todo, to projectID: UUID) {
        todos[projectID, default: []].append(todo)
        save()
    }

    func updateTodo(_ todo: Todo, in projectID: UUID) {
        modifyTodos(for: projectID) { list in
            guard let index = list.firstIndex(where: { $0.id == todo.id }) else { return }
            list[index] = todo
        }
    }

    func removeTodo(id: UUID, from projectID: UUID) {
        modifyTodos(for: projectID) { $0.removeAll { $0.id == id } }
    }

    // MARK: - Persistence

    func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            let persisted = try JSONDecoder().decode(PersistedData.self, from: data)
            self.projects = persisted.projects
            self.todos = Dictionary(
                uniqueKeysWithValues: persisted.todoEntries.map { ($0.projectID, $0.todos) }
            )
        } catch CocoaError.fileReadNoSuchFile {
            // First launch, no data yet — expected.
        } catch {
            print("Failed to load data: \(error)")
        }
    }

    func save() {
        let entries = todos
            .sorted { $0.key.uuidString < $1.key.uuidString }
            .map { TodoEntry(projectID: $0.key, todos: $0.value) }
        let persisted = PersistedData(projects: projects, todoEntries: entries)
        do {
            let data = try JSONEncoder().encode(persisted)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save data: \(error)")
        }
    }

    // MARK: - Helpers

    private func modifyTodos(for projectID: UUID, _ action: (inout [Todo]) -> Void) {
        guard var list = todos[projectID] else { return }
        action(&list)
        todos[projectID] = list
        save()
    }
}

// MARK: - Persisted Model

private struct PersistedData: Codable {
    var projects: [Project]
    var todoEntries: [TodoEntry]
}

private struct TodoEntry: Codable {
    let projectID: UUID
    let todos: [Todo]
}

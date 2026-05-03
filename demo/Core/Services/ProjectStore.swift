//
//  ProjectStore.swift
//  Wisp
//
//  Project 的内存仓库 —— 不直接负责持久化(由 PersistenceCoordinator 监听)。
//

import Combine
import Foundation

final class ProjectStore: ObservableObject {
    @Published var projects: [Project] = []

    func add(_ project: Project) {
        projects.append(project)
    }

    func remove(id: UUID) {
        projects.removeAll { $0.id == id }
    }

    func update(_ project: Project) {
        guard let index = projects.firstIndex(where: { $0.id == project.id }) else { return }
        projects[index] = project
    }

    func project(id: UUID) -> Project? {
        projects.first { $0.id == id }
    }
}

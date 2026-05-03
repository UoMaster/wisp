//
//  AppContainer.swift
//  Wisp
//
//  应用级 DI 容器:实例化、持有、装配所有 stores 与 services。
//  所有 UI 通过参数注入访问这些依赖,不再走单例。
//

import Combine
import Foundation

final class AppContainer: ObservableObject {
    let projectStore: ProjectStore
    let todoStore: TodoStore
    let bus: PanelEventBus
    let promptFiles: PromptFileManager
    let cliRunner: CLIRunner
    private let persistence: PersistenceCoordinator

    init() {
        let projectStore = ProjectStore()
        let todoStore = TodoStore()
        let bus = PanelEventBus()
        let promptFiles = PromptFileManager()

        self.projectStore = projectStore
        self.todoStore = todoStore
        self.bus = bus
        self.promptFiles = promptFiles
        self.cliRunner = CLIRunner(todoStore: todoStore, promptFiles: promptFiles, bus: bus)
        self.persistence = PersistenceCoordinator(projectStore: projectStore, todoStore: todoStore)

        // 启动时清理上次遗留的临时 prompt 文件
        promptFiles.cleanupAll()
        // 加载磁盘 + 订阅未来变化
        persistence.start()
    }
}

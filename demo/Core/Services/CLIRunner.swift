//
//  CLIRunner.swift
//  Wisp
//
//  把 "点击 Todo 启动 CLI" 这件事的全部业务逻辑收口到这里。
//  UI 只需调用 run(todo:cliType:in:) —— 之后的状态机、文件 IO、回调都不用再操心。
//

import Combine
import Foundation

final class CLIRunner {
    private let todoStore: TodoStore
    private let promptFiles: PromptFileManager
    private let bus: PanelEventBus
    private var cancellables: Set<AnyCancellable> = []

    init(todoStore: TodoStore, promptFiles: PromptFileManager, bus: PanelEventBus) {
        self.todoStore = todoStore
        self.promptFiles = promptFiles
        self.bus = bus
        observeFinishedEvents()
    }

    /// 启动一个 Todo —— 写临时文件、构造命令、通过 EventBus 通知 TerminalPanel 执行
    func run(todo: Todo, cliType: CLIType, in projectID: UUID, targetPanelID: UUID? = nil) {
        guard let payload = buildPayload(for: todo, cliType: cliType) else { return }

        todoStore.markRunning(todoID: todo.id, in: projectID)

        bus.send(.runCLI(
            projectID: projectID,
            todoID: todo.id,
            cliType: cliType,
            title: todo.title,
            command: payload.command,
            promptInput: payload.promptInput,
            targetPanelID: targetPanelID
        ))
    }

    // MARK: - Payload

    private struct Payload {
        let command: String
        let promptInput: String?
    }

    private func buildPayload(for todo: Todo, cliType: CLIType) -> Payload? {
        switch cliType {
        case .openCode:
            // OpenCode 通过交互输入 prompt,不依赖临时文件
            return Payload(
                command: cliType.rawValue,
                promptInput: todo.prompt.isEmpty ? nil : todo.prompt
            )

        default:
            do {
                let promptFile = try promptFiles.write(prompt: todo.prompt, for: todo.id)
                let command = cliType.adapter().shellCommand(promptFile: promptFile)
                return Payload(command: command, promptInput: nil)
            } catch {
                print("CLIRunner: failed to write prompt file — \(error)")
                return nil
            }
        }
    }

    // MARK: - Finish handling

    private func observeFinishedEvents() {
        bus.events
            .sink { [weak self] event in
                guard case let .cliFinished(projectID, todoID, exitCode, cliType) = event else { return }
                self?.handleFinished(projectID: projectID, todoID: todoID, exitCode: exitCode, cliType: cliType)
            }
            .store(in: &cancellables)
    }

    private func handleFinished(projectID: UUID, todoID: UUID, exitCode: Int32, cliType: CLIType) {
        if exitCode == 0 {
            todoStore.markCompleted(todoID: todoID, in: projectID, exitCode: exitCode, cliType: cliType)
        } else {
            todoStore.markFailed(todoID: todoID, in: projectID, exitCode: exitCode, cliType: cliType)
        }
        promptFiles.cleanup(for: todoID)
    }
}

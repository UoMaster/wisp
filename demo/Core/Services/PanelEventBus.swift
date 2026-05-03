//
//  PanelEventBus.swift
//  Wisp
//
//  类型安全的跨组件事件总线 —— 取代字符串 key 的 NotificationCenter。
//  Panel 之间、UI 与 Service 之间的所有跨边界通信都经过这条总线。
//

import Combine
import Foundation

final class PanelEventBus {
    enum Event {
        /// 请求在某 project 的终端中执行 CLI 命令
        case runCLI(
            projectID: UUID,
            todoID: UUID,
            cliType: CLIType,
            title: String,
            command: String,
            promptInput: String?
        )

        /// CLI 命令在终端中执行完毕
        case cliFinished(
            projectID: UUID,
            todoID: UUID,
            exitCode: Int32,
            cliType: CLIType
        )

        /// 请求弹出 Todo 编辑抽屉。todoID 为 nil 表示新建
        case presentTodoEditor(projectID: UUID, todoID: UUID?)
    }

    private let subject = PassthroughSubject<Event, Never>()

    var events: AnyPublisher<Event, Never> {
        subject.eraseToAnyPublisher()
    }

    func send(_ event: Event) {
        subject.send(event)
    }
}

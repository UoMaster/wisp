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
        /// targetPanelID 为 nil 时，只有当前 focused 的 panel 会执行
        case runCLI(
            projectID: UUID,
            todoID: UUID,
            cliType: CLIType,
            title: String,
            command: String,
            promptInput: String?,
            targetPanelID: UUID?
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

        /// 切换 Todo 面板的显示/隐藏
        case toggleTodoPanel

        /// 在当前项目新建一个标签页（Command+T）
        case newTab(projectID: UUID)

        /// 分割当前标签页（水平/垂直）
        case splitCurrentTab(projectID: UUID, direction: SplitDirection)

        /// 关闭当前标签页
        case closeCurrentTab(projectID: UUID)

        /// 关闭当前 focused 的 panel（Command+W）
        case closeFocusedPanel(projectID: UUID)

        /// 切换标签页
        case selectTab(projectID: UUID, tabID: UUID)

        /// Panel 获得焦点
        case focusPanel(projectID: UUID, panelID: UUID)

        /// Panel 即将被关闭（真正销毁，不是 SwiftUI 重建）
        case panelWillClose(projectID: UUID, panelID: UUID)
    }

    private let subject = PassthroughSubject<Event, Never>()

    var events: AnyPublisher<Event, Never> {
        subject.eraseToAnyPublisher()
    }

    func send(_ event: Event) {
        subject.send(event)
    }
}

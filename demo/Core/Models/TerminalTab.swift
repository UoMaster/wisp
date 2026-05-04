//
//  TerminalTab.swift
//  Wisp
//
//  TerminalWorkspace 中的标签页，每个标签页内部可分割为多个 Panel。
//

import Foundation

struct TerminalTab: Identifiable {
    let id: UUID
    var title: String
    var root: LayoutNode
    var focusedPanelID: UUID?

    /// 当前放大（zoom）的 panel ID，nil 表示未放大
    var zoomedPanelID: UUID?
}

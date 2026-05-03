//
//  PanelKind.swift
//  Wisp
//
//  所有"主面板"类型的统一协议 —— 后续窗口分割只需操作 [any PanelKind] 数组。
//

import SwiftUI

protocol PanelKind: View {
    var panelID: UUID { get }
    var panelTitle: String { get }
}

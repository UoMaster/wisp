//
//  PanelInstance.swift
//  Wisp
//
//  Terminal 区域中一个可独立管理的 Panel 配置。
//

import Foundation

struct PanelInstance: Identifiable {
    let id: UUID
    var title: String
    var associatedTodoID: UUID?
}

enum SplitDirection {
    case horizontal
    case vertical
}

// MARK: - LayoutNode

/// 树形布局节点，支持嵌套分割。
/// - panel: 叶子节点，一个实际的终端 Panel
/// - split: 分割容器，包含方向和多子节点
indirect enum LayoutNode: Identifiable {
    case panel(PanelInstance)
    case split(id: UUID, direction: SplitDirection, children: [LayoutNode])

    var id: UUID {
        switch self {
        case .panel(let p): return p.id
        case .split(let id, _, _): return id
        }
    }

    // MARK: - Helpers

    /// 找到指定 panelID 在树中的路径（索引数组）
    func path(to panelID: UUID) -> [Int]? {
        switch self {
        case .panel(let p):
            return p.id == panelID ? [] : nil
        case .split(_, _, let children):
            for (index, child) in children.enumerated() {
                if let subpath = child.path(to: panelID) {
                    return [index] + subpath
                }
            }
            return nil
        }
    }

    /// 根据路径获取节点
    func node(at path: [Int]) -> LayoutNode? {
        guard let first = path.first else { return self }
        guard case .split(_, _, let children) = self,
              children.indices.contains(first) else { return nil }
        return children[first].node(at: Array(path.dropFirst()))
    }

    /// 替换路径上的节点
    func replacing(at path: [Int], with newNode: LayoutNode) -> LayoutNode {
        guard let first = path.first else { return newNode }
        guard case .split(let id, let direction, var children) = self,
              children.indices.contains(first) else { return self }
        children[first] = children[first].replacing(at: Array(path.dropFirst()), with: newNode)
        return .split(id: id, direction: direction, children: children)
    }

    /// 移除路径上的 panel。如果父 split 只剩一个子节点，则拍平。
    func removingPanel(at path: [Int]) -> LayoutNode {
        guard let first = path.first else { return self }

        guard case .split(let id, let direction, var children) = self,
              children.indices.contains(first) else { return self }

        if path.count == 1 {
            children.remove(at: first)
            if children.count == 1, let only = children.first {
                return only
            }
            return .split(id: id, direction: direction, children: children)
        }

        let newChild = children[first].removingPanel(at: Array(path.dropFirst()))
        children[first] = newChild

        if children.count == 1, let only = children.first {
            return only
        }
        return .split(id: id, direction: direction, children: children)
    }

    /// 获取树中第一个 panel 的 ID
    var firstPanelID: UUID? {
        switch self {
        case .panel(let p): return p.id
        case .split(_, _, let children):
            for child in children {
                if let id = child.firstPanelID { return id }
            }
            return nil
        }
    }

    /// 判断树中是否包含指定 panel
    func contains(panelID: UUID) -> Bool {
        switch self {
        case .panel(let p): return p.id == panelID
        case .split(_, _, let children):
            return children.contains { $0.contains(panelID: panelID) }
        }
    }

    /// 获取树中所有 panel 的 ID
    var allPanelIDs: [UUID] {
        switch self {
        case .panel(let p): return [p.id]
        case .split(_, _, let children):
            return children.flatMap { $0.allPanelIDs }
        }
    }
}

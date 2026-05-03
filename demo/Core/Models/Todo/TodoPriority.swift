//
//  TodoPriority.swift
//  Wisp
//
//  仅承载语义。颜色映射见 DesignSystem/Style/PriorityStyle.swift。
//

import Foundation

enum TodoPriority: String, Codable, CaseIterable, Equatable {
    case none = "none"
    case low = "low"
    case medium = "medium"
    case high = "high"

    var displayName: String {
        switch self {
        case .none:   return "无"
        case .low:    return "低"
        case .medium: return "中"
        case .high:   return "高"
        }
    }

    var sortOrder: Int {
        switch self {
        case .high:   return 0
        case .medium: return 1
        case .low:    return 2
        case .none:   return 3
        }
    }
}

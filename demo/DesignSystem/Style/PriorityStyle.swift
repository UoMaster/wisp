//
//  PriorityStyle.swift
//  Wisp
//
//  TodoPriority 的视觉映射 —— 让 Model 层不依赖 SwiftUI。
//

import SwiftUI

enum PriorityStyle {
    static func color(for priority: TodoPriority) -> Color {
        switch priority {
        case .none:   return Theme.textTertiary
        case .low:    return Color(red: 0.35, green: 0.55, blue: 0.95)
        case .medium: return Color(red: 0.95, green: 0.60, blue: 0.25)
        case .high:   return Color(red: 0.95, green: 0.35, blue: 0.35)
        }
    }
}

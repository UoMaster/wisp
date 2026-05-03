//
//  StatusStyle.swift
//  Wisp
//
//  TodoStatus 的视觉映射。
//

import SwiftUI

enum StatusStyle {
    static func color(for status: TodoStatus) -> Color {
        switch status {
        case .pending:   return Theme.textTertiary
        case .running:   return Theme.statusRunning
        case .completed: return Theme.statusSuccess
        case .failed:    return Theme.statusDanger
        }
    }
}

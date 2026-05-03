//
//  StatusDot.swift
//  Wisp
//
//  Todo / Session 状态点 —— 取代默认的 SF Symbol icon,更紧凑、更可控。
//

import SwiftUI

struct StatusDot: View {
    let status: TodoStatus
    var size: CGFloat = 8

    var body: some View {
        ZStack {
            // 外圈光晕(running 时显示)
            if status == .running {
                Circle()
                    .fill(color.opacity(0.25))
                    .frame(width: size + 6, height: size + 6)
            }

            Circle()
                .fill(fill)
                .overlay(
                    Circle().stroke(stroke, lineWidth: Stroke.normal)
                )
                .frame(width: size, height: size)
        }
        .frame(width: size + 6, height: size + 6)
    }

    private var color: Color {
        switch status {
        case .pending:   return Theme.textTertiary
        case .running:   return Theme.statusRunning
        case .completed: return Theme.statusSuccess
        case .failed:    return Theme.statusDanger
        }
    }

    private var fill: Color {
        switch status {
        case .pending:   return Color.clear
        case .running:   return Theme.statusRunning
        case .completed: return Theme.statusSuccess
        case .failed:    return Theme.statusDanger
        }
    }

    private var stroke: Color {
        switch status {
        case .pending:   return Theme.borderStrong
        case .running:   return Theme.statusRunning
        case .completed: return Theme.statusSuccess
        case .failed:    return Theme.statusDanger
        }
    }
}

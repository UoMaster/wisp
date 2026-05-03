//
//  StaggerAppear.swift
//  Wisp
//
//  让一组 View 按 index 错开淡入 + 上移。
//

import SwiftUI

extension View {
    func staggerAppear(index: Int, appeared: Bool) -> some View {
        self
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
            .animation(
                .easeOut(duration: Motion.slow)
                    .delay(Double(index) * 0.04),
                value: appeared
            )
    }
}

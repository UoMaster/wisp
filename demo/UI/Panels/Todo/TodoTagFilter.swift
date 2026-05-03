//
//  TodoTagFilter.swift
//  Wisp
//
//  顶部水平滚动的标签筛选条。
//

import SwiftUI

struct TodoTagFilter: View {
    let tags: [String]
    @Binding var selectedTag: String?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Space.xs) {
                SelectablePill(
                    isSelected: selectedTag == nil,
                    action: { selectedTag = nil }
                ) {
                    Text("全部").font(WispFont.bodySmall)
                }

                ForEach(tags, id: \.self) { tag in
                    SelectablePill(
                        isSelected: selectedTag == tag,
                        action: { selectedTag = (selectedTag == tag) ? nil : tag }
                    ) {
                        Text(tag).font(WispFont.bodySmall)
                    }
                }
            }
            .padding(.horizontal, Space.lg)
            .padding(.vertical, Space.sm)
        }
        .overlay(alignment: .bottom) { WispDivider() }
    }
}

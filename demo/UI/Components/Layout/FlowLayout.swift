//
//  FlowLayout.swift
//  Wisp
//
//  自动换行的水平布局,用于标签云等场景。
//

import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func makeCache(subviews: Subviews) -> FlowResult {
        FlowResult(in: 0, subviews: subviews, spacing: spacing)
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout FlowResult) -> CGSize {
        cache = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return cache.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout FlowResult) {
        for (index, subview) in subviews.enumerated() {
            subview.place(
                at: CGPoint(
                    x: bounds.minX + cache.positions[index].x,
                    y: bounds.minY + cache.positions[index].y
                ),
                proposal: .unspecified
            )
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > maxWidth, x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
    }
}

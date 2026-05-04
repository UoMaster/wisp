//
//  TerminalArea.swift
//  Wisp
//
//  扁平化渲染 LayoutNode 树：所有 panel 放在 ZStack 中，
//  手动计算 frame，避免 SwiftUI 递归视图树重建导致终端刷新。
//

import SwiftUI

struct TerminalArea: View {
    let project: Project
    let bus: PanelEventBus
    let root: LayoutNode
    let focusedPanelID: UUID?
    let zoomedPanelID: UUID?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(panels, id: \.panelID) { layout in
                    let isZoomed = zoomedPanelID == layout.panelID
                    let isVisible = zoomedPanelID == nil || isZoomed
                    let frame = isZoomed ? unitRect : layout.frame

                    TerminalPanel(
                        panelID: layout.panelID,
                        project: project,
                        bus: bus,
                        isFocused: focusedPanelID == layout.panelID
                    )
                    .frame(
                        width: frame.width * geometry.size.width,
                        height: frame.height * geometry.size.height
                    )
                    .position(
                        x: (frame.minX + frame.width / 2) * geometry.size.width,
                        y: (frame.minY + frame.height / 2) * geometry.size.height
                    )
                    .opacity(isVisible ? 1 : 0)
                    .allowsHitTesting(isVisible)
                }

                ForEach(dividers, id: \.id) { divider in
                    dividerView(divider, in: geometry.size)
                        .opacity(zoomedPanelID == nil ? 1 : 0)
                }
            }
        }
        .background(Theme.bgWindow)
    }

    private var panels: [PanelLayout] {
        root.panelLayouts(in: unitRect)
    }

    private var dividers: [DividerLayout] {
        root.dividerLayouts(in: unitRect)
    }

    private var unitRect: CGRect {
        CGRect(x: 0, y: 0, width: 1, height: 1)
    }

    @ViewBuilder
    private func dividerView(_ divider: DividerLayout, in size: CGSize) -> some View {
        if divider.axis == .horizontal {
            WispDivider(axis: .horizontal)
                .frame(width: divider.length * size.width)
                .position(
                    x: divider.centerX * size.width,
                    y: divider.centerY * size.height
                )
        } else {
            WispDivider(axis: .vertical)
                .frame(height: divider.length * size.height)
                .position(
                    x: divider.centerX * size.width,
                    y: divider.centerY * size.height
                )
        }
    }
}

// MARK: - Layout Helpers

private struct PanelLayout {
    let panelID: UUID
    let frame: CGRect // 0..1 normalized
}

private struct DividerLayout {
    let id: String
    let axis: WispDivider.Axis
    let centerX: CGFloat // 0..1
    let centerY: CGFloat // 0..1
    let length: CGFloat // 0..1
}

private extension LayoutNode {
    func childRects(in rect: CGRect) -> [(rect: CGRect, child: LayoutNode)] {
        guard case .split(_, let direction, let children) = self else { return [] }
        let count = CGFloat(children.count)
        return children.enumerated().map { index, child in
            let i = CGFloat(index)
            let childRect: CGRect
            if direction == .horizontal {
                let w = rect.width / count
                childRect = CGRect(x: rect.minX + i * w, y: rect.minY, width: w, height: rect.height)
            } else {
                let h = rect.height / count
                childRect = CGRect(x: rect.minX, y: rect.minY + i * h, width: rect.width, height: h)
            }
            return (childRect, child)
        }
    }

    func panelLayouts(in rect: CGRect) -> [PanelLayout] {
        switch self {
        case .panel(let p):
            return [PanelLayout(panelID: p.id, frame: rect)]
        case .split:
            return childRects(in: rect).flatMap { $0.child.panelLayouts(in: $0.rect) }
        }
    }

    func dividerLayouts(in rect: CGRect) -> [DividerLayout] {
        switch self {
        case .panel:
            return []
        case .split(let splitID, let direction, _):
            let children = childRects(in: rect)
            var result: [DividerLayout] = []
            for (index, item) in children.enumerated() {
                let (childRect, child) = item
                if index < children.count - 1 {
                    let dividerID = "\(splitID.uuidString)-\(index)"
                    let divider: DividerLayout
                    if direction == .horizontal {
                        divider = DividerLayout(
                            id: dividerID,
                            axis: .vertical,
                            centerX: childRect.maxX,
                            centerY: rect.midY,
                            length: rect.height
                        )
                    } else {
                        divider = DividerLayout(
                            id: dividerID,
                            axis: .horizontal,
                            centerX: rect.midX,
                            centerY: childRect.maxY,
                            length: rect.width
                        )
                    }
                    result.append(divider)
                }
                result.append(contentsOf: child.dividerLayouts(in: childRect))
            }
            return result
        }
    }
}

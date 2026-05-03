//
//  FormTextEditor.swift
//  Wisp
//
//  统一外观的多行文本输入控件。
//

import SwiftUI

struct FormTextEditor: View {
    let label: String
    @Binding var text: String
    let font: Font
    let minHeight: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: Space.xs) {
            FieldLabel(label)
            TextEditor(text: $text)
                .font(font)
                .scrollContentBackground(.hidden)
                .padding(Space.sm)
                .frame(minHeight: minHeight)
                .background(
                    RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                        .fill(Theme.bgRaised)
                )
                .wispBordered(radius: Radius.sm)
        }
    }
}

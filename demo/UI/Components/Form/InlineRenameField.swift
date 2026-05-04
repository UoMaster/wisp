//
//  InlineRenameField.swift
//  Wisp
//
//  内嵌重命名输入框：Project/Tab/Panel header 共用的"点击即编辑"控件。
//

import SwiftUI

struct InlineRenameField: View {
    let initialText: String
    @Binding var isEditing: Bool
    let font: Font
    var width: CGFloat? = nil
    let onCommit: (String) -> Void

    @State private var draft: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        TextField("", text: $draft)
            .font(font)
            .foregroundStyle(Theme.textPrimary)
            .textFieldStyle(.plain)
            .background(Theme.bgRaised)
            .cornerRadius(Radius.xs)
            .frame(width: width)
            .focused($isFocused)
            .onSubmit {
                onCommit(draft)
                isEditing = false
            }
            .onExitCommand {
                isEditing = false
            }
            .onAppear {
                draft = initialText
                isFocused = true
            }
    }
}

//
//  FieldLabel.swift
//  Wisp
//

import SwiftUI

struct FieldLabel: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .sectionTitleStyle()
    }
}

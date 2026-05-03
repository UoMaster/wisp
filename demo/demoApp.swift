//
//  demoApp.swift
//  Wisp
//

import SwiftUI

@main
struct WispApp: App {
    var body: some Scene {
        WindowGroup {
            MainWindow()
                .frame(minWidth: 900, minHeight: 600)
        }
        .defaultSize(width: 1280, height: 820)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unifiedCompact(showsTitle: false))
    }
}

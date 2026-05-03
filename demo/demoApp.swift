//
//  WispApp.swift
//  Wisp
//
//  应用入口:实例化 AppContainer,注入根视图。
//

import SwiftUI

@main
struct WispApp: App {
    @StateObject private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            MainWindow(
                projectStore: container.projectStore,
                todoStore: container.todoStore,
                cliRunner: container.cliRunner,
                bus: container.bus
            )
            .frame(minWidth: 900, minHeight: 600)
        }
        .defaultSize(width: 1280, height: 820)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unifiedCompact(showsTitle: false))
    }
}

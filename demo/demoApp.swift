//
//  demoApp.swift
//  Wisp
//

import SwiftUI

@main
struct WispApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .defaultSize(width: 1200, height: 800)
        .windowResizability(.contentSize)
    }
}

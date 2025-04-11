//
//  TheBrowserApp.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 10.04.2025.
//

import SwiftUI

@main
struct TheBrowserApp: App {
    @State private var browser: Browser = Browser()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .containerBackground(.thinMaterial, for: .window)
                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
        }
        .environment(\.browser, browser)
        .defaultSize(width: 1000, height: 800)
        .windowStyle(.hiddenTitleBar)
        .windowBackgroundDragBehavior(.enabled)
    }
}

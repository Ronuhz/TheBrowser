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
//        multiple windows disabled for now, because of conflicting behaviour between them
        Window("TheBrowser", id: "main") {
            ContentView()
                .containerBackground(.thinMaterial, for: .window)
                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
                .toolbarVisibility(browser.isSidebarOpen ? .visible : .hidden, for: .windowToolbar)
                .overlay {
                    FloatingSearchBarView()
                }
        }
        .environment(\.browser, browser)
        .windowStyle(.hiddenTitleBar)
        .windowBackgroundDragBehavior(.enabled)
        .commands {
            CommandGroup(replacing: .saveItem) {
                Button("Close") {
                    NSApplication.shared.keyWindow?.performClose(nil)
                }
                .keyboardShortcut("w", modifiers: [.command, .shift])
            }
            
            CommandMenu("Shortcuts") {
                Button("New Tab...") {
                    browser.isSearchBarOpen.toggle()
                }
                .keyboardShortcut("t", modifiers: .command)
                
                Button("Close Tab") {
                    guard let currentTab = browser.getCurrentTab() else { return }
                    browser.closeTab(currentTab)
                }
                .keyboardShortcut("w", modifiers: .command)
                
                Button("Refresh the Page") {
                    browser.reloadCurrentTab()
                }
                .keyboardShortcut("r", modifiers: .command)
                
                Button("\(browser.isSidebarOpen ? "Hide" : "Show") Sidebar") {
                    withAnimation(.spring.speed(1.5)) {
                        browser.isSidebarOpen.toggle()
                    }
                }
                .keyboardShortcut("s", modifiers: .command)
            }
        }
    }
}

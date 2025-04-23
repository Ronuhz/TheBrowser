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
                .containerBackground(.thickMaterial, for: .window)
                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
                .toolbarVisibility(browser.isSidebarOpen || browser.isSidebarPeeking ? .visible : .hidden, for: .windowToolbar)
                .overlay {
                    FloatingSearchBarView()
                }
                .onOpenURL { url in
                    browser.addTab(url: url)
                    browser.isSearchBarOpen = false
                }
//            asks the user to set it as the Default Web Browser
//                .onAppear {
//                    let appURL = Bundle.main.bundleURL
//                        
//                    NSWorkspace.shared.setDefaultApplication(at: appURL, toOpenURLsWithScheme: "https") { error in
//                        dump(error)
//                    }
//                    NSWorkspace.shared.setDefaultApplication(at: appURL, toOpenURLsWithScheme: "http") { error in
//                        dump(error)
//                    }
//
//                }
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
                
                Button("Copy URL") {
                    browser.copyCurrentTabURLToClipboard()
                }
                .keyboardShortcut("c", modifiers: [.command, .shift])
                
                Button("Find on Page") {
                    guard let _ = browser.getCurrentTab() else { return }
                    
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        browser.isShowingFindOnCurrentPageUI.toggle()
                    }
                }
                .keyboardShortcut("f", modifiers: .command)
            }
        }
    }
}

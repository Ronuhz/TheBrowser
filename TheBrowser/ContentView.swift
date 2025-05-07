//
//  ContentView.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 10.04.2025.
//

import SwiftUI

/// The main content view for the browser window.
///
/// This view arranges the sidebar, the web view area, and overlays like the search bar.
struct ContentView: View {
    /// Access to the shared browser state and functionality.
    @Environment(\.browser) private var browser
    // @State private var text = "" // This seems unused, consider removing if truly not needed.
    /// Namespace for sidebar animations (currently unused but kept for potential future use).
    @Namespace private var sidebarNamespace
    
    var body: some View {
        @Bindable var browser = browser // Required for bindings ($browser.property) used by child views.

        ZStack {
            HStack {
                // Sidebar (conditionally shown)
                if browser.isSidebarOpen {
                    SidebarView()
                        .modifier(OpenSidebarViewModifier()) // Assumes this modifier handles transitions/appearance
                }
                
                // Web View Content Area
                // Displays the active web view or a placeholder if no tabs exist.
                Group {
                    if !browser.allTabs.isEmpty {
                    ZStack {
                            // Create WebView for each tab; opacity/zIndex control visibility.
                            ForEach(browser.allTabs) { tab in
                                WebView(tab: tab)
                                    .modifier(WebViewModifier()) // Assumes this handles webview appearance/padding
                                    .opacity(browser.selectedTabID != tab.id ? 0 : 1)
                                    .allowsHitTesting(browser.selectedTabID == tab.id)
                                    .zIndex(browser.selectedTabID == tab.id ? 1 : -10)
                        }
                    }
                } else {
                        // Placeholder view when there are no tabs.
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.regularMaterial)
                        .modifier(WebViewModifier())
                }
                }
            }
            
            // Peeking Sidebar (conditionally shown)
            if !browser.isSidebarOpen {
                PeekingSidebarView() // Assumes this handles the peeking interaction
            }
            
            // Overlays (Find Bar, Notifications)
            VStack {
                if browser.isShowingFindOnCurrentPageUI {
                    FindOnPageBarView()
                }
                
                if browser.isShowingCurrentTabURLCopiedNotification {
                    CurrentTabURLCopiedNotificationView(isVisible: $browser.isShowingCurrentTabURLCopiedNotification)
                        .id(browser.currentTabURLCopiedNotificationID) // Use ID for transition identity
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(.top, -38) // Adjust positioning as needed
            .padding()
        }
        .toolbar {
            // Standard toolbar items
            Group {
                ToggleSidebarButtonView()
                GoBackButtonView()
                GoForwardButtonView()
                ReloadButton()
            }
            .padding(.top, 3) // Adjust positioning as needed
        }
    }
}

#Preview {
    @Previewable @State var browserPreview: Browser = {
        let browser = Browser()
        return browser
    }()
    
    ContentView()
        .environment(\.browser, browserPreview)
}

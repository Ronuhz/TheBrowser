//
//  ContentView.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 10.04.2025.
//

import SwiftUI
import WebKit

struct ContentView: View {
    @Environment(\.browser) private var browser
    
    var body: some View {
        @Bindable var browser = browser
        ZStack {
            HStack {
//                MARK: - Sidebar
                if browser.isSidebarOpen {
                    VStack {
                        SearchBarView()

                        PageLoadingProgressView()
                        
                        NewTabButtonView()
                        
                        ScrollView {
                            VStack {
                                ForEach(browser.tabs) { tab in
                                    TabButtonView(tab: tab)
                                }
                            }
                            .padding(.horizontal, 10)
                        }
                        .padding(.horizontal, -10)
                    }
                    .modifier(SidebarContainerModifier())
                    .transition(.move(edge: .leading).combined(with: .opacity))
                }
                
                if !browser.tabs.isEmpty {
                    ZStack {
                        ForEach($browser.tabs) { $tab in
                            WebView(tab: $tab)
                                .modifier(WebViewModifier())
                                .opacity(browser.selectedTab != tab.id ? 0 : 1)
                                .allowsHitTesting(browser.selectedTab == tab.id)
                                .zIndex(browser.selectedTab == tab.id ? 1 : -10)
                        }
                    }
                } else {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.regularMaterial)
                        .modifier(WebViewModifier())
                }
            }
            
        }
        .toolbar {
            Group {
                GoBackButtonView()
                GoForwardButtonView()
                ReloadButton()
            }
            .padding(.top, 3)
        }
    }
}

#Preview {
    @Previewable @State var browser: Browser = Browser()
    ContentView()
        .environment(\.browser, browser)
}

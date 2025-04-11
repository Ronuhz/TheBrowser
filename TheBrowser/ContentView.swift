//
//  ContentView.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 10.04.2025.
//

import SwiftUI
import WebKit

struct ContentView: View {
    @State private var isShowingSidebar: Bool = true
    
    @Environment(\.browser) private var browser
    
    var body: some View {
        @Bindable var browser = browser
        ZStack {
            HStack {
//                MARK: - Sidebar
                if isShowingSidebar {
                    VStack {
                        SearchBarView()

                        PageLoadingProgressView()
                        
                        NewTabButtonView()
                        
                        #warning("Blocks drag window from anywhere")
                        ScrollView {
                            VStack {
                                ForEach(browser.tabs) { tab in
                                    TabButtonView(tab: tab)
                                }
                            }
                        }
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
                                .padding(.top, -12) // makes top padding equal to trailing, bottom and leading (18 px)
                        }
                    }
                } else {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.regularMaterial)
                        .modifier(WebViewModifier())
                        .padding(.top, isShowingSidebar ? -12 : 14)
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
    ContentView()
}

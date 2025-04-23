//
//  ContentView.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 10.04.2025.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.browser) private var browser
    @State private var text = ""
    @Namespace private var sidebarNamespace
    
    var body: some View {
        @Bindable var browser = browser
        ZStack {
            HStack {
//                MARK: - Sidebar
                if browser.isSidebarOpen {
                    SidebarView()
                        .modifier(OpenSidebarViewModifier())
                }
                
//                MARK: - WebViews
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
            
//            MARK: - Peeking Sidebar
            if browser.isSidebarOpen == false {
                PeekingSidebarView()
            }
            
            VStack {
//            MARK: - Find On Page
                if browser.isShowingFindOnCurrentPageUI {
                    FindOnPageBarView()
                }
                
//            MARK: - Current Tab's URL Copied Notification
                if browser.isShowingCurrentTabURLCopiedNotification {
                    CurrentTabURLCopiedNotificationView(isVisible: $browser.isShowingCurrentTabURLCopiedNotification)
                        .id(browser.currentTabURLCopiedNotificationID)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(.top, -38)
            .padding()
        }
        .toolbar {
            Group {
                ToggleSidebarButtonView()
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
